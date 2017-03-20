//
//  ViewController.m
//  ZZAddressSelector
//
//  Created by Zhang_yD on 2017/3/20.
//  Copyright © 2017年 Z. All rights reserved.
//

#import "ViewController.h"
#import "ZZAreaSelector.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController () <ZZAreaSelectorDelegate>

@property (nonatomic, weak) UIButton *button1;
@property (nonatomic, weak) UIButton *button2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button1 = [[UIButton alloc] init];
    [self.view addSubview:button1];
    button1.frame = CGRectMake(0, 20, ScreenWidth, (ScreenHeight - 20) / 2);
    button1.titleLabel.font = [UIFont systemFontOfSize:16];
    [button1 setTitle:@"City" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(click1) forControlEvents:UIControlEventTouchUpInside];
    _button1 = button1;
    
    UIButton *button2 = [[UIButton alloc] init];
    [self.view addSubview:button2];
    button2.frame = CGRectMake(0, 20 + (ScreenHeight - 20) / 2, ScreenWidth, (ScreenHeight - 20) / 2);
    button2.titleLabel.font = [UIFont systemFontOfSize:16];
    [button2 setTitle:@"Area" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(click2) forControlEvents:UIControlEventTouchUpInside];
    _button2 = button2;
    
}

- (void)click1 {
    ZZAreaSelector *areaS = [[ZZAreaSelector alloc] init];
    areaS.delegate = self;
    areaS.areaType = ZZAreaTypeCity;
    areaS.tag = 100;
    [areaS show];
}

- (void)click2 {
    ZZAreaSelector *areaS = [[ZZAreaSelector alloc] init];
    areaS.delegate = self;
    areaS.areaType = ZZAreaTypeArea;
    areaS.tag = 101;
    [areaS show];
}


#pragma mark - ZZAreaSelectorDelegate
- (void)areaSelector:(ZZAreaSelector *)areaSelector didSelectWithProvince:(NSString *)province city:(NSString *)city area:(NSString *)area {
    if (areaSelector.tag == 100) {
        
    } else {
        
    }
    NSLog(@"province - %@; city - %@; area - %@", province, city, area);
}


@end
