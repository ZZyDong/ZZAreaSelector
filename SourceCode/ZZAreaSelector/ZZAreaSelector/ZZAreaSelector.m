//
//  ZZAreaSelector.m
//  ZZAddressSelector
//
//  Created by Zhang_yD on 2017/3/20.
//  Copyright © 2017年 Z. All rights reserved.
//

#import "ZZAreaSelector.h"
#import "ChineseToPinyin.h"
#import "JSONKit.h"
#import "UIView+ZZAddressExtension.h"
#import "UIColor+ZZAddressExtension.h"
#import "UILabel+ZZAddressExtension.h"

@interface ZZAreaSelector ()

@property (nonatomic, weak) UIView *whiteView;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIView *closeView;

@property (nonatomic, weak) UILabel *provinceLabel;
@property (nonatomic, weak) UILabel *cityLabel;
@property (nonatomic, weak) UILabel *areaLabel;
@property (nonatomic, weak) UIView *line;

@end


@interface ZZAreaSelector (Private)
- (void)zp_setup;
- (UILabel *)zp_addLabel:(UIView *)view text:(NSString *)text index:(NSInteger)index;
- (void)zp_tagClick:(UITapGestureRecognizer *)tgr;
- (void)zp_reloadDatas;
- (void)zp_showAnimation;
- (void)zp_hideAnimation;
- (void)zp_sendDelegateAndClose;
- (BOOL)zp_checkReloadEnable;
- (void)zp_handleTagLabelText;
- (void)zp_preDataHandle;
@end

@interface ZZAreaSelector (Files)
- (void)zp_loadFiles;  // 读取本地文件
- (NSArray *)zp_currentDataArray; // 根据关键字寻找对应数据数组
- (void)zp_handleDatasWithDataArray:(NSArray *)array; // 对数组中的数据进行处理 新构成的数据中元素为字典
@end

@interface ZZAreaSelector (UITableView) <UITableViewDelegate, UITableViewDataSource>
@end


@implementation ZZAreaSelector
{
    NSArray *_originDatas; // 初始数组 加载本地数据，用于查询
    NSArray *_showDatas; // 显示数组，经过originDatas查询的结果集
    
    // 0-省 1-市 2-区
    NSInteger _currentIndex; // 当前标记的位置 变化前的位置
    NSInteger _changeIndex;  // 将要变化的目标位置
    
    
    NSString *_province;
    NSString *_city;
    NSString *_area;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.alpha = 0;
        [self zp_setup];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    self.frame = newSuperview.bounds;
}

- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    // 读取文件
    [self zp_loadFiles];
    [self zp_showAnimation];
}

@end


@implementation ZZAreaSelector (Private)

- (void)setAreaType:(ZZAreaType)areaType {
    _areaType = areaType;
    if (areaType == ZZAreaTypeCity && _areaLabel) {
        [_areaLabel removeFromSuperview];
    }
}

- (void)zp_setup {
    UIView *wView = [[UIView alloc] init];
    [self addSubview:wView];
    _whiteView = wView;
    wView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 400);
    wView.backgroundColor = [UIColor whiteColor];
    
    _provinceLabel = [self zp_addLabel:wView text:@"" index:0];
    _cityLabel = [self zp_addLabel:wView text:@"" index:1];
    _areaLabel = [self zp_addLabel:wView text:@"" index:2];
    
    UIView *gLine = [[UIView alloc] init];
    [wView addSubview:gLine];
    gLine.backgroundColor = kColor(0xdddddd);
    gLine.frame = CGRectMake(0, self.provinceLabel.maxY, wView.width, 1);
    
    UIView *line = [[UIView alloc] init];
    [wView addSubview:line];
    line.backgroundColor = kColor(0xff3939);
    line.y = gLine.y - 1;
    line.height = 3;
    line.width = 26;
    self.line = line;
    line.centerX = self.provinceLabel.centerX;
    
    UITableView *tableView = [[UITableView alloc] init];
    [wView addSubview:tableView];
    tableView.frame = CGRectMake(0, gLine.maxY, wView.width, wView.height - gLine.maxY);
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    tableView.sectionIndexColor = kColor(0x2a2a2b);
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 40;
    
    UIView *closeView = [[UIView alloc] init];
    [self addSubview:closeView];
    closeView.backgroundColor = [UIColor clearColor];
    closeView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - wView.height);
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zp_hideAnimation)];
    [closeView addGestureRecognizer:closeTap];
}

- (UILabel *)zp_addLabel:(UIView *)view text:(NSString *)text index:(NSInteger)index {
    UILabel *label = [[UILabel alloc] init];
    [view addSubview:label];
    label.font = [UIFont systemFontOfSize:15];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = CGRectMake(10 + index * 50, 0, 50, 50);
    label.userInteractionEnabled = YES;
    label.tag = index;
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zp_tagClick:)];
    [label addGestureRecognizer:tgr];
    return label;
}

- (void)zp_tagClick:(UITapGestureRecognizer *)tgr {
    _changeIndex = tgr.view.tag;
    [self zp_reloadDatas];
}

- (void)zp_reloadDatas {
    [self zp_preDataHandle];
    if (![self zp_checkReloadEnable]) return;
    [self zp_handleTagLabelText];
    
    if (_showDatas) {
        _showDatas = nil;
        [_tableView reloadData];
    }
    
    _currentIndex = _changeIndex;
    
    NSArray *dataArray = [self zp_currentDataArray];
    [self zp_handleDatasWithDataArray:dataArray];
    
    [self.tableView reloadData];
    NSIndexSet *newSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _tableView.numberOfSections)];
    [self.tableView reloadSections:newSet withRowAnimation:UITableViewRowAnimationFade];
}

- (void)zp_preDataHandle {
    if (_changeIndex < _currentIndex) {
        if (_changeIndex == 0) {
            _province = nil;
            _city = nil;
            _area = nil;
        } else if (_changeIndex == 1) {
            _city = nil;
            _area = nil;
        }
    }
}

- (BOOL)zp_checkReloadEnable {
    if (_showDatas && _currentIndex == _changeIndex) return NO;
    if (!_province && _changeIndex > 0) return NO;
    if (!_city && _changeIndex > 1) return NO;
    return YES;
}

- (void)zp_handleTagLabelText {
    _provinceLabel.text = _province ? _province : @"省份";
    _provinceLabel.textColor = kColor(0x2a2a2b);
    _cityLabel.text = _city ? _city : @"城市";
    _cityLabel.textColor = [self zp_colorForEnable:_changeIndex >= 1];
    if (_areaLabel) {
        _areaLabel.text = _area ? _area : @"地区";
        _areaLabel.textColor = [self zp_colorForEnable:_changeIndex >= 2];
    }
    [self zp_reFrameTagLabels];
}

- (void)zp_reFrameTagLabels {
    [UIView animateWithDuration:0.5 animations:^{
        _provinceLabel.width = MAX(50, _provinceLabel.labelWidth + 10);
        _cityLabel.x = _provinceLabel.maxX + 10;
        _cityLabel.width = MAX(50, _cityLabel.labelWidth + 10);
        if (_areaLabel) {
            _areaLabel.x = _cityLabel.maxX + 10;
            _areaLabel.width = MIN(ScreenWidth - _cityLabel.maxX - 20, MAX(50, _areaLabel.labelWidth + 10));
        }
    }];
    
    CGFloat lineCenterX;
    if (_changeIndex == 0) {
        lineCenterX = _provinceLabel.centerX;
    } else if (_changeIndex == 1) {
        lineCenterX = _cityLabel.centerX;
    } else {
        lineCenterX = _areaLabel.centerX;
    }
    [UIView animateWithDuration:0.5 animations:^{
        _line.centerX = lineCenterX;
    }];
}

- (UIColor *)zp_colorForEnable:(BOOL)enable {
    return enable ? kColor(0x2a2a2b) : kColor(0xc6c7cc);
}

- (void)zp_showAnimation {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
        _whiteView.y = ScreenHeight - _whiteView.height;
    }];
}

- (void)zp_hideAnimation {
    [UIView animateWithDuration:0.3 animations:^{
        _whiteView.y = ScreenHeight;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)zp_sendDelegateAndClose {
    if ([_delegate respondsToSelector:@selector(areaSelector:didSelectWithProvince:city:area:)]) {
        [self.delegate areaSelector:self didSelectWithProvince:_province city:_city area:_area];
    }
    [self zp_hideAnimation];
}

@end


@implementation ZZAreaSelector (Files)
- (void)zp_loadFiles {
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"province" ofType:@"txt"];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *textFile  = [NSString stringWithContentsOfFile:filePath encoding:enc error:nil];
    _originDatas = [textFile objectFromJSONString];
    _currentIndex = 0;
    _changeIndex = 0;
    [self zp_reloadDatas];
}

- (NSArray *)zp_currentDataArray {
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    if (_currentIndex == 0) {
        for (NSDictionary *dict in _originDatas) {
            [mArray addObject:dict[@"name"]];
        }
    } else if (_currentIndex == 1) {
        for (NSDictionary *province in _originDatas) {
            if ([province[@"name"] isEqualToString:_province]) {
                for (NSDictionary *citys in province[@"city"]) {
                    [mArray addObject:citys[@"name"]];
                }
                break;
            }
        }
    } else {
        for (NSDictionary *province in _originDatas) {
            if ([province[@"name"] isEqualToString:_province]) {
                for (NSDictionary *citys in province[@"city"]) {
                    if ([citys[@"name"] isEqualToString:_city]) {
                        [mArray addObjectsFromArray:citys[@"area"]];
                        break;
                    }
                }
                break;
            }
        }
    }
    return mArray;
}

- (void)zp_handleDatasWithDataArray:(NSArray *)array {
    // 创建空数组
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (int i = 'A'; i <= 'Z'; i++) {
        NSDictionary *dict = @{@"letter" : [NSString stringWithFormat:@"%c", i],
                               @"words" : [[NSMutableArray alloc] init]};
        [dataArray addObject:dict];
    }
    
    // 分组
    for (int i = 0; i < array.count; i++) {
        
        NSString *chn = array[i];
        NSString *pinyin = [ChineseToPinyin pinyinFromChiniseString:chn];
        if ([pinyin isEqualToString:@"ZHONGQING"]) {
            pinyin = @"CHONGQING";
        }
        char letter = [pinyin characterAtIndex:0];
        int index = letter - 'A';
        NSDictionary *tmpDict = dataArray[index];
        NSMutableArray *tmpArray = tmpDict[@"words"];
        [tmpArray addObject:chn];
    }
    
    // 删除空数组
    for (NSInteger i = dataArray.count - 1; i >= 0; i--) {
        NSDictionary *dict = dataArray[i];
        if ([dict[@"words"] count] == 0) {
            [dataArray removeObject:dict];
        }
    }
    _showDatas = dataArray;
}

@end

@implementation ZZAreaSelector (UITableView)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _showDatas.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _showDatas[section][@"letter"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_showDatas[section][@"words"] count];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *sectionTitles = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in _showDatas) {
        [sectionTitles addObject:dict[@"letter"]];
    }
    return sectionTitles;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellName = @"ShowCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        [cell.textLabel setTextColor:kColor(0x2a2a2b)];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
    }
    NSArray *arr = _showDatas[indexPath.section][@"words"];
    cell.textLabel.text = arr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *str = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    if (_currentIndex == 0) {
        _province = str;
        _changeIndex = 1;
    } else if (_currentIndex == 1) {
        _city = str;
        if (_areaType == ZZAreaTypeCity) {
            [self zp_sendDelegateAndClose];
            return;
        }
        _changeIndex = 2;
    } else {
        _area = str;
        [self zp_sendDelegateAndClose];
        return;
    }
    [self zp_reloadDatas];
}
@end
