//
//  NSUserDefaults+PPUserDefaults.h
//  PayForPrint
//
//  Created by Alexander Kovalov on 30.10.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kPPCampusDefaultsKey = @"userdefaults.com.eprintit.ppl";

@interface NSUserDefaults (PPUserDefaults)

+(instancetype)ppUserDefaults;

@end
