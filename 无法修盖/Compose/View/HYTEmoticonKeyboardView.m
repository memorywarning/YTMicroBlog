//
//  HYTEmoticonKeyboardView.m
//  无法修盖
//
//  Created by HelloWorld on 16/1/7.
//  Copyright (c) 2016年 SearchPrefect. All rights reserved.
//

#import "HYTEmoticonKeyboardView.h"
#import "HYTEmoticonTabBar.h"
#import "HYTEmoticonListView.h"
#import "HYTEmoticon.h"
#import "HYTRecentEmoticonTool.h"
#import "MJExtension.h"

@interface HYTEmoticonKeyboardView () <HYTEmoticonTabBarDelegate>

@property (nonatomic, weak  ) HYTEmoticonTabBar   *tabBar;

@property (nonatomic, weak  ) HYTEmoticonListView *showingEmoticonView;
@property (nonatomic, strong) HYTEmoticonListView *emoticonRecencyView;
@property (nonatomic, strong) HYTEmoticonListView *emoticonDefaultView;
@property (nonatomic, strong) HYTEmoticonListView *emoticonEmojiView;
@property (nonatomic, strong) HYTEmoticonListView *emoticonLXHView;

@property (nonatomic, strong) NSMutableDictionary *emoticons;

@end

@implementation HYTEmoticonKeyboardView

+ (instancetype)emoticonKeyboard {
    return [[self alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        HYTEmoticonListView *showingEmoticonView = [HYTEmoticonListView listView];
        [self addSubview:showingEmoticonView];
        self.showingEmoticonView = showingEmoticonView;
        
        HYTEmoticonTabBar *tabBar = [HYTEmoticonTabBar tabBar];
        [tabBar setDelegate:self];
        [self addSubview:tabBar];
        self.tabBar = tabBar;
    }
    return self;
}

#pragma mark - 懒加载视图
- (HYTEmoticonListView *)emoticonRecencyView {
    
    if (_emoticonRecencyView == nil) {
        _emoticonRecencyView = [HYTEmoticonListView listView];
    }
    return _emoticonRecencyView;
}

- (HYTEmoticonListView *)emoticonDefaultView {
    
    if (_emoticonDefaultView == nil) {
        _emoticonDefaultView = [HYTEmoticonListView listView];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Emoticons.bundle/com.sina.default/info.plist" ofType:nil];
        NSArray *emoticonArray = [NSDictionary dictionaryWithContentsOfFile:path][@"emoticons"];
        NSArray *emoticons = [HYTEmoticon mj_objectArrayWithKeyValuesArray:emoticonArray];
        [emoticons setValue:@"com.sina.default" forKeyPath:@"idStr"];
        _emoticonDefaultView.emoticons = emoticons;
    }
    return _emoticonDefaultView;
}

- (HYTEmoticonListView *)emoticonEmojiView {
    
    if (_emoticonEmojiView == nil) {
        _emoticonEmojiView = [HYTEmoticonListView listView];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Emoticons.bundle/com.apple.emoji/info.plist" ofType:nil];
        NSArray *emoticonArray = [NSDictionary dictionaryWithContentsOfFile:path][@"emoticons"];
        NSArray *emoticons = [HYTEmoticon mj_objectArrayWithKeyValuesArray:emoticonArray];
        [emoticons setValue:@"com.apple.emoji" forKeyPath:@"idStr"];
        
        _emoticonEmojiView.emoticons = emoticons;
    }
    return _emoticonEmojiView;
}

- (HYTEmoticonListView *)emoticonLXHView {
    
    if (_emoticonLXHView == nil) {
        _emoticonLXHView = [HYTEmoticonListView listView];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Emoticons.bundle/com.sina.lxh/info.plist" ofType:nil];
        NSArray *emoticonArray = [NSDictionary dictionaryWithContentsOfFile:path][@"emoticons"];
        NSArray *emoticons = [HYTEmoticon mj_objectArrayWithKeyValuesArray:emoticonArray];
        [emoticons setValue:@"com.sina.lxh" forKeyPath:@"idStr"];
        _emoticonLXHView.emoticons = emoticons;
    }
    return _emoticonLXHView;
}

#pragma mark - HYTEmoticonTabBarDelegate
- (void)emoticonTabBar:(HYTEmoticonTabBar *)tabBar didSelectedItemBarType:(HYTEmoticonTabBarItemType)itemType {
    
    [self.showingEmoticonView removeFromSuperview];
    
    switch (itemType) {
        case HYTEmoticonTabBarItemTypeRecency: {
            self.emoticonRecencyView.emoticons = [HYTRecentEmoticonTool recentEmoticons];
            self.showingEmoticonView = self.emoticonRecencyView;
            break;
        }
        case HYTEmoticonTabBarItemTypeDefault: {
            self.showingEmoticonView = self.emoticonDefaultView;
            break;
        }
        case HYTEmoticonTabBarItemTypeEmoji: {
            self.showingEmoticonView = self.emoticonEmojiView;
            break;
        }
        case HYTEmoticonTabBarItemTypeLXH: {
            self.showingEmoticonView = self.emoticonLXHView;
            break;
        }
    }
    
    [self addSubview:self.showingEmoticonView];
}

- (void)setShowingEmoticonView:(HYTEmoticonListView *)showingEmoticonView {
    
    [self.showingEmoticonView removeFromSuperview];
    
    _showingEmoticonView = showingEmoticonView;
    
    [self addSubview:showingEmoticonView];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat tabBarHeight = 37;
    [self.tabBar setFrame:CGRectMake(0, self.height-tabBarHeight, self.width, tabBarHeight)];
    [self.showingEmoticonView setFrame:CGRectMake(0, 0, self.width, self.tabBar.y)];
}


 
@end


