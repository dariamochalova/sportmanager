//
//  DMDataStorage.m
//  SportManager
//
//  Created by Darya on 30/04/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import "DMDataStorage.h"
#import "FMDB.h"

@interface DMDataStorage ()

@property (nonatomic) dispatch_queue_t dbQueue;
@property (nonatomic, strong) FMDatabase *db;

@end

@implementation DMDataStorage

#pragma mark - Basic

+ (instancetype)sharedStorage
{
    static DMDataStorage *sharedStorage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStorage = [[self alloc] init];
    });
    return sharedStorage;
}

- (id)init {
    if (self = [super init])
    {
        self.dbQueue = dispatch_queue_create("daryamochalova.sportmanager.dbQueue", NULL);
        __weak __typeof(self)weakSelf = self;
        dispatch_async(self.dbQueue, ^{
            [weakSelf prepareToStart];
        });
    }
    return self;
}

- (void)prepareToStart
{
    [self copyDatabaseIfNeeded];
    NSString *path = [self getDBPath];
    NSLog(@"db path:%@",path);
    self.db = [FMDatabase databaseWithPath:path];
    if (![self.db open])
    {
        self.db = nil;
    }
}

- (void)prepareToExit
{
    [self.db close];
    self.db = nil;
}

- (void) copyDatabaseIfNeeded {
    
    //Using NSFileManager we can perform many file system operations.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSString *dbPath = [self getDBPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if(!success) {
        
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"database.db"];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        
        if (!success)
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

- (NSString *) getDBPath
{
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    //NSLog(@"dbpath : %@",documentsDir);
    return [documentsDir stringByAppendingPathComponent:@"database.db"];
}

#pragma mark - Load

- (void)exercisesSummaryByAthlete:(DMAthlete *)athlete completionBlock:(queryBlockType)completionBlock errorBlock:(errorBlockType)errorBlock
{
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.dbQueue, ^{
        NSError *error = nil;
        FMResultSet *set = [weakSelf.db executeQuery:@"select id, start_time, end_time, name from exercise where athlete_id = ?"
                                              values:@[@(athlete.oid)]
                                               error:&error];
        if (error)
        {
            if (errorBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorBlock(error);
                });
            }
            return;
        }
        NSMutableArray *exercises = [[NSMutableArray alloc] init];
        while ([set next])
        {
            DMExercise *exercise = [[DMExercise alloc] init];
            exercise.oid = [set intForColumnIndex:0];
            exercise.startDate = [set dateForColumnIndex:1];
            exercise.endDate = [set dateForColumnIndex:2];
            exercise.name = [set stringForColumnIndex:3];
            [exercises addObject:exercise];
        }
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(exercises);
            });
        }
    });
}

- (void)loadUserByLogin:(NSString *)login
               password:(NSString *)password
        completionBlock:(entityBlockType)completionBlock
             errorBlock:(errorBlockType)errorBlock
{
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.dbQueue, ^{
        NSError *error = nil;
        FMResultSet *set = [weakSelf.db executeQuery:@"select * from users where login = ? and password = ? and active = 1"
                                              values:@[login, password]
                                               error:&error];
        if (error)
        {
            if (errorBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorBlock(error);
                });
            }
            return;
        }
        int athlete_id = -1;
        if ([set next])
        {
            athlete_id = [set intForColumn:@"athlete_id"];
            FMResultSet *s = [weakSelf.db executeQuery:@"select * from athlete where id = ?" values:@[@(athlete_id)] error:&error];
            if (error)
            {
                if (errorBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        errorBlock(error);
                    });
                }
                return;
            }
            DMAthlete *athlete = nil;
            if ([s next]) {
                athlete = [[DMAthlete alloc] init];
                athlete.oid = [s intForColumnIndex:0];
                athlete.firstName = [s stringForColumnIndex:1];
                athlete.lastName = [s stringForColumnIndex:2];
                athlete.weight = [s doubleForColumnIndex:3];
                athlete.age = [s intForColumnIndex:4];
            }
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(athlete);
                });
            }
            return;
        }
        error = [[NSError alloc] initWithDomain:@"User not found" code:404 userInfo:nil];
        if (errorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        }
        return;
    });
}

- (void)exerciseById:(int)oid
     completionBlock:(entityBlockType)completionBlock
          errorBlock:(errorBlockType)errorBlock
{
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.dbQueue, ^{
        NSError *error = nil;
        FMResultSet *set = [weakSelf.db executeQuery:@"select * from exercise where id = ?"
                                              values:@[@(oid)]
                                               error:&error];
        
        if (error)
        {
            if (errorBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorBlock(error);
                });
            }
            return;
        }
        DMExercise *exercise = nil;
        if ([set next])
        {
            exercise = [[DMExercise alloc] init];
            exercise.oid = [set intForColumnIndex:0];
            exercise.startDate = [set dateForColumnIndex:2];
            exercise.endDate = [set dateForColumnIndex:3];
            exercise.cal = [set doubleForColumnIndex:4];
            exercise.name = [set stringForColumnIndex:5];
            exercise.athlete = exerciseManager.currentAthlete;
        }
        if (exercise) {
            exercise.gpsTrack = [weakSelf loadGPSDataForExercise:exercise.oid];
            exercise.heartData = [weakSelf loadHeartDataForExercise:exercise.oid];
            
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(exercise);
                });
            }
            return;
        }
        if (errorBlock) {
            error = [[NSError alloc] initWithDomain:@"Exercise load error" code:13 userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        }
    });
}


- (NSMutableArray *)loadGPSDataForExercise:(NSUInteger)exersice_id
{
    FMResultSet *set = [self.db executeQuery:@"select * from gps_data where exercise_id = ? order by timestamp asc",@(exersice_id)];
    NSMutableArray *gpsData = [[NSMutableArray alloc] init];
    while ([set next]) {
        DMGPSData *gps = [[DMGPSData alloc] init];
        
        gps.oid = [set intForColumnIndex:0];
        gps.timestamp = [set doubleForColumnIndex:2];
        gps.latitude = [set doubleForColumnIndex:3];
        gps.longitude = [set doubleForColumnIndex:4];
        gps.speed = [set doubleForColumnIndex:5];
        
        [gpsData addObject:gps];
    }

    return gpsData;
}

- (NSMutableArray *)loadHeartDataForExercise:(NSUInteger)exersice_id
{
    FMResultSet *set = [self.db executeQuery:@"select * from heart_data where exercise_id = ? order by timestamp asc",@(exersice_id)];
    NSMutableArray *heartData = [[NSMutableArray alloc] init];
    while ([set next]) {
        DMHeartData *heart = [[DMHeartData alloc] init];
        
        heart.oid = [set intForColumnIndex:0];
        heart.timestamp = [set doubleForColumnIndex:2];
        heart.heartRate = [set doubleForColumnIndex:3];
        
        [heartData addObject:heart];
    }
    
    return heartData;
}

- (void)lastExerciseWithCompletionBlock:(entityBlockType)completionBlock errorBlock:(errorBlockType)errorBlock
{
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.dbQueue, ^{
        NSError *error = nil;
        FMResultSet *set = [weakSelf.db executeQuery:@"select oid from exercise where athlete_id = ? order by start_time desc limit 1"
                                              values:@[@(exerciseManager.currentAthlete.oid)]
                                               error:&error];
        
        if (error)
        {
            if (errorBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorBlock(error);
                });
            }
            return;
        }
        if ([set next])
        {
            int lastId = [set intForColumnIndex:0];
            [weakSelf exerciseById:lastId completionBlock:completionBlock errorBlock:errorBlock];
            return;
        }
        error = [[NSError alloc] initWithDomain:@"User not found" code:404 userInfo:nil];
        if (errorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        }
        return;
    });
}

#pragma mark - Save

- (void)saveAthlete:(DMAthlete *)athlete
          withLogin:(NSString *)login
           password:(NSString *)password
    completionBlock:(completionBlockType)completionBlock
         errorBlock:(errorBlockType)errorBlock
{
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.dbQueue, ^{
        NSError *error = nil;
        FMResultSet *set = [weakSelf.db executeQuery:@"select id from users where login = ?;"
                                              values:@[login]
                                               error:&error];
        
        if (error)
        {
            if (errorBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorBlock(error);
                });
            }
            return;
        }
        if ([set next])
        {
            error = [[NSError alloc] initWithDomain:@"User exist" code:10 userInfo:nil];
            if (errorBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorBlock(error);
                });
            }
            return;
        }
        
        BOOL success = [weakSelf.db executeUpdate:@"insert into athlete (firstname, lastname, weight, age) values(?,?,?,?)",athlete.firstName,athlete.lastName,@(athlete.weight),@(athlete.age)];
        if (success) {
            NSInteger athlete_id = [weakSelf.db lastInsertRowId];
            success = [weakSelf.db executeUpdate:@"insert into users (active, login, password, athlete_id) values(1,?,?,?)",login,password,@(athlete_id)];
            if (success) {
                if (completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock();
                    });
                }
                return;
            }
        }
        error = [[NSError alloc] initWithDomain:@"User create error" code:11 userInfo:nil];
        if (errorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        }
        return;
    });
}

- (void)saveExercise:(DMExercise *)exercise
     completionBlock:(completionBlockType)completionBlock
          errorBlock:(errorBlockType)errorBlock
{
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.dbQueue, ^{
        BOOL success = [weakSelf.db executeUpdate:@"insert into exercise (athlete_id, start_time, end_time, cal, name) values(?,?,?,?,?)",@(exercise.athlete.oid), exercise.startDate, exercise.endDate, @(exercise.cal), exercise.name];
        if (success) {
            NSUInteger exercise_id = [weakSelf.db lastInsertRowId];
            BOOL gpsSuccess = YES;
            BOOL heartSuccess = YES;
            for (DMGPSData *gpsData in exercise.gpsTrack) {
                if(![weakSelf saveGPSData:gpsData forExercise:exercise_id])
                {
                    gpsSuccess = NO;
                    break;
                }
            }
            for (DMHeartData *heartData in exercise.heartData) {
                if(![weakSelf saveHeartData:heartData forExercise:exercise_id])
                {
                    heartSuccess = NO;
                    break;
                }
            }
            if (gpsSuccess & heartSuccess) {
                if (completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock();
                    });
                }
                return;
            }
            
        }
        NSError *error = [[NSError alloc] initWithDomain:@"Saving error" code:1 userInfo:nil];
        if (errorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        }
    });
}

- (BOOL)saveGPSData:(DMGPSData*)gpsData forExercise:(NSUInteger)exercise_id
{
    return [self.db executeUpdate:@"insert into gps_data (exercise_id, timestamp, lat, lon, speed) values(?,?,?,?,?)",@(exercise_id),@(gpsData.timestamp),@(gpsData.latitude), @(gpsData.longitude),@(gpsData.speed)];
}

- (BOOL)saveHeartData:(DMHeartData*)heartData forExercise:(NSUInteger)exercise_id
{
    return [self.db executeUpdate:@"insert into heart_data (exercise_id, timestamp, length) values(?,?,?)",@(exercise_id),@(heartData.timestamp),@(heartData.heartRate)];
}

@end
