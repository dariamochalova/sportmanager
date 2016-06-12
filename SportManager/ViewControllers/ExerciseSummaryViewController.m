//
//  ExerciseSummaryViewController.m
//  SportManager
//
//  Created by Darya on 01/05/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import "ExerciseSummaryViewController.h"
#import "HeartDataInfoViewController.h"
#import <MapKit/MapKit.h>

@interface ExerciseSummaryViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *avHeartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *calsLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *avSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end

@implementation ExerciseSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:lcString(@"heartData")
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(showHeartData)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.delegate = self;
    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [dataStorage exerciseById:self.exercise.oid completionBlock:^(DMExercise *result) {
        weakSelf.exercise = result;
        [weakSelf reloadData];
        [SVProgressHUD dismiss];
    } errorBlock:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Error!"];
    }];
}

- (void)reloadData
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM/yy HH:mm";
    dateFormatter.locale = [NSLocale currentLocale];
    self.dateLabel.text = [dateFormatter stringFromDate:self.exercise.startDate];
    self.nameLabel.text = self.exercise.name;
    self.avHeartRateLabel.text = [NSString stringWithFormat:@"%.0lf %@",[self.exercise getAverageHeartRate],lcString(@"bpm")];
    [self setTime];
    self.calsLabel.text = [NSString stringWithFormat:@"%.1lf",[self.exercise getCals]];
    [self setDistance];
    [self setSpeed];
    [self showGPSTrack];
}

- (void)setTime
{
    NSTimeInterval timeInterval = [self.exercise.endDate timeIntervalSinceDate:self.exercise.startDate];
    long seconds = lroundf(timeInterval); // Since modulo operator (%) below needs int or long
    
    int hour = seconds / 3600;
    int mins = (seconds % 3600) / 60;
    int secs = seconds % 60;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hour,mins,secs];
}

- (void)setSpeed
{
    self.avSpeedLabel.text = [NSString stringWithFormat:@"%.1lf",[self.exercise getAverageSpeed] * 3.6];
}

- (void)setDistance
{
    double meters = [self.exercise getDistance];
    self.distanceLabel.text = [NSString stringWithFormat:@"%.1lf",meters/1000];
}

- (void)showGPSTrack
{
    @autoreleasepool {
        CLLocationCoordinate2D *coordinates = malloc(self.exercise.gpsTrack.count * sizeof(CLLocationCoordinate2D));
        
        for (int i = 0; i < self.exercise.gpsTrack.count; i++) {
            DMGPSData *coordinate = self.exercise.gpsTrack[i];
            coordinates[i] = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        }
        
        
        MKPolyline *routeLine = [MKPolyline polylineWithCoordinates:coordinates count:self.exercise.gpsTrack.count];
        [self.mapView addOverlay:routeLine];
        
        [self.mapView setVisibleMapRect:[routeLine boundingMapRect] edgePadding:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0) animated:YES];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = self.distanceLabel.textColor;
        renderer.lineWidth = 4;
        return renderer;
    }
    return nil;
}

- (void)showHeartData
{
    [self performSegueWithIdentifier:@"heartRateDataSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"heartRateDataSegue"]) {
        HeartDataInfoViewController *vc = (HeartDataInfoViewController *)segue.destinationViewController;
        vc.heartData = self.exercise.heartData;
    }
}

@end
