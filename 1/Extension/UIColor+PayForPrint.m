//
//  UIColor+PayForPrint.m
//  PayForPrint
//
//  Created by Alexander Kovalov on 27.06.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "UIColor+PayForPrint.h"

@implementation UIColor (PayForPrint)

+ (UIColor*)appBaseColor {
    return [UIColor colorWithRed:247/255.0f green:148/255.0f blue:30/255.0f alpha:1.0f];
}

+ (UIColor*)appDisableBaseColor {
    return [UIColor colorWithRed:252/255.0f green:212/255.0f blue:165/255.0f alpha:1.0f];
}

+ (UIColor*)appCellReadyColor {
    return [UIColor colorWithRed:65/255.0f green:121/255.0f blue:65/255.0f alpha:1.0f];
}

+ (UIColor*)appCellProccessingColor {
    return [UIColor colorWithRed:217/255.0f green:217/255.0f blue:217/255.0f alpha:1.0f];
}

+ (UIColor*)appCellProblemColor {
    return [UIColor colorWithRed:255/255.0f green:31/255.0f blue:31/255.0f alpha:1.0f];
}

+ (UIColor*)appHeaderCellColor {
    return [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f];
}

+ (UIColor*)appValidGrayColor {
    return [UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0f];
}

+ (UIColor*)appValidGreenColor {
    return [UIColor colorWithRed:57/255.0f green:224/255.0f blue:111/255.0f alpha:1.0f];
}

+ (UIColor*)appValidRedColor {
    return [UIColor colorWithRed:255/255.0f green:5/255.0f blue:0/255.0f alpha:1.0f];
}

+ (UIColor*)appValidLightGreenColor {
    return [UIColor colorWithRed:199/255.0f green:255/255.0f blue:199/255.0f alpha:1.0f];
}

+ (UIColor*)appValidLightRedColor {
    return [UIColor colorWithRed:250/255.0f green:125/255.0f blue:23/255.0f alpha:1.0f];
}

@end
