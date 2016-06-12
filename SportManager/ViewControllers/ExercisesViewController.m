//
//  ExercisesViewController.m
//  SportManager
//
//  Created by Darya on 01/05/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import "ExercisesViewController.h"
#import "ExerciseTableViewCell.h"
#import "ExerciseSummaryViewController.h"

@interface ExercisesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<DMExercise *> *exersices;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) DMExercise *selectedExercise;


@end

@implementation ExercisesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [dataStorage exercisesSummaryByAthlete:exerciseManager.currentAthlete
                           completionBlock:^(NSArray *results) {
                               weakSelf.exersices = results;
                               [weakSelf.tableView reloadData];
                               [SVProgressHUD dismiss];
                               
                           }
                                errorBlock:^(NSError *error) {
                                    [SVProgressHUD showErrorWithStatus:@"Error!"];
                                }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.exersices.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExerciseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExerciseCellIdentifier" forIndexPath:indexPath];
    DMExercise *exercise = [self.exersices objectAtIndex:indexPath.row];
    [cell setExercise:exercise];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedExercise = [self.exersices objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"exerciseDetailSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"exerciseDetailSegue"]) {
        ExerciseSummaryViewController *dest = (ExerciseSummaryViewController *)segue.destinationViewController;
        dest.exercise = self.selectedExercise;
    }
    
}

@end
