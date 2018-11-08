//
//  VideoViewLayouter.h
//  NongXianYunTu
//
//  Created by Qingfeng on 2017/4/21.
//  Copyright © 2017年 rongxinhulian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoSession.h"

@interface VideoViewLayouter : NSObject
@property (strong, nonatomic) UIView *selfView;
@property (assign, nonatomic) CGSize selfSize;
@property (assign, nonatomic) CGSize targetSize;

@property (strong, nonatomic) NSArray<UIView *> *videoViews;
@property (strong, nonatomic) UIView *fullView;
@property (strong, nonatomic) UIView *containerView;

- (void)layoutVideoViews;
- (NSInteger)responseIndexOfLocation:(CGPoint)location;
@end
