//
//  PPProfileModelView.h
//  PayForPrint
//
//  Created by Alexander Kovalov on 11.07.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TypeSettingCell) {
    TypeSettingTitleUser = 0,
    TypeSettingProfile,
    TypeSettingOrganization,
    TypeSettingSubOrganization,
    TypeSettingTransaction,
    TypeSettingLogOut,
    TypeSettingProvider,
    TypeSettingSecret,
    TypeSettingAbout,
    TypeSettingContact
};

@class PPProvider;

@interface PPProfileModelView : NSObject

@property (readonly)PPProvider *provider;
@property (readonly)TypeSettingCell typeCell;

@property (strong, readonly)NSString *titleText;
@property (strong, readonly)NSString *detailText;
@property (strong, readonly)UIImage *image;
@property (assign, readonly)BOOL isAccesory;
@property (assign, readonly)BOOL isLink;

-(instancetype)initWithType:(TypeSettingCell)type data:(id)data;

@end
