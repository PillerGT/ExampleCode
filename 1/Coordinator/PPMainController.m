//
//  PPMainController.m
//  PayForPrint
//
//  Created by Alexander Kovalov on 15.08.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPMainController.h"
#import "PPJobNavigationController.h"
#import "PPAddFilesNavigationController.h"
#import "PPLocationNavigationController.h"
#import "PPMeNavigationController.h"

#import "PPJobsViewController.h"
#import "PPAddFilesViewController.h"
#import "AppDelegate.h"

@interface PPMainController ()

@property (strong, nonatomic, readwrite) PPJobNavigationController *jobsNavigationController;
@property (strong, nonatomic, readwrite) PPAddFilesNavigationController *addFilesNavigationController;
@property (strong, nonatomic, readwrite) PPLocationNavigationController *locationNavigationController;
@property (strong, nonatomic, readwrite) PPMeNavigationController *meNavigationController;

@end

@implementation PPMainController

- (void)viewDidLoad {
    [super viewDidLoad];

    for (id controller in self.viewControllers) {
        if ([controller isKindOfClass:[PPJobNavigationController class]]) {
            self.jobsNavigationController = controller;
        }else if ([controller isKindOfClass:[PPAddFilesNavigationController class]]) {
            self.addFilesNavigationController = controller;
        }else if ([controller isKindOfClass:[PPLocationNavigationController class]]) {
            self.locationNavigationController = controller;
        }else if ([controller isKindOfClass:[PPMeNavigationController class]]) {
            self.meNavigationController = controller;
        }
    }
}

- (void)showPendingJob {
    [self backToFirstController];
    self.selectedViewController = self.jobsNavigationController;
    id controller = self.jobsNavigationController.viewControllers.firstObject;
    if ([controller isKindOfClass:[PPJobsViewController class]]) {
        PPJobsViewController *jobController = controller;
        [jobController refreshAfterUploadingFile];
    }
}

- (void)backToFirstController {
    [self.tabBar setHidden:NO];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_addFilesNavigationController setNavigationBarHidden:NO animated:YES];
    }
    UIViewController *vc = _addFilesNavigationController.viewControllers.firstObject;
    if (![vc isKindOfClass:[PPAddFilesViewController class]]) {
        return;
    }
    [_addFilesNavigationController setViewControllers:@[vc] animated:NO];
}

- (PPJobNavigationController *)jobsNavigatinController {
    PPJobNavigationController *controller = _jobsNavigationController;
    if (!controller) {
        controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
        _jobsNavigationController = controller;
    }
    return controller;
}

- (PPAddFilesNavigationController *)addFilesNavigationController {
    PPAddFilesNavigationController *controller = _addFilesNavigationController;
    if (!controller) {
        controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addFilesNavController"];
        _addFilesNavigationController = controller;
    }
    return controller;
}

- (PPLocationNavigationController *)locationNavigationController {
    PPLocationNavigationController *controller = _locationNavigationController;
    if (!controller) {
        controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"locationNavController"];
        _locationNavigationController = controller;
    }
    return controller;
}

- (PPMeNavigationController *)meNavigationController {
    PPMeNavigationController *controller = _meNavigationController;
    if (!controller) {
        controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"meNavController"];
        _meNavigationController = controller;
    }
    return controller;
}

@end

#pragma mark - UIViewController(PPMainController)
@implementation UIViewController (PPMainController)

- (PPMainController *)mainController {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIViewController *controller = [[AppDelegate.instance window] rootViewController];
        if (controller && [controller isKindOfClass:[PPMainController class]]) {
            return (PPMainController *)controller;
        }
        return nil;
    }
    
    UIViewController *controller = self.parentViewController;
    
    if ([controller isKindOfClass:[self.navigationController class]]) {
        UINavigationController *navVC = (UINavigationController *)controller;
        controller = navVC.viewControllers.firstObject;
    }
    while (controller && ![controller isKindOfClass:[PPMainController class]]) {
        controller = (controller.parentViewController == controller) ? nil : controller.parentViewController;
    }
    return (PPMainController *)controller;
}

@end
