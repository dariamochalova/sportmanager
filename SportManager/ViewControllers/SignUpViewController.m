//
//  SignUpViewController.m
//  SportManager
//
//  Created by Darya on 30/04/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import "SignUpViewController.h"
#import "IHKeyboardAvoiding.h"
#import "DMAthlete.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstnameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastnameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *weightTextfield;
@property (weak, nonatomic) IBOutlet UITextField *ageTextfield;
@property (weak, nonatomic) IBOutlet UITextField *loginTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UIView *inputView;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupPlaceHolder:self.firstnameTextfield];
    [self setupPlaceHolder:self.lastnameTextfield];
    [self setupPlaceHolder:self.weightTextfield];
    [self setupPlaceHolder:self.ageTextfield];
    [self setupPlaceHolder:self.loginTextfield];
    [self setupPlaceHolder:self.passwordTextfield];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [IHKeyboardAvoiding setAvoidingView:self.inputView];
    [IHKeyboardAvoiding setPadding:-44];
}


- (void)setupPlaceHolder:(UITextField *)field
{
    UIColor *color = [UIColor whiteColor];
    field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:field.placeholder attributes:@{NSForegroundColorAttributeName: color}];
}

- (IBAction)signUpPressed:(id)sender {
    if (self.firstnameTextfield.text.length &&
        self.lastnameTextfield.text.length &&
        self.weightTextfield.text.length &&
        self.ageTextfield.text.length &&
        self.loginTextfield.text.length &&
        self.passwordTextfield.text.length)
    {
        __weak __typeof(self)weakSelf = self;
        [SVProgressHUD show];
        DMAthlete *athlete = [[DMAthlete alloc] init];
        athlete.firstName = weakSelf.firstnameTextfield.text;
        athlete.lastName = weakSelf.lastnameTextfield.text;
        athlete.weight = [weakSelf.weightTextfield.text floatValue];
        athlete.age = [weakSelf.ageTextfield.text intValue];
        
        [dataStorage saveAthlete:athlete
                       withLogin:weakSelf.loginTextfield.text
                        password:weakSelf.passwordTextfield.text
                 completionBlock:^{
                     [SVProgressHUD showInfoWithStatus:lcString(@"ok")];
                     [weakSelf dismissViewControllerAnimated:YES completion:nil];
                 }
                      errorBlock:^(NSError *error) {
                          [SVProgressHUD showErrorWithStatus:lcString(@"error")];
                      }];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:lcString(@"fillFields")];
    }
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
