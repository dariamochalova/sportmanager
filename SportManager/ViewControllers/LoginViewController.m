//
//  LoginViewController.m
//  SportManager
//
//  Created by Darya on 30/04/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import "LoginViewController.h"
#import "IHKeyboardAvoiding.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *loginTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UIView *inputView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupPlaceHolder:self.loginTextfield];
    [self setupPlaceHolder:self.passwordTextfield];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [IHKeyboardAvoiding setAvoidingView:self.inputView];
    [IHKeyboardAvoiding setPadding:-42];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [IHKeyboardAvoiding removeAll];
}

- (void)setupPlaceHolder:(UITextField *)field
{
    UIColor *color = [UIColor whiteColor];
    field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:field.placeholder attributes:@{NSForegroundColorAttributeName: color}];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)loginPressed:(id)sender {
    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [dataStorage loadUserByLogin:self.loginTextfield.text
                        password:self.passwordTextfield.text
                 completionBlock:^(id result) {
                     DMAthlete *athlete = (DMAthlete*)result;
                     exerciseManager.currentAthlete = athlete;
                     [SVProgressHUD dismiss];
                     [weakSelf performSegueWithIdentifier:@"login" sender:weakSelf];
                     [weakSelf resetView];
                 }
                      errorBlock:^(NSError *error) {
                          [SVProgressHUD showInfoWithStatus:lcString(@"error")];
                      }];
}
- (IBAction)signUpPressed:(id)sender {
    [self resetView];
}

- (void)resetView
{
    self.loginTextfield.text = @"";
    self.passwordTextfield.text = @"";
}

@end
