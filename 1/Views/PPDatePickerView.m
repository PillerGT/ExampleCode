//
//  PPDatePickerView.m
//  PayForPrint
//
//  Created by Alexander Kovalov on 09.07.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPDatePickerView.h"

@interface PPDatePickerView()

@property (strong, nonatomic) void(^doneButtonActionBlock)(NSDate *date);

@end

@implementation PPDatePickerView

+ (void)showDateView:(NSDate *)date doneButtonCompletionBlock:(void(^)(NSDate *date))doneButtonCompletionBlock {
    PPDatePickerView *dateView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PPDatePickerView class]) owner:self options:nil].firstObject;
    dateView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    dateView.doneButtonActionBlock = doneButtonCompletionBlock;
    dateView.alpha = 0;
    dateView.datePicker.maximumDate = [NSDate date];
    dateView.datePicker.date = (date == nil) ? [NSDate date] : date;
    UIView *viewWithBackground = [dateView addBackroudViewWithGrayColor];
    [[UIApplication sharedApplication].keyWindow addSubview:viewWithBackground];
    
    [UIView animateWithDuration:0.3 animations: ^{
        dateView.alpha = 1.0f;
    }];
}

#pragma mark - Configurating Views

- (UIView *)addBackroudViewWithGrayColor {
    UIView *backgroudGrayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelTap:)];
    [backgroudGrayView addGestureRecognizer:tap];
    backgroudGrayView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.25];
    [backgroudGrayView addSubview:self];
    self.center = backgroudGrayView.center;
    return backgroudGrayView;
}

- (IBAction)cancelTap:(UIBarButtonItem *)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self.superview removeFromSuperview];
    }];
}

- (IBAction)doneTap:(UIBarButtonItem *)sender {
    self.doneButtonActionBlock(self.datePicker.date);
    [self cancelTap:nil];
}

@end
