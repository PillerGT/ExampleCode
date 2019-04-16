//
//  PPJobExpandCell.m
//  PayForPrint
//
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPJobExpandCell.h"
#import "PPJobModelView.h"

@interface PPJobExpandCell()

@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIImageView *statusFileImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusDescriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *numberPagesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberDocumentLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingTimeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *expireImageView;
@property (weak, nonatomic) IBOutlet UIButton *rightBottomButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthPageConstraint;

@end

@implementation PPJobExpandCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteDocumentAction:(UIButton *)sender {
    if (self.modelView.job && [self.delegate respondsToSelector:@selector(cellJobDelete:)]) {
        [self.delegate cellJobDelete:self];
    }
}

- (void)configureCell:(PPJobModelView *)jobModel {
    self.modelView = jobModel;
    
    self.typeFileImageView.image = self.modelView.fileTypeImage;
    self.nameFileLabel.text = self.modelView.fileName;
    self.typeFileLabel.text = self.modelView.fileType;
    self.createDateLabel.text = self.modelView.releaseCode;//uploadedTimestamp;
    
    self.statusFileImageView.image = self.modelView.statusImage;
    self.statusDescriptionLabel.text = self.modelView.statusText;
    self.statusDescriptionLabel.textColor = self.modelView.statusTextColor;
    
    self.numberPagesLabel.text = self.modelView.numPages;
    self.numberDocumentLabel.text = self.modelView.uploadedTimestamp;
    self.remainingTimeLabel.text = self.modelView.expiry;
    
    self.headerView.backgroundColor = self.modelView.headerBackgroundColor;
    self.nameFileLabel.textColor = self.modelView.headerTextColor;
    self.typeFileLabel.textColor = self.modelView.headerTextColor;
    self.createDateLabel.textColor = self.modelView.headerTextColor;
    self.moreInfoButton.image = self.modelView.moreInfoButtonImage;
    self.typeFileImageView.image = self.modelView.fileTypeImage;
    
    self.expireImageView.hidden = self.modelView.historyJob;
    [self.rightBottomButton setImage:self.modelView.rightBottomButtonImage forState:UIControlStateNormal];
    self.widthPageConstraint.constant = self.modelView.widthPagesCopiesConstraint;
}

@end
