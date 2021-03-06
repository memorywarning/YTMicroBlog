//
//  HYTEmoticonKeyboardCollectionView.m
//  无法修盖
//
//  Created by HelloWorld on 16/2/1.
//  Copyright © 2016年 SearchPrefect. All rights reserved.
//

#import "HYTEmoticonKeyboardCollectionView.h"
#import "HYTEmoticonCollectionView.h"
#import "HYTEmoticonTabBar.h"
#import "HYTEmoticon.h"
#import "MJExtension.h"

@interface HYTEmoticonKeyboardCollectionView () <HYTEmoticonTabBarDelegate>

@property (nonatomic, weak  ) HYTEmoticonTabBar   *tabBar;
@property (nonatomic, weak  ) HYTEmoticonCollectionView *listView;
@property (nonatomic, strong) NSMutableDictionary *emoticonsDict;

@end

@implementation HYTEmoticonKeyboardCollectionView

+ (instancetype)emoticonKeyboard {
    return [[self alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        _emoticonsDict = [NSMutableDictionary dictionary];
        
        HYTEmoticonCollectionView *listView = [HYTEmoticonCollectionView listView];
        [self addSubview:listView];
        self.listView = listView;
        
        HYTEmoticonTabBar *tabBar = [HYTEmoticonTabBar tabBar];
        [tabBar setDelegate:self];
        [self addSubview:tabBar];
        self.tabBar = tabBar;
    }
    return self;
}

#pragma mark - HYTEmoticonTabBarDelegate
- (void)emoticonTabBar:(HYTEmoticonTabBar *)tabBar didSelectedItemBarType:(HYTEmoticonTabBarItemType)itemType {
    
    NSString *emoticonPackageKey = nil;
    switch (itemType) {
        case HYTEmoticonTabBarItemTypeRecency: {
            emoticonPackageKey = @"com.sina.default";
            break;
        }
        case HYTEmoticonTabBarItemTypeDefault: {
            emoticonPackageKey = @"com.sina.default";
            break;
        }
        case HYTEmoticonTabBarItemTypeEmoji: {
            emoticonPackageKey = @"com.apple.emoji";
            break;
        }
        case HYTEmoticonTabBarItemTypeLXH: {
            emoticonPackageKey = @"com.sina.lxh";
            break;
        }
    }
    
    NSArray *emoticons = self.emoticonsDict[emoticonPackageKey];   //表情的模型数组
    if (!emoticons) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Emoticons.bundle" ofType:nil];
        path = [NSString stringWithFormat:@"%@/%@/info.plist", path, emoticonPackageKey];
        
        NSDictionary *emoticonDict = [NSDictionary dictionaryWithContentsOfFile:path];  //表情字典
        NSArray *emoticonArray =  emoticonDict[@"emoticons"];   //表情数组
        
        emoticons = [HYTEmoticon mj_objectArrayWithKeyValuesArray:emoticonArray];
        [self.emoticonsDict setObject:emoticons forKey:emoticonPackageKey];
    }
    self.listView.emoticons = emoticons;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat tabBarHeight = 37;
    [self.tabBar setFrame:CGRectMake(0, self.height-tabBarHeight, self.width, tabBarHeight)];
    [self.listView setFrame:CGRectMake(0, 0, self.width, self.tabBar.y)];
}
@end
