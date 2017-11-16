//
//  NetworkManager.m
//  NestProject
//
//  Created by Yurii Balashkevych on 11/12/17.
//  Copyright © 2017 Yurii Balashkevych. All rights reserved.
//

#import "NetworkManager.h"
#import "AccessToken.h"
#import "Constants.h"

@interface NetworkManager()

@property (nonatomic, strong) AccessToken *accessToken;

@end

@implementation NetworkManager

#pragma mark - Initialization

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static NetworkManager *instance;
    
    dispatch_once(&once, ^{
        instance = [[NetworkManager alloc] init];
    });
    
    return instance;
}

#pragma mark - Nest Authorization

- (void)authorizeNestWithCode:(NSString *)code
                      success:(void (^)(NSDictionary *response))success {
    NSString *urlString = [NSString stringWithFormat:@"%@?code=%@&client_id=%@&client_secret=%@&grant_type=authorization_code", AUTH_URL, code, CLIENT_ID, CLIENT_SECRET];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setValue:@"x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
          if (error) {
              NSLog(@"%@", error.localizedDescription);
          } else {
              NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:NSJSONReadingAllowFragments
                                                                            error:nil];
              AccessToken *token = [[AccessToken alloc] initWithInfo:responseJSON];
              self.accessToken = token;
              if (success) {
                  success(responseJSON);
              }
          }
      }] resume];
}

- (BOOL)isAuthorized {
    return [self.accessToken isValid];
}

#pragma mark - GET requests

- (void)getDataFrom:(NSString *)url
         withParams:(NSDictionary *)params
            success:(void (^)(NSDictionary *response))success
           redirect:(void (^)(NSHTTPURLResponse *responseURL))redirect
            failure:(void (^)(NSError* error))failure {
    
    NSString *targetUrl = [NSString stringWithFormat:@"%@/%@", self.baseURL, url];
    NSMutableURLRequest *request = [self buildRequestFor:@"GET"
                                            toURL:targetUrl
                                        withParams:params];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
          
          NSHTTPURLResponse *resp = (NSHTTPURLResponse *) response;
          if ([self isRedirect:resp]) {
              redirect(resp);
          } else if (error && failure) {
              failure(error);
          } else {
              NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:NSJSONReadingAllowFragments
                                                                             error:nil];
              if (success) {
                  success(responseJSON);
              }
          }
          
      }] resume];
}

- (void)handleGETRedirectTo:(NSString *)url
                    success:(void (^)(NSDictionary *response))success
                    failure:(void (^)(NSError* error))failure {
    
    NSMutableURLRequest *request = [self buildRequestFor:@"GET"
                                            toURL:url
                                        withParams:nil];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    
                    if (error)
                        failure(error);
                    else {
                        NSDictionary *requestJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:nil];
                        success(requestJSON);
                    }
                    
                }] resume];
}

- (NSMutableURLRequest *)buildRequestFor:(NSString *)type
                            toURL:(NSString *)url
                        withParams:(NSDictionary *)params
{
    NSString *token = [NSString stringWithFormat:@"Bearer %@",
                            self.accessToken.token];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:type];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setURL:[NSURL URLWithString:url]];
    
    if (params) {
        NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        [request setHTTPBody:postData];
    }
    
    return request;
}

#pragma mark - POST requests

- (void)putDataTo:(NSString *)url
       withParams:(NSDictionary *)params
          success:(void (^)(NSDictionary *response))success
         redirect:(void (^)(NSHTTPURLResponse *responseURL))redirect
          failure:(void (^)(NSError* error))failure {

    NSString *targetUrl = [NSString stringWithFormat:@"%@/%@", self.baseURL, url];
    NSMutableURLRequest *request = [self buildRequestFor:@"PUT"
                                            toURL:targetUrl
                                        withParams:params];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
          
          NSHTTPURLResponse *resp = (NSHTTPURLResponse *) response;
          
          if ([self isRedirect:resp]) {
              redirect(resp);
          } else if (error && failure) {
              failure(error);
          } else {
              NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:NSJSONReadingAllowFragments
                                                                             error:nil];
              if (success) {
                  success(responseJSON);
              }
          }

      }] resume];
}

- (void)handlePUTRedirectTo:(NSString *)url
                 withParams:(NSDictionary *)params
                    success:(void (^)(NSDictionary *response))success
                    failure:(void (^)(NSError* error))failure {
    
    NSMutableURLRequest *request = [self buildRequestFor:@"PUT"
                                            toURL:url
                                        withParams:params];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (error)
                        failure(error);
                    else {
                        NSDictionary *requestJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:nil];
                        success(requestJSON);
                    }
                    
                }] resume];
    
}

#pragma mark - Lazy Initialization

- (NSString *)baseURL {
    return BASE_URL;
}

#pragma mark - Private

- (BOOL)isRedirect:(NSHTTPURLResponse *)response {
    if ([response statusCode] == 401 || [response statusCode] == 307) {
        
        NSDictionary *headers = [response allHeaderFields];
        if ([[headers objectForKey:@"Content-Length"] isEqual: @"0"]) {
            return NO;
        }
        else {
            return YES;
        }
    }
    return NO;
}

@end
