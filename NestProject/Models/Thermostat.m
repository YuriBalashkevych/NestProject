//
//  Thermostat.m
//  NestProject
//
//  Created by Yurii Balashkevych on 11/13/17.
//  Copyright © 2017 Yurii Balashkevych. All rights reserved.
//

#import "Thermostat.h"
#import "Constants.h"
#import "NestManager.h"
#import "NetworkManager.h"

NSString * const CURRENT_T_KEY = @"ambient_temperature_c";
NSString * const TARGET_T_KEY = @"target_temperature_c";

@interface Thermostat()

@property (nonatomic, assign, readwrite) NSInteger currentTemperatureC;
@property (nonatomic, assign, readwrite) NSInteger targetTemperatureC;

@end

@implementation Thermostat

- (instancetype)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        self.deviceID = info.allKeys.firstObject;
        self.currentTemperatureC = [info[self.deviceID][CURRENT_T_KEY] integerValue];
        self.targetTemperatureC = [info[self.deviceID][TARGET_T_KEY] integerValue];
    }
    return self;
}

- (void)setNewTargetTemperatureC:(NSInteger)temp {
    
    NSNumber *temperature = @(temp);
    NSDictionary *params = @{TARGET_T_KEY : temperature };
    
    [[NetworkManager sharedManager] putDataTo:[NSString stringWithFormat:@"%@/%@/", THERMOSTATS, self.deviceID] withParams:params success:^(NSDictionary *response) {
        [[NestManager sharedManager] loadThermostats:nil];
    } redirect:^(NSHTTPURLResponse *responseURL) {
        [[NetworkManager sharedManager] handlePUTRedirectTo:responseURL.URL.absoluteString
                                                 withParams:params success:^(NSDictionary *response) {
                                                     [[NestManager sharedManager] loadThermostats:nil];
                                                 } failure:^(NSError *error) {
                                                     NSLog(@"%@", error.localizedDescription);
                                                 }];
    } failure:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];

}

@end
