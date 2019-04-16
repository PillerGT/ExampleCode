//
//  EmptyScreenView.h
//  PayForPrint
//
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TypeEmpty){
    TypeEmptyPending = 0,
    TypeEmptyHistory,
    TypeEmptyTransaction,
    TypeEmptyLocation
};

@interface PPEmptyScreenView : UIView

+ (PPEmptyScreenView *)viewFromNibTypeEmpty:(TypeEmpty)typeEmpty;

@end
