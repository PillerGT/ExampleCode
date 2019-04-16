//
//  PPJobModelView.h
//  PayForPrint
//
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PPPendingJobs, PPHistoryJobs;

@interface PPJobModelView : NSObject

@property (strong, readonly)PPPendingJobs *job;
@property (strong, readonly)PPHistoryJobs *historyJob;

@property (strong, readonly)NSString *jobId;
@property (strong, readonly)NSString *fileFullName;
@property (strong, readonly)NSString *fileName;
@property (strong, readonly)NSString *fileType;
@property (strong, readonly)UIImage *fileTypeImage;
@property (strong, readonly)NSString *fileSize;
@property (strong, readonly)NSString *uploadedTimestamp;
@property (strong, readonly)NSString *numPages;
@property (strong, readonly)NSString *releaseCode;
@property (strong, readonly)NSString *expiry;
@property (strong, readonly)NSString *costBW;
@property (strong, readonly)UIImage *statusImage;
@property (strong, readonly)NSString *statusText;
@property (strong, readonly)NSString *copies;

@property (assign, readonly)BOOL isExpandCell;

@property (strong, readonly)UIColor *headerBackgroundColor;
@property (strong, readonly)UIColor *headerTextColor;
@property (strong, readonly)UIImage *moreInfoButtonImage;
@property (strong, readonly)UIColor *statusTextColor;

@property (strong, readonly)UIImage *rightBottomButtonImage;

@property (assign, readonly)CGFloat widthPagesCopiesConstraint;

- (instancetype)initWithJob:(PPPendingJobs *)job;
- (instancetype)initWithHistoryJob:(PPHistoryJobs *)job;

- (void)shouldExpandViewCell;

@end
