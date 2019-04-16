//
//  PPDatePickerView.h
//  PayForPrint
//
//  Created by Alexander Kovalov on 09.07.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPDatePickerView : UIView

@property (weak, nonatomic) IBOutlet UIView *toolbarAndDateView;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;

+ (void)showDateView:(NSDate *)date doneButtonCompletionBlock:(void(^)(NSDate *date))doneButtonCompletionBlock;

@end
