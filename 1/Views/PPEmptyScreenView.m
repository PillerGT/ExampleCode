//
//  EmptyScreenView.m
//  PayForPrint
//
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPEmptyScreenView.h"

@interface PPEmptyScreenView()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@end

@implementation PPEmptyScreenView

+ (NSString *)nibName {
    return NSStringFromClass([self class]);
}

+ (PPEmptyScreenView *)viewFromNibTypeEmpty:(TypeEmpty)typeEmpty {
    
    PPEmptyScreenView *view = [[[NSBundle mainBundle] loadNibNamed:[PPEmptyScreenView nibName] owner:self options:nil] firstObject];
    switch (typeEmpty) {
        case TypeEmptyPending:
            view.descriptionLabel.text = @"You have no pending job. Pull down to refresh.";
            break;
        case TypeEmptyHistory:
            view.descriptionLabel.text = @"You have no print history, pull down to refresh.";
            break;
        case TypeEmptyTransaction:
            view.descriptionLabel.text = @"No transactions were found. Pull down to refresh.";
            break;
        case TypeEmptyLocation:
            view.descriptionLabel.text = @"There aren't any nearest locations.";
            break;
        default:
            break;
    }
    view.translatesAutoresizingMaskIntoConstraints = YES;
    return view;
}

@end
