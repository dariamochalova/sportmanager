//
//  DMExercise.m
//  SportManager
//
//  Created by Darya on 30/04/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import "DMExercise.h"
#import <CoreLocation/CoreLocation.h>

@implementation DMExercise

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.gpsTrack = [[NSMutableArray alloc] init];
        self.heartData = [[NSMutableArray alloc] init];
    }
    return self;
}

- (double)getDistance
{
    double meters = 0;
    if (self.gpsTrack.count < 2) {
        return meters;
    }
    for (int i = 0; i < self.gpsTrack.count - 1; i++) {
        DMGPSData *gpsData1 = [self.gpsTrack objectAtIndex:i];
        DMGPSData *gpsData2 = [self.gpsTrack objectAtIndex:i+1];
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:gpsData1.latitude
                                                           longitude:gpsData1.longitude];
        
        CLLocation *location2 = [[CLLocation alloc] initWithLatitude:gpsData2.latitude
                                                        longitude:gpsData2.longitude];
        meters += [location2 distanceFromLocation:location1];
    }
    return meters;
}

- (double)getCurrentCals
{
    return [self getCalsForDate:[NSDate date]];
}

- (double)getCals
{
    return [self getCalsForDate:self.endDate];
}

- (double)getCalsForDate:(NSDate *)endDate
{
    double kcals = 0;
    NSTimeInterval distanceBetweenDates = [endDate timeIntervalSinceDate:self.startDate];
    double secondsInAnHour = 3600;
    double hours = distanceBetweenDates / secondsInAnHour;
    
    double MET = 10; //Metabolic Equivalent of Task for running
    
    kcals = MET * self.athlete.weight * hours;
    
    return kcals;
}

- (double)getAverageHeartRate
{
    double avHeartRate = 0.0;
    
    if (self.heartData.count > 0)
    {
        for (DMHeartData *hrData in self.heartData) {
            avHeartRate += hrData.heartRate;
        }
        avHeartRate /= self.heartData.count;
    }
    
    return avHeartRate;
}

- (double)getAverageSpeed
{
    double avSpeed = 0.0;
    
    if (self.gpsTrack.count > 0)
    {
        for (DMGPSData *gpsData in self.gpsTrack) {
            avSpeed += gpsData.speed;
        }
        avSpeed /= self.gpsTrack.count;
        if (avSpeed <= 0) {
            avSpeed = [self getDistance] / (self.endDate.timeIntervalSince1970 - self.startDate.timeIntervalSince1970);
        }
    }
    if (avSpeed <= 0) {
        return 0.0;
    }
    return avSpeed;
}

@end
