//
//  NSUserDefaults+PPUserDefaults.m
//  PayForPrint
//
//  Created by Alexander Kovalov on 30.10.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "NSUserDefaults+PPUserDefaults.h"

@implementation NSUserDefaults (PPUserDefaults)

+(instancetype)ppUserDefaults
{
    static dispatch_once_t onceToken;
    static NSUserDefaults *defaults = nil;
    dispatch_once(&onceToken, ^{
        defaults = [[NSUserDefaults alloc] initWithSuiteName:kPPCampusDefaultsKey];
    });
    return defaults;
}

@end
