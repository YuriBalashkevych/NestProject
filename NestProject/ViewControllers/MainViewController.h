//
//  MainViewController.h
//  NestProject
//
//  Created by Yurii Balashkevych on 11/12/17.
//  Copyright © 2017 Yurii Balashkevych. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WebViewResponseDelegate <NSObject>

- (void)pinCodeReceived:(NSString *)pinCode;

@end

@interface MainViewController : UIViewController <WebViewResponseDelegate>

@end
