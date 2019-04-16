//
//  PPBaseViewController.m
//  PayForPrint
//
//  Created by Alexander Kovalov on 29.06.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPBaseViewController.h"

@interface PPBaseViewController ()

@end

@implementation PPBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 105, 35)];
    titleImageView.image = [UIImage imageNamed:@"ppLogoEprintitWhite"];
    self.navigationItem.titleView = titleImageView;
    self.navigationController.navigationBar.barTintColor = [UIColor appBaseColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

@end
