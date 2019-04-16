//
//  PPUploadFiles.m
//  PayForPrint
//
//  Created by Alexander Kovalov on 08.08.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPUploadFiles.h"
#import "PPApiClient.h"
#import "PrintableContent.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIViewController+Alert.h"
#import "PDNetworkManager.h"
#import "StringHelper.h"

@interface PPUploadFiles()
@property (weak, nonatomic) id<PPUploadFilesDelegate> delegate;
@end

@implementation PPUploadFiles

- (instancetype)initUploadFilesWithDelegate:(id<PPUploadFilesDelegate>)delegate {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.delegate = delegate;
    return self;
}

- (void)startUploadFiles:(NSArray *)fileArray controller:(UIViewController *)vc {
    if (fileArray.count == 0) {
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
    __weak typeof(self) wSelf = self;
    [self uploadFilesToServer:[fileArray mutableCopy] success:^{
        [MBProgressHUD hideHUDForView:vc.view animated:YES];
        [wSelf showSuccessAlert];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:vc.view animated:YES];
        [wSelf showFailureAlert:vc];
    }];
}

- (void) uploadFilesToServer:(NSMutableArray *)uploadFiles success:(void(^)(void))success failure:(void(^)(NSError *error))failure{
    PrintableContent *pContent = uploadFiles.firstObject;
    if ([pContent isKindOfClass:[PrintableContent class]]) {
        NSString *fileName = pContent.fileName;
        NSURL *url = pContent.url;
        NSError* error = nil;
        NSData* data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            if (failure) {
                failure(error);
            }
        } else {
            NSLog(@"Data has loaded successfully.");
            
            [[PPApiClient sharedClient] postUploadFileName:fileName data:data success:^{
                NSLog(@"success");
                [uploadFiles removeObject:pContent];
                [self uploadFilesToServer:uploadFiles success:success failure:failure];
            } failure:^(NSError *error) {
                NSLog(@"error");
                if (failure) {
                    failure(error);
                }
            }];
        }
    }else if (success) {
        success();
    }
}

- (void)startNewUploadFiles:(NSArray *)fileArray controller:(UIViewController *)vc {
    [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
    __weak typeof(self) wSelf = self;

    NSMutableArray *printUnifyleFiles = [NSMutableArray new];    
    for (PDDocument *content in fileArray) {
        NSArray *pathCompon = [content.pdFullPath pathComponents];
        NSMutableArray *pathComponEncode = [NSMutableArray new];
        for (NSString *component in pathCompon) {
            [pathComponEncode addObject:[StringHelper stringUrlEncoded:component]];
        }
        NSDictionary *parameters = @{ @"fileId": [NSString pathWithComponents: pathComponEncode],
                                      @"providerName": @"unifyle" };
        [printUnifyleFiles addObject:parameters];
    }
    
    [[PPApiClient sharedClient] uploadFileFromProviderMulti:printUnifyleFiles success:^{
        [MBProgressHUD hideHUDForView:vc.view animated:YES];
        [wSelf showSuccessAlert];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:vc.view animated:YES];
        [wSelf showFailureAlert:vc];
    }];
}

- (void)showSuccessAlert {
    if ([self.delegate respondsToSelector:@selector(finishSuccessLoadFiles)]) {
        [self.delegate finishSuccessLoadFiles];
    }
}

- (void)showFailureAlert:(UIViewController *)vc {
    if ([self.delegate respondsToSelector:@selector(finishFailureLoadFiles)]) {
        [self.delegate finishFailureLoadFiles];
    }
    [vc showFailureUploadToServerAlert];
}

- (BOOL)isTypeSupported:(NSString *)typeToCheck {
    NSString *fileExt = typeToCheck.pathExtension.lowercaseString;
    if (fileExt.length == 0) {
        return YES;
    }
    NSDictionary *dict = [PPUploadFiles fromFileToDictionary];
    if (!dict) {
        return YES;
    }
    NSMutableSet *supportTypeFilesSet = [[NSMutableSet alloc] initWithArray:[dict allKeys]];
    if ([supportTypeFilesSet containsObject:fileExt]) {
        return NO;
    }
    return YES;
}

+ (NSArray *)documentsTypeForCloud {
    NSDictionary *dict = [PPUploadFiles fromFileToDictionary];
    //NSArray *tmpArray = dict.allKeys;
    NSMutableArray *publicArray = [NSMutableArray new];
    for (NSString *extension in dict.allKeys) {
        NSString *newExt = [@"public." stringByAppendingString:extension];
        [publicArray addObject:newExt];
    }
    return [publicArray copy];
}

+ (NSString *)mimeTypeForFile:(NSString *)fileName {
    NSDictionary *dict = [PPUploadFiles fromFileToDictionary];
    return [dict objectForKey:fileName.pathExtension.lowercaseString];
}

+ (NSDictionary *)fromFileToDictionary{
    NSString *plist = [[NSBundle mainBundle] pathForResource:@"Extensions" ofType:@"plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath: plist] == NO){
        return nil;
    }
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plist];
    if (!(dict) && dict.count == 0) {
        return nil;
    }
    return dict;
}

@end
