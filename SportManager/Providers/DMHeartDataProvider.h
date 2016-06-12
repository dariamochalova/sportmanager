//
//  DMHeartDataProvider.h
//  SportManager
//
//  Created by Darya on 30/04/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMDataProvider.h"

@protocol DMHeartDataProviderDelegate <NSObject>

- (void)heartDataReceived:(DMHeartData *)heartData;

@end

@interface DMHeartDataProvider : NSObject <DMDataProvider>

@property (nonatomic, weak) id<DMHeartDataProviderDelegate> delegate;


@end
