//
//  PPLocation.h
//  PayForPrint
//
//  Created by Alexander Kovalov on 22.11.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PPLocationDelegate;

@interface PPLocation : NSObject
@property (weak, nonatomic) id<PPLocationDelegate> delegate;

+ (instancetype)sharedClient;
- (void)startLocationWithDelegate:(id)delegate;
- (void)removeLocationManager;

@end


@protocol PPLocationDelegate<NSObject>
@optional
-(void)locationAuthorizationStatusDenied;
-(void)locationStopSearchCoordinateLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude;
@end
