//
//  DMExerciseManager.h
//  SportManager
//
//  Created by Darya on 30/04/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMExercise.h"

@interface DMExerciseManager : NSObject

@property (nonatomic, strong) DMExercise *currentExercise;
@property (nonatomic, strong) DMAthlete *currentAthlete;

+ (instancetype)sharedManager;
- (void)initialize;

- (void)startExercise;
- (void)finishExercise;
- (void)resetExercise;

@end
