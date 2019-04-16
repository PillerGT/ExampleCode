//
//  NSNumber+Date.h
//  PayForPrint
//
//  Created by Alexander Kovalov on 27.06.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Date)

- (NSString *)convertToDate;
- (NSString *)convertToExpireDate;
- (NSString *)convertToTransactionDate;
- (NSString *)convertToSelectDate;

+ (NSNumber *)convertDateToNumber:(NSDate *)date;
+ (NSNumber *)timeStampFromString:(NSString *)timestampInString;

@end
