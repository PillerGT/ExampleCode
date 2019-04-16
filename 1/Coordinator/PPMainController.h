//
//  PPMainController.h
//  PayForPrint
//
//  Created by Alexander Kovalov on 15.08.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPMainController : UITabBarController

@property (strong, nonatomic, readonly) UINavigationController *jobsNavigationController;
@property (strong, nonatomic, readonly) UINavigationController *addFilesNavigationController;
@property (strong, nonatomic, readonly) UINavigationController *locationNavigationController;
@property (strong, nonatomic, readonly) UINavigationController *meNavigationController;

- (void)showPendingJob;

@end



@interface UIViewController (PPMainController)

@property (strong, nonatomic, readonly) PPMainController *mainController;

@end
