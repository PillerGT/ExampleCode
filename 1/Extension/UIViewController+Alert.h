//
//  UIViewController+Alert.h
//  PayForPrint
//
//  Created by Alexander Kovalov on 13.08.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Alert)

- (void)showNotSupportedFileAlert;
- (void)showNotSupportedFileForPreviewAlert;
- (void)showSuccessUploadToServerAlert;
- (void)showFailureUploadToServerAlert;

@end
