//
//  PPCustomButton.m
//  PayForPrint
//
//  Created by Alexander Kovalov on 18.07.2018.
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPBorderButton.h"
#import "UIColor+PayForPrint.h"

@implementation PPBorderButton


- (void)awakeFromNib {
    [super awakeFromNib];
    [self configButton];
}

- (void)configButton {
    [self setTitleColor:[UIColor appBaseColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor appDisableBaseColor] forState:UIControlStateDisabled];
    CALayer *layer = self.layer;
    layer.borderColor = [[UIColor appBaseColor] CGColor];
    layer.borderWidth = 1;
}

- (void)setEnabled:(BOOL)enabled {
    CALayer *layer = self.layer;
    layer.borderColor = enabled ? [[UIColor appBaseColor] CGColor] : [[UIColor appDisableBaseColor] CGColor];
}

@end
