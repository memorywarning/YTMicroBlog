//
//  HYTStatusFrame.m
//  无法修盖
//
//  Created by HelloWorld on 15/12/4.
//  Copyright (c) 2015年 SearchPrefect. All rights reserved.
//

#define HYTStatusFrameNameFont [UIFont systemFontOfSize:15]

#import "HYTStatusFrame.h"
#import "HYTStatusPicturesView.h"

@implementation HYTStatusFrame

static CGFloat HYTStatusFrameMargin = 8;  //Cell之间的间距
const CGFloat HYTStatusFrameNormalMargin = 8;  //普通内容的间距
const CGFloat HYTStatusFrameSmallMargin  = 5;  //小间距 （用户名-时间、时间-来源）

//static CGFloat kVerticalMargin = 25;    //距离边框的竖直距离(暂时弃用)
+ (instancetype)statusFrameWithStatus:(HYTStatus *)status {
    
    HYTStatusFrame *statusFrame = [[self alloc] init];
    statusFrame.status = status;
    return statusFrame;
}

- (void)setStatus:(HYTStatus *)status {
    
    _status = status;
    HYTUser *user = status.user;
    
    CGFloat cellHeight = 0;
    CGFloat cellWidth = SCREEN_WIDTH;

    /** 用户头像Frame */
    CGFloat iconViewWidth = 38.5;
    CGFloat iconViewHeight = iconViewWidth;
    CGFloat iconViewX = HYTStatusFrameNormalMargin;
    CGFloat iconViewY = HYTStatusFrameNormalMargin;
    self.iconViewF = CGRectMake(iconViewX, iconViewY, iconViewWidth, iconViewHeight);
    
    /** 用户昵称Frame */
    CGFloat nameX = CGRectGetMaxX(self.iconViewF) + HYTStatusFrameNormalMargin;
    CGFloat nameY = iconViewY;
    CGSize nameSize = [user.name yt_sizeWithFont:HYTStatusFrameNameFont];
    self.nameLabelF = (CGRect){{nameX, nameY}, nameSize};
    
    /** 用户会员图标Frame */
    if (user.isVip) {
        CGFloat mbMarkHeight = nameSize.height * 0.8;
        CGFloat mbMarkWidth = mbMarkHeight;
        CGFloat mbMarkX = CGRectGetMaxX(self.nameLabelF) + HYTStatusFrameSmallMargin;
        CGFloat mbMarkY = nameY + (nameSize.height - mbMarkHeight) * 0.5;
        self.mbMarkViewF = CGRectMake(mbMarkX, mbMarkY, mbMarkWidth, mbMarkHeight);
    }
    
    /** 微博创建时间Frame */
    CGFloat createdAtX = nameX;
    CGFloat createdAtY = CGRectGetMaxY(self.nameLabelF) + HYTStatusFrameSmallMargin;
    CGSize createdAtSize = [status.createdAt yt_sizeWithFont:HYTStatusFrameCreatedAtFont];
    self.createdAtLabelF = (CGRect){{createdAtX, createdAtY}, createdAtSize};
    
    /** 微博来源Frame */
    CGFloat sourceX = CGRectGetMaxX(self.createdAtLabelF) + HYTStatusFrameSmallMargin;
    CGFloat sourceY = createdAtY;
    CGSize sourceSize = [status.source yt_sizeWithFont:HYTStatusFrameSourceFont];
    self.sourceLabelF = (CGRect){{sourceX, sourceY}, sourceSize};
    
    /** 微博信息内容Frame */
    CGFloat contentX = iconViewX;
    CGFloat contentY = MAX(CGRectGetMaxY(self.iconViewF), CGRectGetMaxY(self.sourceLabelF)) + HYTStatusFrameNormalMargin;
    CGFloat contentMaxWidth = cellWidth - contentX - HYTStatusFrameNormalMargin;
    CGSize contentSize = [status.text yt_sizeWithFont:HYTStatusFrameContentFont maxWidth:contentMaxWidth];
    self.contentLabelF = (CGRect){{contentX, contentY}, contentSize};

    CGFloat picturesViewX = contentX;
    CGFloat picturesViewY = CGRectGetMaxY(self.contentLabelF);
    CGFloat picturesViewMaxWidth = contentMaxWidth;
    CGSize  picturesViewSize = CGSizeZero;
    if (status.pictures.count) {
        picturesViewY += HYTStatusFrameSmallMargin;
        picturesViewSize = [HYTStatusPicturesView statusPicturesViewWithMaxWidth:picturesViewMaxWidth showCount:status.pictures.count];
    }
    self.picturesViewF = (CGRect){{picturesViewX, picturesViewY}, picturesViewSize};
    
    /** 原创微博Frame */
    self.originalStatusViewF = CGRectMake(0, HYTStatusFrameMargin, cellWidth, CGRectGetMaxY(self.picturesViewF) + HYTStatusFrameNormalMargin);
    cellHeight = CGRectGetMaxY(self.originalStatusViewF);
    
    /***********************转发微博***********************/
    if (status.retweetedStatus) {
        
        HYTStatus *retweetedStatus = status.retweetedStatus;
        CGFloat retweetedContentX = HYTStatusFrameNormalMargin;
        CGFloat retweetedContentY = HYTStatusFrameNormalMargin;
        NSString *retweentContentText = [NSString stringWithFormat:@"%@:%@", retweetedStatus.user.name, retweetedStatus.text];
        CGFloat retweetedMaxWidth = cellWidth - retweetedContentX - HYTStatusFrameNormalMargin;
        CGSize retweetedContentSize = [retweentContentText yt_sizeWithFont:HYTStatusFrameReweetedContentFont maxWidth:retweetedMaxWidth];
        self.retweetedContentLabelF = (CGRect){{retweetedContentX, retweetedContentY}, retweetedContentSize};
        
        CGFloat retweetedPicturesViewX = retweetedContentX;
        CGFloat retweetedPicturesViewY = CGRectGetMaxY(self.retweetedContentLabelF);
        CGFloat retweetedPicturesViewMaxWidth = retweetedMaxWidth;
        CGSize  retweetedPicturesViewSize = CGSizeZero;
        if (retweetedStatus.pictures.count) {
            retweetedPicturesViewY += HYTStatusFrameSmallMargin;
            retweetedPicturesViewSize = [HYTStatusPicturesView statusPicturesViewWithMaxWidth:retweetedPicturesViewMaxWidth showCount:retweetedStatus.pictures.count];
        }
        self.retweetedPicturesViewF = (CGRect){{retweetedPicturesViewX, retweetedPicturesViewY}, retweetedPicturesViewSize};
        
        self.retweetedStatusViewF = CGRectMake(0, cellHeight, cellWidth, CGRectGetMaxY(self.retweetedPicturesViewF)+HYTStatusFrameNormalMargin);
        
        cellHeight = CGRectGetMaxY(self.retweetedStatusViewF);
    }
    
    self.toolBarF = CGRectMake(0, cellHeight, cellWidth, 34);
    
    cellHeight = CGRectGetMaxY(self.toolBarF);
    self.cellTotalHeight = cellHeight;
}

@end
