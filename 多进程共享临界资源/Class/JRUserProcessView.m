//
//  JRUserProcessView.m
//  多进程共享临界资源
//
//  Created by sky on 2016/12/8.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "JRUserProcessView.h"

#define kTimerDuration 0.3

@interface JRUserProcessView()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *takeTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *waitTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *btn;

/** 执行时钟 */
@property (nonatomic, strong) NSTimer *runningTimer;

/** 等待时钟 */
@property (nonatomic, strong) NSTimer *waitingTimer;


/** 剩余时间(在临界区 or 在等待队列) */
@property (nonatomic, assign) int leftTime;

@end

@implementation JRUserProcessView

+ (instancetype)userProcessWithName:(NSString *)name takeTime:(int)takeTime waitTime:(int)waitTime
{
    JRUserProcessView *process = [[[NSBundle mainBundle] loadNibNamed:@"JRUserProcessView" owner:nil options:nil] firstObject];
    
    process.layer.cornerRadius = 5;
    process.clipsToBounds = YES;
    
    process.name = name;
    process.takeTime = takeTime;
    process.waitTime = waitTime;
    process.state = ProcessStateNone; // 默认不工作状态
    
    return process;
}

#pragma mark - private
- (void)setTakeTime:(int)takeTime
{
    _takeTime = takeTime;
    
    self.takeTimeLabel.text = [NSString stringWithFormat:@"占用时间 : %d", takeTime];
}

- (void)setName:(NSString *)name
{
    [super setName:name];
    
    self.nameLabel.text = name;
}

- (void)setWaitTime:(int)waitTime
{
    _waitTime = waitTime;
    
    self.waitTimeLabel.text = [NSString stringWithFormat:@"等待时间 : %d", waitTime];
}

- (void)setState:(ProcessState)state
{
    _state = state;
    
    switch (state) {
      case ProcessStateNone:{
        [self.btn setTitle:@"抢占资源" forState:UIControlStateNormal];
        [self.btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
      }
      break;
      
      case ProcessStateWaiting:{
        [self.btn setTitle:@"放弃等待" forState:UIControlStateNormal];
        [self.btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
      }
      break;
      
      case ProcessStateWorking:{
        [self.btn setTitle:@"退出" forState:UIControlStateNormal];
        [self.btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
      }
      break;
    }
}

- (IBAction)btnOnClick {

    if ([self.delegate respondsToSelector:@selector(userProcessViewDidStartAction:)]) {
        [self.delegate userProcessViewDidStartAction:self];
    }
    
}

- (void)quitFromWaitingQueue
{
    // 让时钟失效
    [self invalidateTimer];
    
    // 设置状态位
    self.state = ProcessStateNone;
    // 重新设置等待时间
    self.waitTime = self.waitTime;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        // 回到原来的位置
        self.center = self.originCenter;
        
    }];
    
}

- (void)startWorking
{

    self.leftTime = self.takeTime;
    self.runningTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerDuration target:self selector:@selector(runningFunc) userInfo:nil repeats:YES];
    
}

- (void)startWaiting
{
    self.leftTime = self.waitTime;
    self.waitingTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerDuration target:self selector:@selector(waitingFunc) userInfo:nil repeats:YES];
    
}

- (void)runningFunc
{
    // 占用时间减少
    self.leftTime--;
    
    // 设置文本
    self.waitTimeLabel.text = [NSString stringWithFormat:@"%d", self.leftTime];
    
    if (self.leftTime <= 0) {
        [self.runningTimer invalidate];
        
        // 通知代理
        if ([self.delegate respondsToSelector:@selector(userProcessViewDidFinish)]) {
            [self.delegate userProcessViewDidFinish];
        }
    }

}

- (void)waitingFunc
{
    // 占用时间减少
    self.leftTime--;
    
    // 设置文本
    self.waitTimeLabel.text = [NSString stringWithFormat:@"%d", self.leftTime];
    if (self.leftTime <= 0) {
        // 通知代理
        if ([self.delegate respondsToSelector:@selector(userProcessViewDidEndWaiting:)]) {
            [self.delegate userProcessViewDidEndWaiting:self];
        }
    }
}

- (void)invalidateTimer
{

    [self.runningTimer invalidate];
    self.runningTimer = nil;
    [self.waitingTimer invalidate];
    self.waitingTimer = nil;
}

@end
