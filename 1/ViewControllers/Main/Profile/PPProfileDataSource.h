//
//  PPProfileDataSource.h
//  PayForPrint
//
//  Created by Alexander Kovalov on 11.07.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PPProfileDataSourceDelegate, PPProviderLinkCellDelegate, PPButtonCellDelegate, PPUserNameCellDelegate;
@class PPProfileModelView, PPProviderLinkCell, PPButtonCell, PPUserNameCell;

@interface PPProfileDataSource : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (assign, nonatomic) BOOL isShowSecret;

- (instancetype)initWithDelegate:(id<PPProfileDataSourceDelegate, PPProviderLinkCellDelegate, PPButtonCellDelegate, PPUserNameCellDelegate>)delegate;
- (void)reload;

@end

@protocol PPProfileDataSourceDelegate <NSObject>
-(void)shouldReloadTableView;
-(void)logOutUser;
-(void)tapProfile;
-(void)tapTransaction;
@end
