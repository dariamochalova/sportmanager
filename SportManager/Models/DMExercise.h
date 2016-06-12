//
//  DMExercise.h
//  SportManager
//
//  Created by Darya on 30/04/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMAthlete.h"
#import "DMGPSData.h"
#import "DMHeartData.h"

@interface DMExercise : NSObject

@property (nonatomic, assign) int oid;
@property (nonatomic, strong) DMAthlete *athlete;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) double cal;
@property (nonatomic, strong) NSMutableArray<DMHeartData *> *heartData;
@property (nonatomic, strong) NSMutableArray<DMGPSData *> *gpsTrack;
@property (nonatomic, strong) NSString *name;

- (double)getDistance;
- (double)getCurrentCals;
- (double)getCals;
- (double)getAverageHeartRate;
- (double)getAverageSpeed;

@end
