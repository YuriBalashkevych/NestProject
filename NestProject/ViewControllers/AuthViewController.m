//
//  AuthViewController.m
//  NestProject
//
//  Created by Yurii Balashkevych on 11/12/17.
//  Copyright © 2017 Yurii Balashkevych. All rights reserved.
//

#import "AuthViewController.h"
#import "Constants.h"

@interface AuthViewController ()

@end

@implementation AuthViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"request: %@", navigationAction.request);
    
    if ([navigationAction.request.URL.absoluteString hasPrefix:REDIRECT_URL]) {
        [self fetchAccessKeyFromURL:navigationAction.request.URL.absoluteString];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - Private

- (void)setup {
    self.webView.navigationDelegate = self;
    NSURL *authURL = [NSURL URLWithString:WEBVIEW_AUTH_URL];
    NSURLRequest *authRequest = [[NSURLRequest alloc] initWithURL:authURL];
    [self.webView loadRequest:authRequest];
}

//TODO: it is not safe, should handle situation when pin code don't arrive
- (void)fetchAccessKeyFromURL:(NSString *)urlString {
    NSArray *components = [urlString componentsSeparatedByString:@"="];
    NSString *authToken = [components lastObject];
    if (authToken.length) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate pinCodeReceived:authToken];
        });
    }
}

@end
