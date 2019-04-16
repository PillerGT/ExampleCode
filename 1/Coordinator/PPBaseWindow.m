//
//  PPBaseWindow.m
//  PayForPrint
//
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPBaseWindow.h"
#import "PPLoginViewController.h"
#import "PPMainController.h"

@interface PPBaseWindow()
@property (strong, nonatomic, readwrite) PPMainController *mainController;
@end

@implementation PPBaseWindow

- (void) showLoginScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Auth" bundle:nil];
    PPLoginViewController *rootViewController = [storyboard instantiateInitialViewController];
    self.rootViewController = rootViewController;
}

- (void) showMainScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.mainController = [storyboard instantiateInitialViewController];
    self.rootViewController = self.mainController;
}

@end
