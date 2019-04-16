//
//  PPButtonCell.h
//  PayForPrint
//
//  Created by Alexander Kovalov on 13.08.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPProfileModelView.h"

@class PPProfileModelView;
@protocol PPButtonCellDelegate;

@interface PPButtonCell : UITableViewCell

@property (weak, nonatomic)id<PPButtonCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *bigButton;
@property TypeSettingCell typeCell;

-(void)configureCell:(PPProfileModelView *)modelView;

@end




@protocol PPButtonCellDelegate <NSObject>
- (void)tapAboutButton;
- (void)tapContactButton;
- (void)tapSecretButton;
@end
