//
//  NestManager.m
//  NestProject
//
//  Created by Yurii Balashkevych on 11/13/17.
//  Copyright © 2017 Yurii Balashkevych. All rights reserved.
//

#import "Constants.h"
#import "NestManager.h"
#import "NetworkManager.h"

@interface NestManager()

@property (nonatomic, strong, readwrite) NSArray <Thermostat *> *thermostats;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation NestManager

#pragma mark - Initialization

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static NestManager *instance;
    
    dispatch_once(&once, ^{
        instance = [[NestManager alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^{
            instance.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:instance selector:@selector(loadThermostats:) userInfo:nil repeats:YES];
        });
    });
    
    return instance;
}

- (void)loadThermostats:(void (^)(NSArray <Thermostat*> *response))callback {
    
    [[NetworkManager sharedManager] getDataFrom:THERMOSTATS withParams:nil success:^(NSDictionary *response) {
        [self parseThermostatInfo:response];
    } redirect:^(NSHTTPURLResponse *responseURL) {
        [[NetworkManager sharedManager] handleGETRedirectTo:[responseURL URL].absoluteString success:^(NSDictionary *response) {
            [self parseThermostatInfo:response];
        } failure:^(NSError *error) {
            NSLog(@"%@", error.localizedDescription);
        }];
    } failure:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];

}

- (void)parseThermostatInfo:(NSDictionary *)info {
    NSMutableArray *ts = [NSMutableArray array];
    for (NSString *key in info.allKeys) {
        Thermostat *t = [[Thermostat alloc] initWithInfo:@{key : info[key]}];
        [ts addObject:t];
    }
    self.thermostats = ts;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate thermostatsUpdated:ts];
    });
}

#pragma mark - Lazy

- (CLLocation *)homeLocation {
    return [[CLLocation alloc] initWithLatitude:55.751244 longitude:37.618423];
}



@end
