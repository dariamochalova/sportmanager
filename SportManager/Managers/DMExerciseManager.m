//
//  DMExerciseManager.m
//  SportManager
//
//  Created by Darya on 30/04/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import "DMExerciseManager.h"
#import "DMLocationDataProvider.h"
#import "DMHeartDataProvider.h"

@interface DMExerciseManager () <DMLocationDataProviderDelegate, DMHeartDataProviderDelegate>

@property (nonatomic, strong) DMLocationDataProvider *locationProvider;
@property (nonatomic, strong) DMHeartDataProvider *heartDataProvider;

@end

@implementation DMExerciseManager

+ (instancetype)sharedManager
{
    static DMExerciseManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    if (self = [super init])
    {
        self.locationProvider = [[DMLocationDataProvider alloc] init];
        self.locationProvider.delegate = self;
        self.heartDataProvider = [[DMHeartDataProvider alloc] init];
        self.heartDataProvider.delegate = self;
    }
    return self;
}

- (void)initialize
{
    [self.locationProvider initialize];
    [self.heartDataProvider initialize];
}

- (void)startExercise
{
    DMExercise *exercise = [[DMExercise alloc] init];
    exercise.athlete = self.currentAthlete;
    exercise.startDate = [NSDate date];
    [self startLocationTracking];
    [self.heartDataProvider start];
    self.currentExercise = exercise;
}

- (void)finishExercise
{
    [self.locationProvider stop];
    [self.heartDataProvider stop];
    self.currentExercise.endDate = [NSDate date];
    self.currentExercise.cal = [self.currentExercise getCals];
    [dataStorage saveExercise:self.currentExercise completionBlock:nil errorBlock:nil];
    self.currentExercise = nil;
}

- (void)resetExercise
{
    [self.locationProvider stop];
    [self.heartDataProvider stop];
    self.currentExercise = nil;
}

#pragma mark - DMHeartDataProvider

- (void)heartDataReceived:(DMHeartData *)heartData
{
    [self.currentExercise.heartData addObject:heartData];
    [[NSNotificationCenter defaultCenter] postNotificationName:DMExerciseManagerHeartDataReceived object:heartData userInfo:nil];
}

#pragma mark - DMLocationDataProvider

- (void)startLocationTracking
{
    [self.locationProvider start];
}

- (void)locationReceived:(DMGPSData *)location
{
    if (location.timestamp < [self.currentExercise.startDate timeIntervalSince1970]) {
        return;
    }
    [self.currentExercise.gpsTrack addObject:location];
    [[NSNotificationCenter defaultCenter] postNotificationName:DMExerciseManagerLocationReceived object:location userInfo:nil];
}

@end
