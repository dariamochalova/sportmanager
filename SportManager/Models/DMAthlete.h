//
//  DMAthlete.h
//  SportManager
//
//  Created by Darya on 30/04/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMAthlete : NSObject

@property (nonatomic, assign) int oid;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, assign) float weight;
@property (nonatomic, assign) int age;

@end
