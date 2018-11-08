//
//  RoomViewController.h
//  NongXianYunTu
//
//  Created by Qingfeng on 2017/4/21.
//  Copyright © 2017年 rongxinhulian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>

@class RoomViewController;
@protocol RoomVCDelegate <NSObject>
- (void)roomVCNeedClose:(RoomViewController *)roomVC;
@end

@interface RoomViewController : UIViewController
@property (copy, nonatomic) NSString *roomName;
@property (assign, nonatomic) AgoraRtcVideoProfile videoProfile;
@property (weak, nonatomic) id<RoomVCDelegate> delegate;
@end
