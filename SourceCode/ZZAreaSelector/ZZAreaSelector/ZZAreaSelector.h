//
//  ZZAreaSelector.h
//  ZZAddressSelector
//
//  Created by Zhang_yD on 2017/3/20.
//  Copyright © 2017年 Z. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZZAreaType) {
    ZZAreaTypeCity = 0,
    ZZAreaTypeArea
};

@class ZZAreaSelector;
@protocol ZZAreaSelectorDelegate <NSObject>

- (void)areaSelector:(ZZAreaSelector *)areaSelector didSelectWithProvince:(NSString *)province city:(NSString *)city area:(NSString *)area;

@end

@interface ZZAreaSelector : UIView


@property (nonatomic, weak) id<ZZAreaSelectorDelegate> delegate;

@property (nonatomic, assign) ZZAreaType areaType;

- (void)show;

@end
