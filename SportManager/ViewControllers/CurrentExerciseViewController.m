//
//  CurrentExerciseViewController.m
//  SportManager
//
//  Created by Darya on 01/05/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import "CurrentExerciseViewController.h"
#import <MapKit/MapKit.h>
#import "MKInputBoxView.h"

@interface CurrentExerciseViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *calsLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation CurrentExerciseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.showsUserLocation = YES;
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.delegate = self;
    
    self.navigationBar.barTintColor = [UIColor colorWithRed:0.35 green:0.24 blue:0.31 alpha:1.00];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationReceived:) name:DMExerciseManagerLocationReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heartDataReceived:) name:DMExerciseManagerHeartDataReceived object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(timerTick)
                                                userInfo:nil
                                                 repeats:YES];
}

- (IBAction)stopExercisePressed:(id)sender {
    __weak __typeof(self)weakSelf = self;
    MKInputBoxView *inputBoxView = [MKInputBoxView boxOfType:PlainTextInput];
    inputBoxView.onSubmit = ^(NSString *name, NSString *string2){
        exerciseManager.currentExercise.name = name;
        [exerciseManager finishExercise];
        [weakSelf.timer invalidate];
        weakSelf.timer = nil;
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    [inputBoxView setTitle:lcString(@"enterExerciseNameTitle")];
    [inputBoxView setMessage:lcString(@"enterExerciseName")];
    
    [inputBoxView show];
}

- (IBAction)cancelPressed:(id)sender {
    [self.timer invalidate];
    self.timer = nil;
    [exerciseManager resetExercise];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.001;
    span.longitudeDelta = 0.001;
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [aMapView setRegion:region animated:YES];
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

- (void)locationReceived:(NSNotification *)notification
{
    @autoreleasepool {
        DMGPSData *gpsData  = (DMGPSData *)notification.object;
        [self setSpeed:gpsData];
        [self setDistance];
        if(exerciseManager.currentExercise.gpsTrack.count < 2)
        {
            return;
        }
        CLLocationCoordinate2D coordinates[2];
        DMGPSData *coordinate1 = [exerciseManager.currentExercise.gpsTrack lastObject];
        DMGPSData *coordinate2 = [exerciseManager.currentExercise.gpsTrack objectAtIndex:exerciseManager.currentExercise.gpsTrack.count - 2];
        coordinates[0] = CLLocationCoordinate2DMake(coordinate1.latitude, coordinate1.longitude);
        coordinates[1] = CLLocationCoordinate2DMake(coordinate2.latitude, coordinate2.longitude);
        MKPolyline *routeLine = [MKPolyline polylineWithCoordinates:coordinates count:2];
        [self.mapView addOverlay:routeLine];
    }
}

- (void)heartDataReceived:(NSNotification *)notification
{
    DMHeartData *heartData  = (DMHeartData *)notification.object;
    [self setHeartRate:heartData];
}

- (void)timerTick
{
    exerciseManager.currentExercise.endDate = [NSDate date];
    [self setCals];
    [self setTime];
}

- (void)setDistance
{
    double meters = [exerciseManager.currentExercise getDistance];
    self.distanceLabel.text = [NSString stringWithFormat:@"%.1lf",meters/1000];
}

- (void)setSpeed:(DMGPSData*)location
{
    double speed = location.speed;
    if (speed <= 0) {
        speed = [exerciseManager.currentExercise getAverageSpeed];
        
    }
    self.speedLabel.text = [NSString stringWithFormat:@"%.1lf",speed * 3.6];
    self.speedTitleLabel.text = lcString(@"kmh");
}

- (void)setCals
{
    double kcals = [exerciseManager.currentExercise getCurrentCals];
    self.calsLabel.text = [NSString stringWithFormat:@"%.2lf",kcals];
}

- (void)setTime
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:exerciseManager.currentExercise.startDate];
    long seconds = lroundf(timeInterval); // Since modulo operator (%) below needs int or long
    
    int hour = seconds / 3600;
    int mins = (seconds % 3600) / 60;
    int secs = seconds % 60;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hour,mins,secs];
}

- (void)setHeartRate:(DMHeartData *)heartData
{
    self.heartRateLabel.text = [NSString stringWithFormat:@"%.0lf %@", heartData.heartRate, lcString(@"bpm")];
}


@end
