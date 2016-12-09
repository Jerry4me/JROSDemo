//
//  CreateProcessController.m
//  多进程共享临界资源
//
//  Created by sky on 2016/12/8.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "CreateProcessController.h"
#import "JRUserProcessView.h"

@interface CreateProcessController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *takeTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *waitTimeTextField;
@property (weak, nonatomic) IBOutlet UISwitch *randomSwitch;

@end

@implementation CreateProcessController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor lightTextColor];
    
}

- (IBAction)createProcess:(id)sender {

    JRUserProcessView *process;
    if (self.randomSwitch.isOn) {
        process = [JRUserProcessView userProcessWithName:[NSString stringWithFormat:@"进程%d", arc4random_uniform(99) + 1] takeTime:arc4random_uniform(32) + 1 waitTime:arc4random_uniform(32) + 1];
    } else {
        process = [JRUserProcessView userProcessWithName:self.nameTextField.text takeTime:[self.takeTimeTextField.text intValue] waitTime:[self.waitTimeTextField.text intValue]];
    }

    if ([self.delegate respondsToSelector:@selector(createProcessControllerDidCreateProcess:)])
    {
        [self.delegate createProcessControllerDidCreateProcess:process];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
