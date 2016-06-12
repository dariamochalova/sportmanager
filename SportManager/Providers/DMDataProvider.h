//
//  DMDataProvider.h
//  SportManager
//
//  Created by Darya on 30/04/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DMDataProvider <NSObject>

@property (nonatomic, assign, readonly) BOOL running;

- (void)initialize;
- (void)start;
- (void)stop;

@end
