//
//  AccessToken.m
//  NestProject
//
//  Created by Yurii Balashkevych on 11/12/17.
//  Copyright © 2017 Yurii Balashkevych. All rights reserved.
//

#import "AccessToken.h"

@implementation AccessToken

- (instancetype)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        NSTimeInterval expiresIn = [[info objectForKey:@"expires_in"] longValue];
        NSString *accessToken = [info objectForKey:@"access_token"];
        self.expirationDate = [NSDate dateWithTimeIntervalSinceNow:expiresIn];
        self.token = accessToken;
    }
    
    return self;
}

- (BOOL)isValid {
    return [self.expirationDate compare:[NSDate date]] == NSOrderedAscending;
}

@end
