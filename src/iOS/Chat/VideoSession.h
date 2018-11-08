//
//  VideoSession.h
//  NongXianYunTu
//
//  Created by Qingfeng on 2017/4/21.
//  Copyright © 2017年 rongxinhulian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>

@interface VideoSession : NSObject
@property (assign, nonatomic) NSUInteger uid;
@property (strong, nonatomic) UIView *hostingView;
@property (strong, nonatomic) AgoraRtcVideoCanvas *canvas;
@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) BOOL isVideoMuted;

- (instancetype)initWithUid:(NSUInteger)uid;
+ (instancetype)localSession;
@end
