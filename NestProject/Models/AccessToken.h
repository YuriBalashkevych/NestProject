//
//  AccessToken.h
//  NestProject
//
//  Created by Yurii Balashkevych on 11/12/17.
//  Copyright © 2017 Yurii Balashkevych. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccessToken : NSObject

@property (nonatomic, copy) NSString *token;
@property (nonatomic, strong) NSDate *expirationDate;

- (instancetype)initWithInfo:(NSDictionary *)info;

//TODO: Apply logic for access token expiration flow
- (BOOL)isValid;

@end
