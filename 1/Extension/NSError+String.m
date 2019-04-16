//
//  NSError+String.m
//  PayForPrint
//
//  Created by Alexander Kovalov on 31.08.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "NSError+String.h"
#import "AFNetworking.h"

@implementation NSError (String)

- (NSString *)responceErrorData {
    NSData *dataError = self.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (dataError.length == 0) {
        return @"";
    }
    return [[NSString alloc] initWithData:dataError encoding:NSUTF8StringEncoding];
}

@end
