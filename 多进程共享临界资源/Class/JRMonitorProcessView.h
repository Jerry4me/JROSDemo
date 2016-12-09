//
//  JRMonitorProcessView.h
//  多进程共享临界资源
//
//  Created by sky on 2016/12/8.
//  Copyright © 2016年 sky. All rights reserved.
//  管程

#import "JRProcessView.h"

@interface JRMonitorProcessView : JRProcessView


/** 控制器 */
@property (nonatomic, weak) UIViewController *vc;


/** 临界区是否忙 */
@property (nonatomic, assign, getter=isCriticalRegionBusy) BOOL criticalReionBusy;

/**
 进程process申请进入临界区

 @return YES : 允许; NO : 不允许
 */
- (BOOL)askForEnter:(JRProcessView *)process;


/**
 当前在临界区的process退出临界区
 */
- (void)quitFromCriticalRegion;

@end
