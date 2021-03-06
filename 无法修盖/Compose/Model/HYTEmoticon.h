//
//  HYTEmoticon.h
//  无法修盖
//
//  Created by HelloWorld on 16/1/7.
//  Copyright (c) 2016年 SearchPrefect. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYTEmoticon : NSObject <NSCoding>

/** 表情文字的Id */
@property (nonatomic, copy) NSString *idStr;

/** 简体文字 */
@property (nonatomic, copy) NSString *chs;

/** 繁体文字 */
@property (nonatomic, copy) NSString *cht;

/** 表情图 */
@property (nonatomic, copy) NSString *png;

/** emoji表情 */
@property (nonatomic, copy) NSString *code;

@end
