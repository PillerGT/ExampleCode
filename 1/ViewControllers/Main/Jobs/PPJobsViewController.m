//
//  PPJobsViewController.m
//  HP ePrint
//
//Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPJobsViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "PPApiClient.h"
#import "PPJobsViewDataSource.h"
#import "PPJobCell.h"
#import "PPEmptyScreenView.h"
#import "UIColor+PayForPrint.h"
#import "PPJobHeaderView.h"
#import "UIViewController+Alert.h"
#import "PPUser.h"
#import "NSNumber+Currency.h"
#import "PPOrganisation.h"

@interface PPJobsViewController () <PPJobsViewDataSourceDelegate, PPJobCellDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *jobSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *jobsTableView;

@property (weak, nonatomic) IBOutlet UIButton *pendingJobsButton;
@property (weak, nonatomic) IBOutlet UIButton *historyJobsButton;
@property (weak, nonatomic) IBOutlet UIButton *searchJobsButton;

@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *addFundsButton;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic)PPEmptyScreenView *emptyView;
@property (strong, nonatomic)PPJobsViewDataSource *jobsDataSource;

@end

@implementation PPJobsViewController
- (IBAction)tapHeaderButtonAction:(UIButton *)sender {
    if (sender == self.pendingJobsButton) {
        self.jobsDataSource.isPendingJob = YES;
    }else if (sender == self.historyJobsButton) {
        self.jobsDataSource.isPendingJob = NO;
    }else {
        self.jobsDataSource.isShowSearch = !self.jobsDataSource.isShowSearch;
        if ([self.jobsDataSource respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
            [self.jobsDataSource searchBarSearchButtonClicked:self.jobSearchBar];
        }
        [self selectButton];
        [self showSearchBar];
        [self.jobsDataSource changeVisibleArray];
        return;
    }
    [self selectButton];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.jobsDataSource changeVisibleArray];
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    
    [self checkCreditProvider];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self addedRefreshControl];
    self.jobsDataSource = [[PPJobsViewDataSource alloc] initWithDelegate:self];
    self.jobSearchBar.hidden = !self.jobsDataSource.isShowSearch;
    self.jobsTableView.dataSource = self.jobsDataSource;
    self.jobsTableView.delegate = self.jobsDataSource;
    self.jobSearchBar.delegate = self.jobsDataSource;
    self.jobsTableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.jobsTableView.estimatedSectionHeaderHeight = 40;
    [self selectButton];
    self.emptyView = [PPEmptyScreenView viewFromNibTypeEmpty:TypeEmptyPending];
    self.jobsTableView.backgroundView = self.emptyView;
    [self registerHeaderView];
    self.balanceLabel.textColor = [UIColor appBaseColor];
}

- (void)registerHeaderView{
    NSString *name = NSStringFromClass([PPJobHeaderView class]);
    [self.jobsTableView registerNib:[UINib nibWithNibName:name bundle:nil] forHeaderFooterViewReuseIdentifier:name];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateBalance];
}

- (void)checkCreditProvider {
    __weak typeof(self) wSelf = self;
    [[PPApiClient sharedClient] getOrganizationMySuccess:^(PPOrganisation *org) {
        wSelf.addFundsButton.hidden = org.creditProvider == TypeCreditProviderNone;
    } failure:nil];
}

- (void)updateBalance {
    PPUser *user = [[PPApiClient sharedClient] getUserData];
    self.balanceLabel.text = [user.balance numberToCurrencyString];
    __weak typeof(self) wSelf = self;
    [[PPApiClient sharedClient] getUserSuccess:^(PPUser *user) {
        wSelf.balanceLabel.text = [user.balance numberToCurrencyString];
    } failure:nil];
}

- (void)addedRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    if (@available(iOS 10, *)) {
        self.jobsTableView.refreshControl = self.refreshControl;
    }else {
        [self.jobsTableView addSubview:self.refreshControl];
    }
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
}

- (void)refreshData {
    [self.jobsDataSource reload];
}

- (void)refreshAfterUploadingFile {
    self.jobsDataSource.isPendingJob = YES;
    self.jobsDataSource.isShowSearch = NO;
    [self showSearchBar];
    [self selectButton];
    [self refreshData];
    [self showSuccessUploadToServerAlert];
}

- (void)selectButton {
    UIColor *selectColor = [UIColor appBaseColor];
    UIColor *unSelectColor = [UIColor blackColor];
    [self.pendingJobsButton setTitleColor:self.jobsDataSource.isPendingJob ? selectColor : unSelectColor forState:UIControlStateNormal];
    [self.historyJobsButton setTitleColor:self.jobsDataSource.isPendingJob ? unSelectColor : selectColor forState:UIControlStateNormal];
    UIImage *searchImage = [UIImage imageNamed:self.jobsDataSource.isShowSearch ? @"ppSearchSelect" : @"ppSearch"];
    [self.searchJobsButton setImage:searchImage forState:UIControlStateNormal];
}

- (void)showSearchBar {
    [UIView animateWithDuration:0.3 animations:^{
        self.jobSearchBar.hidden = !self.jobsDataSource.isShowSearch;
    } completion:nil];
}

#pragma mark - PPJobsViewDataSourceDelegate
- (void)shouldReloadTableViewWithEmpty:(BOOL)isShowEmpty {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.refreshControl endRefreshing];
    if (isShowEmpty) {
        if (self.jobsDataSource.isPendingJob) {
            self.emptyView = [PPEmptyScreenView viewFromNibTypeEmpty:TypeEmptyPending];
        }else {
            self.emptyView = [PPEmptyScreenView viewFromNibTypeEmpty:TypeEmptyHistory];
        }
        self.jobsTableView.backgroundView = self.emptyView;
    }else {
        self.jobsTableView.backgroundView = nil;
    }
    [self.jobsTableView reloadData];
}

-(void)changeSearchTextInSearchBar:(NSString *)searchText {
    self.jobSearchBar.text = searchText;
}

#pragma mark - PPJobCellDelegate
- (void)cellJobDelete:(PPJobCell *)cell {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Delete document?" preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) wSelf = self;
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Delete");
        [MBProgressHUD showHUDAddedTo:wSelf.view animated:YES];
        NSIndexPath *indexPath = [wSelf.jobsTableView indexPathForCell:cell];
        [wSelf.jobsDataSource cellDeleteJobIndexPath:indexPath];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)cellExpand:(PPJobCell *)cell {
    NSIndexPath *indexPath = [self.jobsTableView indexPathForCell:cell];
    [self.jobsDataSource cellExpandIndexPath:indexPath];
}

@end
