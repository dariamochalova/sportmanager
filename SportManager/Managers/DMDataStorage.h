//
//  DMDataStorage.h
//  SportManager
//
//  Created by Darya on 30/04/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMExercise.h"
#import "DMAthlete.h"
#import "DMGPSData.h"
#import "DMHeartData.h"

@interface DMDataStorage : NSObject

+ (instancetype)sharedStorage;
- (void)prepareToStart;
- (void)prepareToExit;

#pragma mark - Load

- (void)loadUserByLogin:(NSString *)login
               password:(NSString *)password
        completionBlock:(entityBlockType)completionBlock
             errorBlock:(errorBlockType)errorBlock;

- (void)exercisesSummaryByAthlete:(DMAthlete *)athlete
                  completionBlock:(queryBlockType)completionBlock
                       errorBlock:(errorBlockType)errorBlock;

- (void)exerciseById:(int)oid
     completionBlock:(entityBlockType)completionBlock
          errorBlock:(errorBlockType)errorBlock;

- (void)lastExerciseWithCompletionBlock:(entityBlockType)completionBlock
                             errorBlock:(errorBlockType)errorBlock;

#pragma mark - Save

- (void)saveAthlete:(DMAthlete*)athlete
          withLogin:(NSString *)login
           password:(NSString *)password
    completionBlock:(completionBlockType)completionBlock
         errorBlock:(errorBlockType)errorBlock;

- (void)saveAthlete:(DMAthlete*)athlete
    completionBlock:(completionBlockType)completionBlock
         errorBlock:(errorBlockType)errorBlock;

- (void)saveExercise:(DMExercise*)exercise
     completionBlock:(completionBlockType)completionBlock
          errorBlock:(errorBlockType)errorBlock;

@end
