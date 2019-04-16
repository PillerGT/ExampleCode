//
//  PPProfileDataSource.m
//  PayForPrint
//
//  Created by Alexander Kovalov on 11.07.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPProfileDataSource.h"
#import "PPUserNameCell.h"
#import "PPSettingsCell.h"
#import "PPProviderLinkCell.h"
#import "PPButtonCell.h"

#import "PPProfileModelView.h"
#import "PPApiClient.h"
#import "PPUser.h"
#import "PPSubOrganization.h"
#import "PPProvider.h"
#import "PPOrganisation.h"

#import "PluginFactory.h"

static NSString *userNameIdentifier = @"userName";
static NSString *settingsIdentifier = @"settingsCell";
static NSString *providerLinkIdentifier = @"providerLink";
static NSString *bigButtonIdentifier = @"bigButton";

@interface PPProfileDataSource()
@property (weak, nonatomic) id<PPProfileDataSourceDelegate, PPProviderLinkCellDelegate, PPButtonCellDelegate, PPUserNameCellDelegate> delegate;
@property (strong, nonatomic) NSArray *sectionsArray;
@end

@implementation PPProfileDataSource

- (instancetype)initWithDelegate:(id<PPProfileDataSourceDelegate, PPProviderLinkCellDelegate, PPButtonCellDelegate, PPUserNameCellDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [self configureSettings];
    }
    return self;
}

- (void)reload {
    [self configureSettings];
    if ([self.delegate respondsToSelector:@selector(shouldReloadTableView)]) {
        [self.delegate shouldReloadTableView];
    }
}

#pragma mark - Provate methods
- (void)configureSettings {
    PPUser *user = [[PPApiClient sharedClient] getUserData];
    PPOrganisation *organization = [[PPApiClient sharedClient] getOrganizationData];

    PPProfileModelView *userTitleModel = [[PPProfileModelView alloc] initWithType:TypeSettingTitleUser data:user.username];
    PPProfileModelView *profileModel = [[PPProfileModelView alloc] initWithType:TypeSettingProfile data:nil];
    PPProfileModelView *paymentsModel = [[PPProfileModelView alloc] initWithType:TypeSettingTransaction data:nil];
    PPProfileModelView *logoutModel = [[PPProfileModelView alloc] initWithType:TypeSettingLogOut data:nil];
    PPProfileModelView *secretModel = [[PPProfileModelView alloc] initWithType:TypeSettingSecret data:nil];
    PPProfileModelView *contactModel = [[PPProfileModelView alloc] initWithType:TypeSettingContact data:nil];
    PPProfileModelView *aboutModel = [[PPProfileModelView alloc] initWithType:TypeSettingAbout data:nil];
    PPProfileModelView *organizationModel = [[PPProfileModelView alloc] initWithType:TypeSettingOrganization data:organization.organisationName];
    PPProfileModelView *subOrgModel = [[PPProfileModelView alloc] initWithType:TypeSettingSubOrganization data:user.subOrg.name];
    
    NSMutableArray *settingsArray = [[NSMutableArray alloc] initWithArray:@[userTitleModel, profileModel, organizationModel]];

    if (user.subOrg != nil && user.subOrg.name != nil && user.subOrg.name.length > 0) {
        [settingsArray addObject:subOrgModel];
    }
    if (organization.creditProvider == TypeCreditProviderStripe) {
        [settingsArray addObject:paymentsModel];
    }
    
    NSArray *providerArray = [NSArray arrayWithObjects:
                              [PPProvider providerObject:TypeProviderDropbox],
                              [PPProvider providerObject:TypeProviderBox],
                              [PPProvider providerObject:TypeProviderGDrive],
                              [PPProvider providerObject:TypeProviderOneDrive],
                              [PPProvider providerObject:TypeProviderOffice365],
                              nil];
    NSMutableArray *infoArray = [[NSMutableArray alloc] initWithArray:@[logoutModel, contactModel, aboutModel]];
    if (self.isShowSecret) {
        [infoArray insertObject:secretModel atIndex:1];
    }
    
    self.sectionsArray = [NSArray arrayWithObjects:settingsArray, [self configureProviders:providerArray], infoArray,nil];
}

- (NSArray *)configureProviders:(NSArray *)providersArray {
    NSDictionary *accounts = [[PluginFactory sharedPlugin] accounts];
    NSMutableArray *providerArray = [NSMutableArray new];
    
    for (NSNumber *providerObject in providersArray) {
        PDAccount *account = [accounts objectForKey:providerObject.stringValue];
        PPProvider *provider = [PPProvider createProvider:providerObject.unsignedIntegerValue account:account];
        PPProfileModelView *providerModel = [[PPProfileModelView alloc] initWithType:TypeSettingProvider data:provider];
        [providerArray addObject:providerModel];
    }
    return [providerArray mutableCopy];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionsArray count];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sectionsArray[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Settings";
    }else if (section == 1)
        return @"Linked Accounts";
    return nil;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PPProfileModelView *modelView = self.sectionsArray[indexPath.section][indexPath.row];
    
    if (modelView.typeCell == TypeSettingTitleUser) {
        PPUserNameCell *cell = [tableView dequeueReusableCellWithIdentifier:userNameIdentifier forIndexPath:indexPath];
        [cell configureCell:modelView];
        cell.delegate = self.delegate;
        return cell;
    }
    if ((modelView.typeCell == TypeSettingProfile) || (modelView.typeCell == TypeSettingTransaction) || (modelView.typeCell == TypeSettingLogOut) || (modelView.typeCell == TypeSettingOrganization) || (modelView.typeCell == TypeSettingSubOrganization)) {
        PPSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:settingsIdentifier forIndexPath:indexPath];
        [cell configureCell:modelView];
        return cell;
    }
    if (modelView.typeCell == TypeSettingProvider) {
        PPProviderLinkCell *cell = [tableView dequeueReusableCellWithIdentifier:providerLinkIdentifier forIndexPath:indexPath];
        [cell configureCell:modelView];
        cell.delegate = self.delegate;
        return cell;
    }
    if ((modelView.typeCell == TypeSettingAbout) || (modelView.typeCell == TypeSettingContact) || (modelView.typeCell == TypeSettingSecret)) {
        PPButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:bigButtonIdentifier forIndexPath:indexPath];
        [cell configureCell:modelView];
        cell.delegate = self.delegate;
        return cell;
    }
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    PPProfileModelView *modelView = self.sectionsArray[indexPath.section][indexPath.row];
    if (modelView.typeCell == TypeSettingProfile) {
        if ([self.delegate respondsToSelector:@selector(tapProfile)]) {
            [self.delegate tapProfile];
        }
    }
    if (modelView.typeCell == TypeSettingTransaction) {
        if ([self.delegate respondsToSelector:@selector(tapTransaction)]) {
            [self.delegate tapTransaction];
        }
    }
    if (modelView.typeCell == TypeSettingLogOut) {
        if ([self.delegate respondsToSelector:@selector(logOutUser)]) {
            [self.delegate logOutUser];
        }
    }
}

@end
