//
//  UIView+ZZAddressExtension.h
//  ZZAddressSelector
//
//  Created by Zhang_yD on 2017/3/20.
//  Copyright © 2017年 Z. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface UIView (ZZAddressExtension)

- (CGFloat)x;
- (CGFloat)y;
- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;
- (CGFloat)width;
- (CGFloat)height;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;
- (CGFloat)maxX;
- (CGFloat)maxY;
- (CGFloat)centerX;
- (CGFloat)centerY;
- (void)setCenterX:(CGFloat)centerX;
- (void)setCenterY:(CGFloat)centerY;

@end
