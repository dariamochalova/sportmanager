//
//  DMLocationDataProvider.m
//  SportManager
//
//  Created by Darya on 30/04/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import "DMLocationDataProvider.h"
#import <CoreLocation/CoreLocation.h>

@interface DMLocationDataProvider () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL running;

@end

@implementation DMLocationDataProvider

- (void)initialize
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
}

- (void)start
{
    self.running = YES;
    [self.locationManager startUpdatingLocation];
}

- (void)stop
{
    self.running = NO;
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    if (!location && !self.running)
    {
        return;
    }
    DMGPSData *gpsData = [[DMGPSData alloc] init];
    gpsData.timestamp = [location.timestamp timeIntervalSince1970];
    gpsData.latitude = location.coordinate.latitude;
    gpsData.longitude = location.coordinate.longitude;
    gpsData.speed = location.speed;
    if (self.delegate) {
        [self.delegate locationReceived:gpsData];
    }
}

@end
