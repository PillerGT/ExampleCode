//
//  NSNumber+Date.m
//  PayForPrint
//
//  Created by Alexander Kovalov on 27.06.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "NSNumber+Date.h"

@implementation NSNumber (Date)

+ (NSNumber *)timeStampFromString:(NSString *)timeStampInString {
    NSString *str = timeStampInString;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *date = [dateFormatter dateFromString:str];
    NSNumber *timeStamp = [NSNumber numberWithDouble:[date timeIntervalSinceReferenceDate]];
    return timeStamp;
}

- (NSString *)convertToDate {
    double timeStamp = self.doubleValue;
    NSTimeInterval timeInterval = timeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"M/dd/yyyy"];
    return [dateformatter stringFromDate:date];
}

- (NSString *)convertToExpireDate {
    NSInteger timeStamp = self.integerValue / 1000;
    int second = 1;
    int minute = second * 60;
    int hour = minute * 60;
    int day = hour * 24;
    NSInteger minutes = (timeStamp / minute) % 60;
    NSInteger hours = (timeStamp / hour) % 24 ;
    NSInteger days = (timeStamp / day);
    return [NSString stringWithFormat:@"%02lid %02lih %02lim", days, hours, minutes];
}

- (NSString *)convertToTransactionDate {
    double timeStamp = self.doubleValue;
    NSTimeInterval timeInterval = timeStamp/1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"M/dd/yyyy h:mm a"];
    return [dateformatter stringFromDate:date];
}

- (NSString *)convertToSelectDate {
    double timeStamp = self.doubleValue;
    NSTimeInterval timeInterval = timeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"MMM d, yyyy"];
    return [dateformatter stringFromDate:date];
}

+ (NSNumber *)convertDateToNumber:(NSDate *)date {
    if (date == nil) {
        return [NSNumber numberWithInteger:0];
    }
    NSTimeInterval interval = [date timeIntervalSince1970];
    interval = interval * 1000;
    NSNumber *dateNumber = [NSNumber numberWithDouble:interval];
    return dateNumber;
}

@end
