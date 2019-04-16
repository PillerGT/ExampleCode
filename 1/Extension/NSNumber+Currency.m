//
//  NSNumber+Currency.m
//  PayForPrint
//
//  Created by Alexander Kovalov on 01.11.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "NSNumber+Currency.h"

@implementation NSNumber (Currency)

- (NSString *)numberToCurrencyString {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setCurrencySymbol:@"$"];
    return [formatter stringFromNumber:self];
}

@end
