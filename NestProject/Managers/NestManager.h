//
//  NestManager.h
//  NestProject
//
//  Created by Yurii Balashkevych on 11/13/17.
//  Copyright © 2017 Yurii Balashkevych. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Thermostat.h"

@protocol NestManagerDelegate

- (void)thermostatsUpdated:(NSArray <Thermostat *> *)thermostats;

@end

@interface NestManager : NSObject

@property (nonatomic, strong, readonly) NSArray <Thermostat *> *thermostats;
@property (nonatomic, strong, readonly) CLLocation *homeLocation;
@property (nonatomic, weak) id <NestManagerDelegate> delegate;

+ (instancetype)sharedManager;

- (void)loadThermostats:(void (^)(NSArray <Thermostat*> *response))callback;

@end
