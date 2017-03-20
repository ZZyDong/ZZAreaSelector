//
//  UILabel+ZZAddressExtension.m
//  ZZAddressSelector
//
//  Created by Zhang_yD on 2017/3/20.
//  Copyright © 2017年 Z. All rights reserved.
//

#import "UILabel+ZZAddressExtension.h"

@implementation UILabel (ZZAddressExtension)

- (CGSize)labelSize {
    return  [self.text sizeWithAttributes:@{NSFontAttributeName : self.font}];
}

- (CGFloat)labelWidth {
    return self.labelSize.width;
}
- (CGFloat)labelHeight {
    return self.labelSize.height;
}

@end
