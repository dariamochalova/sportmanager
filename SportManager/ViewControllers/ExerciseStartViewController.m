//
//  ExerciseStartViewController.m
//  SportManager
//
//  Created by Darya on 01/05/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import "ExerciseStartViewController.h"
#import <MapKit/MapKit.h>

@interface ExerciseStartViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *startExerciseButton;
@property (strong, nonatomic) DMExercise *lastExercise;
@property (weak, nonatomic) IBOutlet UILabel *lastExerciseLabel;
@end

@implementation ExerciseStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.delegate = self;
    self.title = @"Run Boy Run";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [dataStorage lastExerciseWithCompletionBlock:^(DMExercise *result) {
        weakSelf.lastExercise = result;
        [weakSelf reloadData];
        [SVProgressHUD dismiss];
    } errorBlock:^(NSError *error) {
        if (error.code == 404) {
            [weakSelf lastExerciseNotFound];
        }
        [SVProgressHUD dismiss];
    }];
}

- (void)reloadData
{
    double distance = [self.lastExercise getDistance] / 1000;
    double timeInMin = lroundf([self.lastExercise.endDate timeIntervalSinceDate:self.lastExercise.startDate]) / 60;
    self.lastExerciseLabel.text = [NSString stringWithFormat:@"%.1lf %@ / %.1lf %@",distance,lcString(@"km"),timeInMin,lcString(@"min")];
}

- (void)lastExerciseNotFound
{
    self.lastExerciseLabel.text = lcString(@"notFound");
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [aMapView setRegion:region animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.mapView.showsUserLocation = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.mapView.showsUserLocation = YES;
}

- (IBAction)startExercisePressed:(id)sender
{
    [exerciseManager startExercise];
}

@end
