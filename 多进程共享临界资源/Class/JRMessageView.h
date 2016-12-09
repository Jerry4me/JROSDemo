//
//  JRMessageView.h
//  多进程共享临界资源
//
//  Created by sky on 2016/12/9.
//  Copyright © 2016年 sky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JRMessageView : UIView

+ (void)showMessage:(NSString *)message viewController:(UIViewController *)vc;

@end
