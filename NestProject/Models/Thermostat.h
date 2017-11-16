//
//  Thermostat.h
//  NestProject
//
//  Created by Yurii Balashkevych on 11/13/17.
//  Copyright © 2017 Yurii Balashkevych. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Thermostat : NSObject

//Thermostat has much more properties but we show a basic functionality here
@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, assign, readonly) NSInteger currentTemperatureC;
@property (nonatomic, assign, readonly) NSInteger targetTemperatureC;

- (instancetype)initWithInfo:(NSDictionary *)info;

- (void)setNewTargetTemperatureC:(NSInteger)temp;

@end
