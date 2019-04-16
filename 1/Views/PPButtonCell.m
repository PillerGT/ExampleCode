//
//  PPButtonCell.m
//  PayForPrint
//
//  Created by Alexander Kovalov on 13.08.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPButtonCell.h"

@implementation PPButtonCell

-(void)configureCell:(PPProfileModelView *)modelView {
    self.separatorInset = UIEdgeInsetsZero;
    self.typeCell = modelView.typeCell;
    [self.bigButton setTitle:modelView.titleText forState:UIControlStateNormal];
}

- (IBAction)tapButton:(id)sender {
    if (self.typeCell == TypeSettingAbout) {
        if ([self.delegate respondsToSelector:@selector(tapAboutButton)]) {
            [self.delegate tapAboutButton];
        }
    }else if (self.typeCell == TypeSettingContact) {
        if ([self.delegate respondsToSelector:@selector(tapContactButton)]) {
            [self.delegate tapContactButton];
        }
    }else if (self.typeCell == TypeSettingSecret) {
        if ([self.delegate respondsToSelector:@selector(tapSecretButton)]) {
            [self.delegate tapSecretButton];
        }
    }
}

@end
