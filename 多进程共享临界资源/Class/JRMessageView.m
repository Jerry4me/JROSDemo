//
//  JRMessageView.m
//  多进程共享临界资源
//
//  Created by sky on 2016/12/9.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "JRMessageView.h"
#import "UIView+Extension.h"

@interface JRMessageView()
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation JRMessageView

+ (void)showMessage:(NSString *)message viewController:(UIViewController *)vc
{
    // 创建自身
    JRMessageView *msgView = [[[NSBundle mainBundle] loadNibNamed:@"JRMessageView" owner:nil options:nil] firstObject];
    
    // 设置tag
    msgView.tag = 999;
    
    int msgX = 0;
    int msgMinY = 20;
    int msgMaxY = 64;
    
    // 判断是否有msgView正在显示
    JRMessageView *aliveMsgView = (JRMessageView *)[vc.view viewWithTag:999];
    
    if (aliveMsgView) msgMaxY += 44;
    
    // 设置文字
    msgView.messageLabel.text = message;
    
    msgView.alpha = 0.0;
    
    msgView.x = msgX;
    msgView.y = msgMinY;
    // 显示
    [vc.view insertSubview:msgView belowSubview:vc.navigationController.navigationBar];
    
    [UIView animateWithDuration:1 animations:^{
        msgView.alpha = 1.0;
        msgView.y = msgMaxY;
    } completion:^(BOOL finished) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:1 animations:^{
                msgView.alpha = 0.0;
                msgView.y = msgMinY;
            } completion:^(BOOL finished) {
                [msgView removeFromSuperview];
            }];
            
        });
        
    }];
}

@end
