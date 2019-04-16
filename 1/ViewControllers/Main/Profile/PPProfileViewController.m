//
//  PPProfileViewController.m
//  HP ePrint
//
//Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPProfileViewController.h"
#import "PPApiClient.h"
#import "PPProvider.h"
#import "UIViewController+Router.h"
#import "PPProfileDataSource.h"
#import "PPProviderLinkCell.h"
#import "PPButtonCell.h"
#import "PPUserNameCell.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import "PluginFactory.h"
#import "UNAutNavigationViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "InterfaceHelper.h"
#import "AboutViewController.h"


@interface PPProfileViewController () <PPProfileDataSourceDelegate, PPProviderLinkCellDelegate, PPProviderLinkCellDelegate, PDOAuthDelegate, PPButtonCellDelegate, MFMailComposeViewControllerDelegate, PPUserNameCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PPProfileDataSource *dataSource;
@property (strong, nonatomic) PPProvider *selectProvider;

@end

@implementation PPProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60.f;
    self.dataSource = [[PPProfileDataSource alloc] initWithDelegate:self];
    self.tableView.delegate = self.dataSource;
    self.tableView.dataSource = self.dataSource;
    self.tableView.tableFooterView = [UIView new];
    
    [self checkCreditProvider];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self oauthDoneWithSucces:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.dataSource.isShowSecret = NO;
    [self.dataSource reload];
}

- (void)checkCreditProvider {
    __weak typeof(self) wSelf = self;
    [[PPApiClient sharedClient] getOrganizationMySuccess:^(PPOrganisation *org) {
        [wSelf.dataSource reload];
    } failure:nil];
}

- (void)showLogOutAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Log Out" message:@"Do you really want to log out?" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) wSelf = self;
    UIAlertAction *okAktion = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[PPApiClient sharedClient] getLogOutUser];
        [wSelf.router showLoginScreen];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAktion];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)providerClicked:(PPProvider *)provider  switchLink:(UISwitch *)sender{
    if (provider.account.pdAuthorized && ![provider.account.pdAuthorized boolValue]) {
        self.selectProvider = provider;
        [self loadProviderAccount:provider.account];
    }else if (provider.account) {
        __weak typeof(self) wSelf = self;
        NSString *title = [NSString stringWithFormat:@"Do You want to unlink %@?", provider.titleText];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [wSelf deleteAccount:provider sender:sender];
        }];
        [alert addAction:okAction];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            sender.on = YES;
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UNAutNavigationViewController *controller = [[UIStoryboard storyboardWithName:@"UNAuthStoryboard" bundle:nil] instantiateInitialViewController];
        controller.providerId = provider.typeProvider;
        controller.providerName = provider.titleText;
        controller.authDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)deleteAccount:(PPProvider *)provider sender:(UISwitch *)sender {
    __weak typeof(self) wSelf = self;
    [MBProgressHUD showHUDAddedTo:wSelf.view animated:YES];
    [[PluginFactory sharedPlugin] removeProvider: provider.account.pdProviderId
                                   providerIndex:[NSString stringWithFormat:@"%@",@(provider.typeProvider)]
                                          succes:^(BOOL result) {
                                              [MBProgressHUD hideHUDForView:wSelf.view animated:YES];
                                              [wSelf.dataSource reload];//sender.on = NO;
                                          } failure:^(NSError *error) {
                                              [MBProgressHUD hideHUDForView:wSelf.view animated:YES];
                                              sender.on = YES;
                                          }];
}

- (void)loadProviderAccount:(PDAccount *)account  {
    PDNetworkManager *manager = [PDNetworkManager sharedManager];
    __weak typeof(self) weakSelf = self;
    [manager getDocumentsContentInFolder:account.pdPath withSucces:nil failure:^(NSError *error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            NSDictionary *errorDictionary = (NSDictionary*)error;
            if ([[errorDictionary objectForKey:@"error"] isEqualToString:@"invalid-oauth-token"]) {
                [weakSelf processInvalidTokenWithErrorDict:errorDictionary];
            } else if ([[errorDictionary objectForKey:@"error"] isEqualToString:@"authentication-error"]) {
                [weakSelf deleteAccount:account senderTag:@"168"];
            }
        }
    }];
}

- (void)processInvalidTokenWithErrorDict:(NSDictionary *)errorDictionary {
    NSString *renew = [errorDictionary objectForKey:@"renewalUrl"];
    [self startAuthWithRenewStr:renew];
}

- (void)deleteAccount:(PDAccount *)account senderTag:(NSString *)senderTag {
    __weak typeof(self) wSelf = self;
    [[PluginFactory sharedPlugin] removeProvider:account.pdProviderId
                                   providerIndex:[NSString stringWithFormat:@"%@",senderTag]
                                          succes:^(BOOL result) {
                                              [wSelf startAuthWithRenewStr:nil];
                                          } failure:^(NSError *error) {
                                          }];
}

- (void)startAuthWithRenewStr:(NSString *)renew {
    UNAutNavigationViewController *controller = [[UIStoryboard storyboardWithName:@"UNAuthStoryboard" bundle:nil] instantiateInitialViewController];
    controller.providerId = self.selectProvider.typeProvider;
    controller.providerName = self.selectProvider.titleText;
    controller.authDelegate = self;
    controller.renewUrl = renew;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - PDOAuthDelegate
- (void)oauthDoneWithSucces:(bool)succes {
    if (succes) {
        __weak typeof(self) wSelf = self;
        [MBProgressHUD showHUDAddedTo:wSelf.view animated:YES];
        [[PluginFactory sharedPlugin] getProviderAccountsWithSuccess:^(NSDictionary<NSString *,PDAccount *> *accounts) {
            [MBProgressHUD hideHUDForView:wSelf.view animated:YES];
            [wSelf.dataSource reload];
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:wSelf.view animated:YES];
            [wSelf.dataSource reload];
        }];
    }else {
        [self.dataSource reload];
    }
}

#pragma mark - PPProfileDataSourceDelegate
- (void)shouldReloadTableView {
    [self.tableView reloadData];
}

-(void)logOutUser {
    [self showLogOutAlert];
}

-(void)tapProfile {
    [self performSegueWithIdentifier:@"profile" sender:nil];
}

-(void)tapTransaction {
    [self performSegueWithIdentifier:@"payments" sender:nil];
}

-(void)tapSecretButton {
    [self performSegueWithIdentifier:@"secret" sender:nil];
}

#pragma mark - PPProviderLinkCellDelegate
-(void)changeStatusLinkAccount:(PPProvider *)provider switchLink:(UISwitch *)switchLink {
    [self providerClicked:provider switchLink:switchLink];
}

#pragma mark - PPButtonCellDelegate
- (void)tapAboutButton {
    AboutViewController *aboutViewControl = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    [self.navigationController pushViewController:aboutViewControl animated:YES];
}

- (void)tapContactButton {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:NSLocalizedString(@"iPhone application support", @"iPhone application support")];
    [controller setToRecipients:[NSArray arrayWithObject:@"support@eprintit.com"]];
    [controller setMessageBody:[NSString stringWithFormat:@"%@: %@\n %@: %@\n %@: %@\n %@: %@\n %@: %@\n %@: %@\n",
                                NSLocalizedString(@"Application version", nil), [InterfaceHelper getAppVersion],
                                NSLocalizedString(@"Device model", nil), [InterfaceHelper devicePlatformString],
                                NSLocalizedString(@"OS version", nil), [[UIDevice currentDevice] systemVersion],
                                NSLocalizedString(@"Locale", nil), [InterfaceHelper localeString],
                                NSLocalizedString(@"Username", nil), [[PPApiClient sharedClient] getUsername],
                                NSLocalizedString(@"Email", nil), [[PPApiClient sharedClient] getEmail]
                                ] isHTML:NO];
    if (controller)
    {
        [self.navigationController presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - PPUserNameCellDelegate
- (void)secretTapForCell {
    self.dataSource.isShowSecret = YES;
    [self.dataSource reload];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
