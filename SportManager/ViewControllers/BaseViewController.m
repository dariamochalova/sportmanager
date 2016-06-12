//
//  BaseViewController.m
//  SportManager
//
//  Created by Darya on 11/05/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.35 green:0.24 blue:0.31 alpha:1.00];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    
    UIImage *menuImage = [UIImage imageNamed:@"menu"];
    UIButton *menu = [UIButton buttonWithType:UIButtonTypeCustom];
    menu.bounds = CGRectMake( 0, 0, 25, 20);
    [menu setImage:menuImage forState:UIControlStateNormal];
    [menu addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:menu];
    
    self.navigationItem.leftBarButtonItem = btn;

}

@end
