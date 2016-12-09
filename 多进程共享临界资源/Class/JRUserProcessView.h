//
//  JRUserProcessView.h
//  多进程共享临界资源
//
//  Created by sky on 2016/12/8.
//  Copyright © 2016年 sky. All rights reserved.
//  用户进程

#import "JRProcessView.h"
@class JRUserProcessView;

typedef NS_ENUM(NSUInteger, ProcessState) {
    ProcessStateNone = 10,
    ProcessStateWaiting,
    ProcessStateWorking
};

@protocol JRUserProcessViewDelegate <NSObject>

- (void)userProcessViewDidStartAction:(JRUserProcessView *)process;

- (void)userProcessViewDidFinish;

- (void)userProcessViewDidEndWaiting:(JRUserProcessView *)process;

@end

@interface JRUserProcessView : JRProcessView

/** 原来的位置 */
@property (nonatomic, assign) CGPoint originCenter;

/** 占用时间 */
@property (nonatomic, assign) int takeTime;

/** 等待时间 */
@property (nonatomic, assign) int waitTime;

/** 状态 */
@property (nonatomic, assign) ProcessState state;

/** 代理 */
@property (nonatomic, weak) id<JRUserProcessViewDelegate> delegate;


+ (instancetype)userProcessWithName:(NSString *)name takeTime:(int)takeTime waitTime:(int)waitTime;

// 按钮点击事件
- (IBAction)btnOnClick;

- (void)invalidateTimer;


// 从等待队列中退出
- (void)quitFromWaitingQueue;

// 启动时钟(临界区)
- (void)startWorking;

// 启动始终(等待队列)
- (void)startWaiting;

@end
