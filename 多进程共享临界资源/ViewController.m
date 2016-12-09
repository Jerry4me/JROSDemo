//
//  ViewController.m
//  多进程共享临界资源
//
//  Created by sky on 2016/12/8.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "ViewController.h"
#import "JRUserProcessView.h"
#import "JRMonitorProcessView.h"
#import "UIView+Extension.h"
#import "CreateProcessController.h"
#import "JRMessageView.h"

// 进程的视图宽度
#define kProcessWidth 200
// 进程的视图高度
#define kProcessHeight 44
// 空闲进程最小Y值
#define kProcessStartY 200 
// 进程视图间的间距
#define kProcessMargin 20
// 最大支持5个进程
#define kProcessMaxCount 5

@interface ViewController () <CreateProcessControllerDelegate, JRUserProcessViewDelegate>

/** 管程 */
@property (nonatomic, weak) JRMonitorProcessView *monitorProcess;

/** 进程列表 */
@property (nonatomic, strong) NSMutableArray *processes;

/** 等待队列 */
@property (nonatomic, strong) NSMutableArray *waitingProcesses;
// 临界区
@property (weak, nonatomic) IBOutlet UIView *criticalRegionView;
// 分隔符
@property (weak, nonatomic) IBOutlet UIView *divider;

@end

@implementation ViewController

- (NSMutableArray *)processes
{
    if (!_processes) {
    
        _processes = [NSMutableArray array];
    
    }
    
    return _processes;
}

- (NSMutableArray *)waitingProcesses
{
    if (!_waitingProcesses) {
    
        _waitingProcesses = [NSMutableArray array];
    
    }
    
    return _waitingProcesses;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景色
    self.view.backgroundColor = [UIColor grayColor];
    
    // 创建管程
    [self setupMonitor];
    
    // 手动创建5个进程
    [self setupProcesses];
    
}

- (void)setupMonitor
{
    // 创建管程
    JRMonitorProcessView *monitorProcess = [[JRMonitorProcessView alloc] init];
    monitorProcess.name = @"管程";
    monitorProcess.vc = self;
    
    // 设置frame
    monitorProcess.width = kProcessWidth;
    monitorProcess.height = kProcessHeight;
    monitorProcess.centerX = self.view.width / 2;
    monitorProcess.centerY = 200;
    
    [self.view addSubview:monitorProcess];
    self.monitorProcess = monitorProcess;
}

- (void)setupProcesses
{
    JRUserProcessView *process1 = [JRUserProcessView userProcessWithName:@"进程x" takeTime:15 waitTime:15];
    JRUserProcessView *process2 = [JRUserProcessView userProcessWithName:@"进程y" takeTime:7 waitTime:13];
    JRUserProcessView *process3 = [JRUserProcessView userProcessWithName:@"进程z" takeTime:9 waitTime:11];
    JRUserProcessView *process4 = [JRUserProcessView userProcessWithName:@"进程q" takeTime:8 waitTime:8];
    JRUserProcessView *process5 = [JRUserProcessView userProcessWithName:@"进程w" takeTime:24 waitTime:17];
    
    [self createProcessControllerDidCreateProcess:process1];
    [self createProcessControllerDidCreateProcess:process2];
    [self createProcessControllerDidCreateProcess:process3];
    [self createProcessControllerDidCreateProcess:process4];
    [self createProcessControllerDidCreateProcess:process5];
}

#pragma mark - process
- (IBAction)createProcess:(id)sender {

    CreateProcessController *vc = [[CreateProcessController alloc] init];

    vc.delegate = self;

    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:vc];
    
    popover.popoverContentSize = CGSizeMake(200, 200);
    
    [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}

- (IBAction)allProcessAskToEnterCriticalRegion:(id)sender {
    
    // 全部空闲的进程一起抢夺资源
    [self.processes makeObjectsPerformSelector:@selector(btnOnClick)];
}



#pragma mark CreateProcessControllerDelegate
- (void)createProcessControllerDidCreateProcess:(JRUserProcessView *)process
{
    // 进程数已达最大值
    if (self.processes.count + self.waitingProcesses.count >= kProcessMaxCount) {
        
        [JRMessageView showMessage:@"进程达到上限" viewController:self];
        
        return;
    }
    
    // 设置代理
    process.delegate = self;
    
    [self.processes addObject:process];

    process.width = kProcessWidth;
    process.height = kProcessHeight;
    
    // 把进程添加到视图上
    [self.view addSubview:process];
    
    // 重新布局空闲进程视图
    [self reLayoutProcessesPosision];
    
}

#pragma mark - JRUserProcessViewDelegate
- (void)userProcessViewDidStartAction:(JRUserProcessView *)process
{
    switch (process.state) {
      case ProcessStateNone:{ // 申请进入临界区
        
        BOOL result = [self.monitorProcess askForEnter:process];
        if (result) {
            
            // 从数组中移除
            [self.processes removeObject:process];
            
            [self reLayoutProcessesPosision];
            
            // 设置状态位
            process.state = ProcessStateWorking;
            // 动画进入到临界区
            [UIView animateWithDuration:0.5 animations:^{
            
                process.center = self.criticalRegionView.center;
            } completion:^(BOOL finished) {
                // 启动时钟
                [process startWorking];
            }];
        } else { // 不让进, 则进入就绪队列
            
            // 设置状态位
            process.state = ProcessStateWaiting;
            // 从数组中移除
            [self.processes removeObject:process];
            // 加入到等待队列中
            [self.waitingProcesses addObject:process];
            
            [self reLayoutProcessesPosision];
            
            // 计算x, y坐标
            // 行
            int row = (self.waitingProcesses.count >= 5) ? 1 : 0;
            // 列
            int column = (self.waitingProcesses.count % 5) - 1;
            
            // 动画移动到某位置
            [UIView animateWithDuration:0.5 animations:^{
                
                process.x = kProcessMargin + (kProcessMargin + kProcessWidth) * column;
                process.y = (self.divider.y + kProcessMargin) + (kProcessMargin + kProcessHeight) * row;

                [self reLayoutWatingQueue];
                
            } completion:^(BOOL finished) {
                
                // 启动始终, 开始倒计时
                [process startWaiting];
                
            }];
            
        }
      }
      break;
      
      case ProcessStateWaiting:{ // 从等待队列中退出
      
        [self.waitingProcesses removeObject:process];
        [self.processes addObject:process];
        // 将进程从等待队列中移除
        [process quitFromWaitingQueue];
        
        // 重新调整就绪队列中进程的位置
        [self reLayoutProcessesPosision];
        [self reLayoutWatingQueue];
        
      }
      break;
      
      case ProcessStateWorking:{ // 从临界区中退出
        [self userProcessViewDidFinish];
      
      }
      break;
    }
}

- (void)userProcessViewDidFinish
{
    [self.monitorProcess quitFromCriticalRegion];
    
    // 取出就绪队列的第一个, 让他进入临界区
    if (self.waitingProcesses.count == 0) return;
    
    JRUserProcessView *firstProcess = [self.waitingProcesses firstObject];
    
    if (firstProcess != nil) {
        
        // 申请进入临界区
        BOOL result = [self.monitorProcess askForEnter:firstProcess];
        if (result) {
            
            // 让时钟失效
            [firstProcess invalidateTimer];
            
            // 从数组中移除
            [self.waitingProcesses removeObject:firstProcess];
            
            // 设置状态位
            firstProcess.state = ProcessStateWorking;
            // 动画进入到临界区
            [UIView animateWithDuration:0.5 animations:^{
            
                firstProcess.center = self.criticalRegionView.center;
            } completion:^(BOOL finished) {
                // 启动时钟
                [firstProcess startWorking];
                
                // 排列队伍
                [self reLayoutWatingQueue];
            }];
            
        }
    }
    
}

- (void)userProcessViewDidEndWaiting:(JRUserProcessView *)process
{
    // 不等了, 回到之前的地方
    [self.waitingProcesses removeObject:process];
    
    [self.processes addObject:process];
    
    [process quitFromWaitingQueue];
    
    // 重新调整就绪队列中进程的位置
    [self reLayoutProcessesPosision];
    [self reLayoutWatingQueue];
    
}

#pragma mark - reLayout algorithm

- (void)reLayoutWatingQueue
{
    // 取出就绪队列的所有进程, 重新计算x, y
    [self.waitingProcesses enumerateObjectsUsingBlock:^(JRUserProcessView *process, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // 列
        int column = (idx % kProcessMaxCount);
        
        // 动画移动到某位置
        [UIView animateWithDuration:0.2 animations:^{
            process.x = kProcessMargin + (kProcessMargin + kProcessWidth) * column;
        }];
        
    }];
}

- (void)reLayoutProcessesPosision
{
    // 取出就绪队列的所有进程, 重新计算x, y
    [self.processes enumerateObjectsUsingBlock:^(JRUserProcessView *process, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // 行
        int row = (idx % kProcessMaxCount);
        // 列
        int column = 1;
        
        // 动画移动到某位置
        [UIView animateWithDuration:0.2 animations:^{
            process.y = kProcessStartY + (kProcessHeight + kProcessMargin) * row ;
            process.x = self.view.width - (kProcessWidth + kProcessMargin) * column;
        }];
        
    }];
}


@end
