//
//  NetworkManager.h
//  NestProject
//
//  Created by Yurii Balashkevych on 11/12/17.
//  Copyright © 2017 Yurii Balashkevych. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

@property (nonatomic, readonly, copy) NSString *baseURL;


+ (instancetype)sharedManager;

- (void)authorizeNestWithCode:(NSString *)code
                      success:(void (^)(NSDictionary *response))success;
;

- (BOOL)isAuthorized;

// get requests
- (void)getDataFrom:(NSString *)url
         withParams:(NSDictionary *)params
            success:(void (^)(NSDictionary *response))success
           redirect:(void (^)(NSHTTPURLResponse *responseURL))redirect
            failure:(void (^)(NSError* error))failure;

- (void)handleGETRedirectTo:(NSString *)url
                    success:(void (^)(NSDictionary *response))success
                    failure:(void (^)(NSError* error))failure;

//post requests
- (void)putDataTo:(NSString *)url
        withParams:(NSDictionary *)params
           success:(void (^)(NSDictionary *response))success
          redirect:(void (^)(NSHTTPURLResponse *responseURL))redirect
           failure:(void (^)(NSError* error))failure;

- (void)handlePUTRedirectTo:(NSString *)url
                 withParams:(NSDictionary *)params
                    success:(void (^)(NSDictionary *response))success
                    failure:(void (^)(NSError* error))failure;

//building request
- (NSMutableURLRequest *)buildRequestFor:(NSString *)type
                                   toURL:(NSString *)url
                              withParams:(NSDictionary *)params;

@end

