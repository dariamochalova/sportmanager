//
//  DMLocationDataProvider.h
//  SportManager
//
//  Created by Darya on 30/04/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMDataProvider.h"
#import "DMGPSData.h"

@protocol DMLocationDataProviderDelegate <NSObject>

- (void)locationReceived:(DMGPSData*)location;

@end

@interface DMLocationDataProvider : NSObject <DMDataProvider>

@property (nonatomic, weak) id<DMLocationDataProviderDelegate> delegate;

@end
