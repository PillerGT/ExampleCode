//
//  UINavigationController+PayForPrint.m
//  PayForPrint
//
//  Created by Alexander Kovalov on 23.07.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "UINavigationController+PayForPrint.h"

@implementation UINavigationController (PayForPrint)

- (void)setTopController:(UIViewController *)viewController animated:(BOOL)animated {
    NSMutableArray *navigationArray = [NSMutableArray arrayWithArray:self.viewControllers];
    [navigationArray removeLastObject];
    [navigationArray addObject:viewController];
    [self setViewControllers:navigationArray animated:animated];
}

@end
