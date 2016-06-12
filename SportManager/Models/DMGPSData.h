//
//  DMGPSData.h
//  SportManager
//
//  Created by Darya on 30/04/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMGPSData : NSObject

@property (nonatomic, assign) int oid;
@property (nonatomic, assign) double timestamp;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double speed;

@end
