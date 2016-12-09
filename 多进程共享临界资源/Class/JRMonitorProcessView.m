//
//  JRMonitorProcessView.m
//  多进程共享临界资源
//
//  Created by sky on 2016/12/8.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "JRMonitorProcessView.h"
#import "JRMessageView.h"

#define kProcessDismissDuration 0.5

@interface JRMonitorProcessView()

/** 当前在临界区的process */
@property (nonatomic, strong) JRProcessView *process;

/** 名字文本 */
@property (nonatomic, weak) UILabel *nameLabel;

@end

@implementation JRMonitorProcessView

- (instancetype)init
{
    if (self = [super init]){
        
        self.backgroundColor = [UIColor greenColor];
        self.layer.cornerRadius = 5;
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont systemFontOfSize:15.0];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
    }
     return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.nameLabel.frame = self.bounds;
}

- (void)setName:(NSString *)name
{
    [super setName:name];
    
    self.nameLabel.text = name;
}

#pragma mark - 用户进程申请进入临界区和退出临界区

- (BOOL)askForEnter:(JRProcessView *)process
{
    // 临界区忙, 不让进
    if (self.isCriticalRegionBusy) return NO;
    
    // 显示消息
    [JRMessageView showMessage:[NSString stringWithFormat:@"%@申请进入临界区", process.name] viewController:self.vc];

    // 设置标题
    self.nameLabel.text = [NSString stringWithFormat:@"管程 : %@正在临界区", process.name];
    
    // 加锁
    @synchronized (self) {
        self.process = process;
        
        self.criticalReionBusy = YES;
        
    }

    return YES;
}

- (void)quitFromCriticalRegion
{
    // 修改标志位
    self.criticalReionBusy = NO;
    
    // 显示消息
    [JRMessageView showMessage:[NSString stringWithFormat:@"%@退出临界区", self.process.name] viewController:self.vc];
    
    // 设置标题
    self.nameLabel.text = @"管程";
    
    [self.process removeFromSuperview];
    // 置空
    self.process = nil;
}

@end
