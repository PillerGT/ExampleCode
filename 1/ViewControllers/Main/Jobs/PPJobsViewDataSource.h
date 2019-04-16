//
//  PPJobsViewDataSource.h
//  PayForPrint
//
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PPJobsViewDataSourceDelegate, PPJobCellDelegate;

@interface PPJobsViewDataSource : NSObject <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (assign, nonatomic)BOOL isPendingJob;
@property (assign, nonatomic)BOOL isShowSearch;

- (instancetype)initWithDelegate:(id<PPJobsViewDataSourceDelegate, PPJobCellDelegate>)delegate;
- (void)reload;
- (void)changeVisibleArray;
- (void)cellExpandIndexPath:(NSIndexPath *)indexPath;
- (void)cellDeleteJobIndexPath:(NSIndexPath *)indexPath;

@end


@protocol PPJobsViewDataSourceDelegate <NSObject>
- (void)shouldReloadTableViewWithEmpty:(BOOL)isShowEmpty;
- (void)changeSearchTextInSearchBar:(NSString *)searchText;
@end
