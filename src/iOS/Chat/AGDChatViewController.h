//
//  AGDChatViewController.h
//  AgoraDemo
//
//  Created by apple on 15/9/9.
//  Copyright (c) 2015年 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGDChatCell.h"
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import "AgoraSigKit/AgoraSigKit.h"
@interface AGDChatViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, AgoraRtcEngineDelegate>
-(void) setAppId: (NSString*) appId;
-(void) setChn: (NSString*) channel;
-(void) setPeerAccount: (NSString*) peerAccount;
-(void) setPeerAccountName: (NSString*) peerAccountName;
-(void) setToken: (NSString*) token;
-(void) setCallback: (void(^)(NSString*, NSString*))handler;
-(void) setLecture: (BOOL) is_lecture;
-(void) setUid: (int) uid;
-(void) setChatMode: (int) chatMode;
-(void) setSignalEngine: (AgoraAPI*) signalEngine;
-(void) setAccount: (NSString*) account;
-(void) finishChat;
-(void) disableVideo;
@property(nonatomic,retain) NSDictionary *dictionary;

@property (assign, nonatomic) AGDChatType chatType;
@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;
@property (strong, nonatomic) AgoraAPI *signalEngine;
@end

static NSString * const AGDKeyChannel = @"Channel";
static NSString * const AGDKeyVendorKey = @"VendorKey";
