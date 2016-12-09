//
//  CreateProcessController.h
//  多进程共享临界资源
//
//  Created by sky on 2016/12/8.
//  Copyright © 2016年 sky. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JRUserProcessView;

@protocol CreateProcessControllerDelegate <NSObject>

- (void)createProcessControllerDidCreateProcess:(JRUserProcessView *)process;

@end

@interface CreateProcessController : UIViewController

/** 代理 */
@property (nonatomic, weak) id<CreateProcessControllerDelegate> delegate;

@end
