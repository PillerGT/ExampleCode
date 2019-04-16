//
//  PPLocation.m
//  PayForPrint
//
//  Created by Alexander Kovalov on 22.11.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPLocation.h"
#import <CoreLocation/CoreLocation.h>

static id shared = nil;

@interface PPLocation()<CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@end

@implementation PPLocation

+ (instancetype)sharedClient {
    if (!shared) {
        shared = [[self alloc] init];
    }
    return shared;
}

- (void)startLocationWithDelegate:(id)delegate {
    self.delegate = delegate;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestWhenInUseAuthorization];
        }else if (status == kCLAuthorizationStatusDenied) {
            [self locationServicesAuthorizationStatusDenied];
        }
    }else {
        NSLog(@"locationServices disenabled");
    }
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"%@", locations);
    self.currentLocation = locations.lastObject;
    [self.locationManager stopUpdatingLocation];
    [self stopSearchCoordinateLocation];
}

- (void)removeLocationManager {
    shared = nil;
}

- (void)locationServicesAuthorizationStatusDenied {
    if ([self.delegate respondsToSelector:@selector(locationAuthorizationStatusDenied)]) {
        [self.delegate locationAuthorizationStatusDenied];
    }
}

- (void)stopSearchCoordinateLocation {
    if ([self.delegate respondsToSelector:@selector(locationStopSearchCoordinateLatitude:longitude:)]) {
        NSNumber *lat = [NSNumber numberWithDouble:self.currentLocation.coordinate.latitude];//@40.7881783;
        NSNumber *lon = [NSNumber numberWithDouble:self.currentLocation.coordinate.longitude];//@-74.084258;
        [self.delegate locationStopSearchCoordinateLatitude:lat longitude:lon];
    }
}

@end
