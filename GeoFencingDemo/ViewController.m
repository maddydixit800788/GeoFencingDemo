//
//  ViewController.m
//  GeoFencingDemo
//
//  Created by Madhav on 18/07/19.
//  Copyright © 2019 Madhav. All rights reserved.
//

#import "ViewController.h"
@import CoreLocation;

@interface RegionDelegate : NSObject<CLLocationManagerDelegate>

@end

@interface ViewController () {
    BOOL isStart;
    CLLocationManager *locationManager;
    CLCircularRegion *circularRegion;
    RegionDelegate *regionDelegate;
}

@property (weak, nonatomic) IBOutlet UIButton *btnStart;

@end

@implementation RegionDelegate

-(void)showAlert:(NSString *)title Message:(NSString *)message {
    NSLog(@"Show alert With title : %@ AND Message : %@",title,message);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    id rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        rootViewController = [((UINavigationController *)rootViewController).viewControllers objectAtIndex:0];
    }
    
    [rootViewController presentViewController:alert animated:YES completion:nil];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(nonnull CLRegion *)region {
    NSLog(@"Entering ...");
    if ([[region identifier] isEqualToString:@"CircularRegion"]) {
        [self showAlert:@"Entering" Message:@"You are now CircularRegion"];
    }
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Exiting ...");
    if ([[region identifier] isEqualToString:@"CircularRegion"]) {
        [self showAlert:@"Exiting" Message:@"You left from CircularRegion"];
    }
}

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    isStart = NO;
    self.btnStart.backgroundColor = UIColor.orangeColor;
    self.btnStart.layer.cornerRadius = self.btnStart.frame.size.height/2;
    
    locationManager = [[CLLocationManager alloc] init];
    regionDelegate = [[RegionDelegate alloc] init];
    
    [locationManager requestAlwaysAuthorization];
}

- (IBAction)btnStart:(UIButton *)sender {
    
    if (isStart) {
        [UIView animateWithDuration:1.0 animations:^{
            [self.btnStart setTitle:@"Start" forState:UIControlStateNormal];
            self.btnStart.backgroundColor = [UIColor orangeColor];
            [self.btnStart setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self StopGeoFencing];
            NSLog(@"Done Animation Stoped");
        }];
    } else {
        [UIView animateWithDuration:1.0 animations:^{
            [self.btnStart setTitle:@"Stop" forState:UIControlStateNormal];
            [self.btnStart setBackgroundColor:[UIColor darkGrayColor]];
            [self.btnStart setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self StartGeoFencing];
            NSLog(@"Done Animation Started");
        }];
    }
    
    isStart = !isStart;
}

-(void)StartGeoFencing {
    NSLog(@"Start GeoFencing....");
    
    BOOL monitoringAvailable = [CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]];
    BOOL monitoringAuthorized = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways;
    
    if (!monitoringAvailable || !monitoringAuthorized) {
        NSLog(@"Access Not Grant");
        [regionDelegate showAlert:@"Something went wrong" Message:@"Location Access not Granted."];
    } else {
        CLLocationDegrees latitude = 37.530439;
        CLLocationDegrees longitude = -122.264483;
        CLLocationDistance radius = 1000;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        circularRegion = [[CLCircularRegion alloc] initWithCenter:coordinate radius:radius identifier:@"CircularRegion"];
        circularRegion.notifyOnExit = YES;
        circularRegion.notifyOnEntry = YES;
        
        locationManager.delegate = regionDelegate;
        [locationManager startMonitoringForRegion:circularRegion];
    }
}

-(void)StopGeoFencing {
    [locationManager stopMonitoringForRegion:circularRegion];
}

@end
