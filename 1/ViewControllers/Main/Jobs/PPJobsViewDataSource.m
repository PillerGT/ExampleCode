//
//  PPJobsViewDataSource.m
//  PayForPrint
//
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPJobsViewDataSource.h"
#import "PPApiClient.h"
#import "PPPendingJobs.h"
#import "PPHistoryJobs.h"
#import "PPJobCell.h"
#import "PPJobExpandCell.h"
#import "PPJobModelView.h"
#import "PPEmptyScreenView.h"
#import "PPJobHeaderView.h"

static NSString *identifierCell = @"jobCell";
static NSString *identifierExpandCell = @"jobExpandCell";

@interface PPJobsViewDataSource()

@property (weak, nonatomic) id<PPJobsViewDataSourceDelegate, PPJobCellDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *dataJobArray;
@property (strong, nonatomic) NSMutableArray *dataHistoryArray;

@property (strong, nonatomic) NSString* jobSearchText;
@property (strong, nonatomic) NSString* historySearchText;

@end

@implementation PPJobsViewDataSource

- (instancetype)initWithDelegate:(id<PPJobsViewDataSourceDelegate, PPJobCellDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.isPendingJob = YES;
        self.isShowSearch = NO;
        self.jobSearchText = @"";
        self.historySearchText = @"";
        [self reload];
    }
    return self;
}

- (void)reload {
    __weak typeof (self) wSelf = self;
    
    if (self.isPendingJob) {
        [[PPApiClient sharedClient] getPendingJobsSuccess:^(NSArray *pendingJobs) {
            NSMutableArray *temp = [NSMutableArray new];
            for (PPPendingJobs *job in pendingJobs) {
                PPJobModelView *jobModel = [[PPJobModelView alloc] initWithJob:job];
                [temp addObject:jobModel];
            }
            wSelf.dataJobArray = [temp mutableCopy];
            wSelf.dataArray = wSelf.dataJobArray;
        } failure:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }else {
        [[PPApiClient sharedClient] getPrintHistorySuccess:^(NSArray *historyJobs) {
            NSMutableArray *temp = [NSMutableArray new];
            for (PPHistoryJobs *job in historyJobs) {
                PPJobModelView *jobModel = [[PPJobModelView alloc] initWithHistoryJob:job];
                [temp addObject:jobModel];
            }
            wSelf.dataHistoryArray = [temp mutableCopy];
            wSelf.dataArray = wSelf.dataHistoryArray;
        } failure:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}

- (void)changeVisibleArray {
    if (self.isShowSearch == YES) {
        [self changeSearchText];
        if ((self.historySearchText.length != 0 && self.dataJobArray.count != 0) || (self.jobSearchText.length != 0 && self.dataHistoryArray.count != 0)) {
            [self reloadTableViewController];
            return;
        }
    }else {
        self.historySearchText = @"";
        self.jobSearchText = @"";
        [self changeSearchText];
    }
    
    if (self.isPendingJob) {
        self.dataArray = self.dataJobArray;
    }else {
        if (self.dataHistoryArray != nil) {
            self.dataArray = self.dataHistoryArray;
        }else {
            [self reload];
        }
    }
}

- (void)changeSearchText {
    if ([self.delegate respondsToSelector:@selector(changeSearchTextInSearchBar:) ]) {
        [self.delegate changeSearchTextInSearchBar:(self.isPendingJob == YES) ? self.jobSearchText : self.historySearchText];
    }
    [self searchBar:[UISearchBar new] textDidChange:(self.isPendingJob == YES) ? self.jobSearchText : self.historySearchText];
}

- (void)cellExpandIndexPath:(NSIndexPath *)indexPath {
    PPJobModelView *viewModel = [self.dataArray objectAtIndex:indexPath.row];
    [viewModel shouldExpandViewCell];
    [self reloadTableViewController];
}

- (void)cellDeleteJobIndexPath:(NSIndexPath *)indexPath {
    PPJobModelView *viewModel = [self.dataArray objectAtIndex:indexPath.row];
    __weak typeof (self) wSelf = self;
    [[PPApiClient sharedClient] deletePrintJobID:viewModel.jobId success:^{
        for (PPJobModelView *searchModel in wSelf.dataJobArray) {
            if ([searchModel.jobId isEqualToString:viewModel.jobId]) {
                [wSelf.dataJobArray removeObjectAtIndex:indexPath.row];
                wSelf.dataArray = wSelf.dataJobArray;
                return;
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.dataArray.count > 0) {
        return 1;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *name = NSStringFromClass([PPJobHeaderView class]);
    PPJobHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:name];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PPJobModelView *jobModel = self.dataArray[indexPath.row];
    if (jobModel.isExpandCell) {
        PPJobExpandCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierExpandCell forIndexPath:indexPath];
        [cell configureCell:jobModel];
        cell.delegate = self.delegate;
        return cell;
    }else {
        PPJobCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierCell forIndexPath:indexPath];
        [cell configureCell:jobModel];
        cell.delegate = self.delegate;
        return cell;
    }
    return [UITableViewCell new];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSMutableArray *tmpArray = (self.isPendingJob == YES) ? self.dataJobArray : self.dataHistoryArray;
    if (searchText.length == 0) {
        if (self.isPendingJob) {
            self.jobSearchText = @"";
        }else {
            self.historySearchText = @"";
        }
        self.dataArray = tmpArray;
    }else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fileFullName CONTAINS[cd] %@", searchText];
        self.dataArray = [[tmpArray filteredArrayUsingPredicate:predicate] mutableCopy];
        if (self.isPendingJob) {
            self.jobSearchText = searchText;
        }else {
            self.historySearchText = searchText;
        }
    }
}

#pragma mark - Private methods
- (void)setDataArray:(NSMutableArray *)dataArray {
    _dataArray = dataArray;
    [self reloadTableViewController];
}

- (void)reloadTableViewController {
    if ([self.delegate respondsToSelector:@selector(shouldReloadTableViewWithEmpty:)]) {
        [self.delegate shouldReloadTableViewWithEmpty:(_dataArray.count == 0)];
    }
}

@end
