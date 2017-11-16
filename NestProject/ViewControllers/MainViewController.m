//
//  MainViewController.m
//  NestProject
//
//  Created by Yurii Balashkevych on 11/12/17.
//  Copyright © 2017 Yurii Balashkevych. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "AuthViewController.h"
#import "MainViewController.h"
#import "NetworkManager.h"
#import "NestManager.h"

NSUInteger const MIN_DISTANCE_FOR_SAVEMODE  = 1000;
NSUInteger const TEMPERATURE_FOR_SAVEMODE   = 10;
NSUInteger const NORMAL_TEMPERATURE         = 23;

@interface MainViewController () <NestManagerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *currentTemperature;
@property (weak, nonatomic) IBOutlet UILabel *targetTemperature;
@property (weak, nonatomic) IBOutlet UISlider *temperatureSlider;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL automaticMode;

@end

@implementation MainViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

#pragma NestManagerDelegate

- (void)thermostatsUpdated:(NSArray<Thermostat *> *)thermostats {
    [self.activityIndicatorView stopAnimating];
    self.view.userInteractionEnabled = YES;
    
    Thermostat *thermostat = [thermostats firstObject];
    self.currentTemperature.text = [NSString stringWithFormat:@"%ld°C", (long)thermostat.currentTemperatureC];
    self.targetTemperature.text = [NSString stringWithFormat:@"%ld°C", (NSInteger)thermostat.targetTemperatureC];
    self.temperatureSlider.value = (NSInteger)thermostat.targetTemperatureC;
}

#pragma mark - WebViewResponseDelegate

- (void)pinCodeReceived:(NSString *)pinCode {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NetworkManager sharedManager] authorizeNestWithCode:pinCode success:^(NSDictionary *response) {
        [[NestManager sharedManager] loadThermostats:nil];
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {    
    NSLog(@"didUpdateToLocation: %@", newLocation);
    if (!self.automaticMode || [newLocation distanceFromLocation:oldLocation] < 1000) {
        return;
    }
    [self setTemperatureAutomaticallyForLocation:newLocation];
}

#pragma mark - Actions

- (IBAction)sliderValueChanged:(UISlider *)sender {
    self.targetTemperature.text = [NSString stringWithFormat:@"%d°C", (int)sender.value];
}

- (IBAction)sliderEditingDidEnd:(UISlider *)sender {
    Thermostat *t = [[[NestManager sharedManager] thermostats] firstObject];
    [t setNewTargetTemperatureC:(NSInteger)sender.value];
}

- (IBAction)automaticSwitch:(UISwitch *)sender {
    self.automaticMode = sender.isOn;
    
    if (self.automaticMode) {
        CLLocation *currentLocation = self.locationManager.location;
        [self setTemperatureAutomaticallyForLocation:currentLocation];
    }
}

#pragma mark - Private

- (void)setup {
    [NestManager sharedManager].delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    if (![[NetworkManager sharedManager] isAuthorized]) {
        UIStoryboard *st = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AuthViewController *vc = [st instantiateViewControllerWithIdentifier:NSStringFromClass([AuthViewController class])];
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)enterEnergySaveMode {
    Thermostat *t = [[[NestManager sharedManager] thermostats] firstObject];
    [t setNewTargetTemperatureC:TEMPERATURE_FOR_SAVEMODE];
}

- (void)exitEnergySaveMode {
    Thermostat *t = [[[NestManager sharedManager] thermostats] firstObject];
    [t setNewTargetTemperatureC:NORMAL_TEMPERATURE];
}

- (void)setTemperatureAutomaticallyForLocation:(CLLocation *)location {
    CLLocationDistance distance = [location distanceFromLocation:[[NestManager sharedManager] homeLocation]];
    if (distance > MIN_DISTANCE_FOR_SAVEMODE) {
        [self enterEnergySaveMode];
    } else if (self.automaticMode){
        [self exitEnergySaveMode];
    }
}

@end







