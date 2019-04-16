//
//  PPProfileModelView.m
//  PayForPrint
//
//  Created by Alexander Kovalov on 11.07.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPProfileModelView.h"
#import "PDAccount.h"
#import "PPProvider.h"
#import "PPApiClient.h"

@implementation PPProfileModelView

-(instancetype)initWithType:(TypeSettingCell)type data:(id)data {
    self = [super init];
    if (!self) {
        return nil;
    }
    _typeCell = type;
    switch (type) {
        case TypeSettingTitleUser: {
            NSString *name = (NSString *)data;
            _titleText = [NSString stringWithFormat:@"Hi %@", name.capitalizedString];
            break;
        }
        case TypeSettingProfile: {
            _titleText = @"Profile";
            _image = [UIImage imageNamed:@"ppUser"];
            _isAccesory = YES;
            break;
        }
        case TypeSettingOrganization: {
            _titleText = @"Organization";
            _detailText = (NSString *)data;;
            _image = [UIImage imageNamed:@"ppOrganization"];
            _isAccesory = NO;
            break;
        }
        case TypeSettingSubOrganization: {
            _titleText = @"Sub-Organization";
            _detailText = (NSString *)data;
            _image = [UIImage imageNamed:@"ppOrganization"];
            _isAccesory = NO;
            break;
        }
        case TypeSettingTransaction: {
            _titleText = @"Payments & Transactions";
            _image = [UIImage imageNamed:@"ppPayments"];
            _isAccesory = YES;
            break;
        }
        case TypeSettingLogOut: {
            _titleText = @"Log out";
            _image = [UIImage imageNamed:@"ppLogOut"];
            _isAccesory = NO;
            break;
        }
        case TypeSettingProvider: {
            if ([data isKindOfClass:[PPProvider class]]) {
                PPProvider *provider = (PPProvider *)data;
                _provider = provider;
                _titleText = provider.titleText;
                if (provider.account.pdAuthorized == nil) {
                    _isLink = (provider.account == nil) ? NO : YES;
                }else
                    _isLink = [provider.account.pdAuthorized boolValue];
            }
            break;
        }
        case TypeSettingSecret: {
            _titleText = @"Server settings";
            break;
        }
        case TypeSettingAbout: {
            _titleText = @"About";
            break;
        }
        case TypeSettingContact: {
            _titleText = @"Contact Support";
            break;
        }
        default:
            break;
    }
    return self;
}

@end
