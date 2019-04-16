//
//  UIViewController+Router.m
//  PayForPrint
//
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "UIViewController+Router.h"
#import "AppDelegate.h"

@implementation UIViewController (Router)

- (PPBaseWindow *)router {
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return (PPBaseWindow *)appDelegate.window;
}

@end
