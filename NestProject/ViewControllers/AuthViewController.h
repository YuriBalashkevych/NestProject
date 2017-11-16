//
//  AuthViewController.h
//  NestProject
//
//  Created by Yurii Balashkevych on 11/12/17.
//  Copyright © 2017 Yurii Balashkevych. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "MainViewController.h"

@interface AuthViewController : UIViewController <WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) id <WebViewResponseDelegate> delegate;

@end
