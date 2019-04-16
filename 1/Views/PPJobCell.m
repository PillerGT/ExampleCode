//
//  PPJobCell.m
//  PayForPrint
//
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPJobCell.h"
#import "PPJobModelView.h"

@interface PPJobCell()



@end

@implementation PPJobCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addTapToViewHeader];
    [self addedShadow];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)configureCell:(PPJobModelView *)jobModel {
    self.modelView = jobModel;
    
    self.typeFileImageView.image = self.modelView.fileTypeImage;
    self.nameFileLabel.text = self.modelView.fileName;
    self.typeFileLabel.text = self.modelView.fileType;
    self.createDateLabel.text = self.modelView.releaseCode;
    
    self.headerView.backgroundColor = self.modelView.headerBackgroundColor;
    self.nameFileLabel.textColor = self.modelView.headerTextColor;
    self.typeFileLabel.textColor = self.modelView.headerTextColor;
    self.createDateLabel.textColor = self.modelView.headerTextColor;
    self.moreInfoButton.image = self.modelView.moreInfoButtonImage;
    self.typeFileImageView.image = self.modelView.fileTypeImage;
}

- (void)addTapToViewHeader {
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMore)];
    [self.headerView addGestureRecognizer:gesture];
}

- (void)tapMore {
    if ([self.delegate respondsToSelector:@selector(cellExpand:)]) {
        [self.delegate cellExpand:self];
    }
}

- (void)addedShadow {
    CALayer *layer = self.baseView.layer;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.5;
    layer.shadowOffset = CGSizeMake(0, 2);
    layer.shadowRadius = 2;
    layer.masksToBounds = NO;
}

@end
