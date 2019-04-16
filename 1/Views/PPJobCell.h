//
//  PPJobCell.h
//  PayForPrint
//
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PPJobModelView;
@protocol PPJobCellDelegate;

@interface PPJobCell : UITableViewCell

@property (weak, nonatomic) id<PPJobCellDelegate> delegate;

@property (strong, nonatomic)PPJobModelView *modelView;

@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIImageView *typeFileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameFileLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeFileLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *moreInfoButton;

- (void)configureCell:(PPJobModelView *)jobModel;

@end

@protocol PPJobCellDelegate <NSObject>
-(void)cellJobDelete:(PPJobCell *)cell;
-(void)cellExpand:(PPJobCell *) cell;
@end
