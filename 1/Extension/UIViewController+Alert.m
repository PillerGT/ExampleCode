//
//  UIViewController+Alert.m
//  PayForPrint
//
//  Created by Alexander Kovalov on 13.08.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "UIViewController+Alert.h"

@implementation UIViewController (Alert)

- (void)showNotSupportedFileAlert {
    [self showAlertWithTitle:nil message:@"This file could not be printed" actionTitle:@"OK"];
}

- (void)showNotSupportedFileForPreviewAlert {
    [self showAlertWithTitle:nil message:@"You can't preview this type of file" actionTitle:@"OK"];
}

- (void)showSuccessUploadToServerAlert {
    [self showAlertWithTitle:nil message:@"File(s) uploaded successfully" actionTitle:@"OK"];
}

- (void)showFailureUploadToServerAlert {
    [self showAlertWithTitle:@"Failure!" message:@"Unsuccessful sending to the server" actionTitle:@"OK"];
}

- (void)showAlertWithTitle:(NSString *)alertTitle message:(NSString *)message actionTitle:(NSString *)actionTitle {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
