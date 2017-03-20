//
//  UIColor+ZZAddressExtension.h
//  ZZAddressSelector
//
//  Created by Zhang_yD on 2017/3/20.
//  Copyright © 2017年 Z. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ZZAddressExtension)

+ (UIColor *)colorWithHex:(NSInteger)hexValue;
+ (UIColor *)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;

@end

#define kColor(a) [UIColor colorWithHex:a]
