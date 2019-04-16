//
//  PPUploadFiles.h
//  PayForPrint
//
//  Created by Alexander Kovalov on 08.08.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PPUploadFilesDelegate;

@interface PPUploadFiles : NSObject
- (instancetype)initUploadFilesWithDelegate:(id<PPUploadFilesDelegate>)delegate;
- (void)startUploadFiles:(NSArray *)fileArray controller:(UIViewController *)vc;
- (void)startNewUploadFiles:(NSArray *)fileArray controller:(UIViewController *)vc;
- (BOOL)isTypeSupported:(NSString *)typeToCheck;
+ (NSArray *)documentsTypeForCloud;
+ (NSString *)mimeTypeForFile:(NSString *)fileName;
+ (NSDictionary *)fromFileToDictionary;
@end



@protocol PPUploadFilesDelegate <NSObject>
- (void)finishSuccessLoadFiles;
@optional
- (void)finishFailureLoadFiles;
@end
