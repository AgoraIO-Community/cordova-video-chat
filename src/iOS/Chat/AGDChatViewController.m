//
//  AGDChatViewController.m
//  AgoraDemo
//
//  Created by apple on 15/9/9.
//  Copyright (c) 2015年 Agora. All rights reserved.
//
#import "agora.h"
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import <AgoraRtcEngineKit/AgoraEnumerates.h>
#import "AGDChatViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
@interface AGDChatViewController ()
{
    __block AgoraChannelStats *lastStat_;
    void (^_completionHandler)(NSString* someParameter, NSString* otherParameter );
}

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *speakerControlButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *audioMuteControlButtons;

// 从 tutoral借来
@property (weak, nonatomic) IBOutlet UIView *controlButtons;
@property (weak, nonatomic) IBOutlet UIImageView *remoteVideoMutedIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *localVideoMutedBg;
@property (weak, nonatomic) IBOutlet UIImageView *localVideoMutedIndicator;


@property (weak, nonatomic) IBOutlet UIButton *cameraControlButton;
@property (weak, nonatomic) IBOutlet UIView *videoSelfView;
@property (weak, nonatomic) AgoraRtcVideoCanvas  *videoCanvasSelfView;

@property (weak, nonatomic) IBOutlet UIView *audioControlView;
@property (weak, nonatomic) IBOutlet UIView *videoControlView;

@property (weak, nonatomic) IBOutlet UIView *videoMainView;
@property (weak, nonatomic) AgoraRtcVideoCanvas  *videoCanvasMainView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UILabel *talkTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dataTrafficLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;

@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIButton *audioMuteButton;
@property (weak, nonatomic) IBOutlet UIButton *videoMuteButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraSwitchButton;
@property(nonatomic) CGRect localFrame;
@property(nonatomic) CGRect localBounds;
@property(nonatomic) CGPoint localCenter;
@property(nonatomic) CGAffineTransform localTransform;
@property (strong, nonatomic) NSMutableArray *uids;
@property (strong, nonatomic) NSMutableDictionary *videoMuteForUids;

//
@property (assign, nonatomic) AGDChatType type;
@property (strong, nonatomic) IBOutlet UIView *selfView;
@property (strong, nonatomic) IBOutlet UIView *RemoteView;


@property (strong, nonatomic) NSString *channel;
@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *peerAccount;
@property (strong, nonatomic) NSString *account;
@property (strong, nonatomic) NSString *peerAccountName;
@property (assign, nonatomic) BOOL agoraVideoEnabled;
@property (strong, nonatomic) NSTimer *durationTimer;
@property (nonatomic) NSUInteger duration;
@property (assign, nonatomic) int chatMode;

@property (assign, nonatomic) BOOL peerJoined;
@property (strong, nonatomic) UIAlertView *errorKeyAlert;
@property (assign, nonatomic) BOOL is_lecture_mode;
@property (assign, nonatomic) int selfUid;
@property (assign, nonatomic) NSInteger listenerCounter;



@end

@implementation AGDChatViewController

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    return self;
}
-(void) setAppId:(NSString *)appId
{
    _appId = appId;
}
-(void) setChatMode:(int)chatMode
{
    _chatMode = chatMode;
}
-(void) setToken:(NSString *)token
{
    _token = token;
}

-(void) setPeerAccount:(NSString *)peerAccount
{
    _peerAccount = peerAccount;
}
-(void) setAccount:(NSString *)account
{
    _account = account;
}
-(void) setPeerAccountName:(NSString *)peerAccountName
{
    _peerAccountName = peerAccountName;
}



-(void)setChn:(NSString *)channel
{
    _channel = channel;
}

-(void) setCallback:(void (^)(NSString *, NSString *))handler
{
    _completionHandler = [handler copy];
}

-(void) setSignalEngine: (AgoraAPI*) signalEngine;
{
    
    _signalEngine = signalEngine;
}

-(void) setLecture: (BOOL) is_lecture
{
    _is_lecture_mode = is_lecture;
}
-(void) setUid: (int) uid
{
    _selfUid=uid;
}

-(BOOL)shouldAutorotate
{
    
    return NO;
}

-(NSUInteger)supportedInterfaceOrientation

{
    
    return UIInterfaceOrientationPortrait;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    
    self.uids = [NSMutableArray array];
    self.videoMuteForUids = [NSMutableDictionary dictionary];
    self.type = AGDChatTypeVideo;
    //    self.videoSelfView.hidden = true;
    self.peerJoined = false;
    self.title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"room", nil), self.channel];
    //    [self selectSpeakerButtons:YES];
    [self initAgoraKit];
    
    //    NSString *path = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] pathForResource:@"Tock" ofType:@"aiff"];
    //SystemSoundID soundID;
    //    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    //AudioServicesPlaySystemSound(soundID);
    //AudioServicesDisposeSystemSoundID(soundID);
    
    NSLog(@"self: %@", self);
}
-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    self.videoSelfView.frame = self.videoSelfView.superview.bounds; // video view's autolayout cause crash
    [self joinChannel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of asny resources that can be recreated.
}

#pragma mark -


- (void)initAgoraKit
{
    // use test key
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:self.appId delegate:self];
    
    //    self.agoraKit = [[AgoraRtcEngineKit alloc] initWithVendorKey:self.vendorKey error:^(AgoraRtcErrorCode errorCode) {
    //        if (errorCode == AgoraRtc_Error_InvalidVendorKey) {
    //            [self.agoraKit leaveChannel:nil];
    //            [self.errorKeyAlert show];
    //        }
    //    }];
    
    
    [self.agoraKit setLogFilter:0];
    [self setUpVideo];
    [self setUpBlocks];
}

- (void)joinChannel
{
    __weak __typeof(self) weakSelf = self;
    if(_chatMode == 1){
        
        [self.agoraKit enableVideo];
    }
    else{
        
        [self.agoraKit disableVideo];
    }
    [self.agoraKit joinChannelByToken:_token channelId:_channel info:nil uid:_selfUid joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        
        [weakSelf.agoraKit setEnableSpeakerphone:YES];
        if (weakSelf.type == AGDChatTypeAudio) {
            [weakSelf.agoraKit disableVideo];
        }
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        NSDictionary *jsonDictionary = @{
                                         @"channel" : channel,
                                         @"uid" :  @(uid),
                                         @"elapsed" :  @(elapsed)
                                         
                                         };
        NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
        
        _completionHandler(@"onJoinChannelSuccess", jsonString);
        NSLog(@"success");
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:weakSelf.appId forKey:AGDKeyVendorKey];
    }];
}

- (void)setUpVideo
{
    __weak __typeof(self) weakSelf = self;
    [self.agoraKit enableVideo];
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    self.videoCanvasSelfView = videoCanvas;
    if(!_is_lecture_mode) {
        
        
        self.localFrame = self.videoSelfView.frame; //[self setFrame:(CGRect){.origin = position,.size = self.frame.size}];
        self.localBounds = self.videoSelfView.bounds;
        self.localCenter = self.videoSelfView.center;
        self.localTransform = self.videoSelfView.transform;
        
        if(_chatMode == 1){
            
            videoCanvas.uid = 0;
            //      weakSelf.videoSelfView.frame = weakSelf.videoMainView.superview.bounds;
            videoCanvas.view = self.videoSelfView;
            videoCanvas.renderMode = AgoraVideoRenderModeHidden;
            
            if([self.agoraKit setupLocalVideo:videoCanvas]<0) NSLog(@"failed local view");
            
            [[UIApplication sharedApplication].keyWindow bringSubviewToFront:weakSelf.videoSelfView];
            self.localVideoMutedIndicator.hidden = true;
            self.localVideoMutedBg.hidden = true;
        }
        else{
            
            [self hideOnAudioMode];
        }
        
        [self showAlertLabelWithString:@"等待对方加入"];
        
        
        
    } else {
        if(_selfUid == 10000) {
            _listenerCounter = 0;
            [self showAlertLabelWithString: @"Waiting for audience"];
            
            videoCanvas.uid = 10000;
            videoCanvas.view = self.videoMainView;
            videoCanvas.renderMode = AgoraVideoRenderModeHidden ;
            //            weakSelf.videoMainView.frame = weakSelf.videoMainView.superview.bounds;
            if([self.agoraKit setupLocalVideo:videoCanvas]<0) NSLog(@"failed local view");
        } else {
            [self showAlertLabelWithString:NSLocalizedString(@"Waiting for the lecturer", nil)];
        }
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed
{
    NSLog(@"local video display");
    __weak __typeof(self) weakSelf = self;
    if(self.peerJoined){
        weakSelf.videoMainView.frame = weakSelf.videoMainView.superview.bounds;
        
    }
    else{
        
        weakSelf.videoSelfView.frame = weakSelf.videoSelfView.superview.bounds;
    }
    // video view's autolayout cause crash
    //
}
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed

{
    self.peerJoined = true;
    __weak __typeof(self) weakSelf = self;
    NSLog(@"self: %@", weakSelf);
    NSLog(@"engine: %@", engine);
    //    [weakSelf hideAlertLabel];
    //    [weakSelf.uids addObject:@(uid)];
    //
    //    [weakSelf.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.uids.count-1 inSection:0]]];
    if(!_is_lecture_mode || (_selfUid != 10000 && uid == 10000)) {
        //        [self showAlertLabelWithString:@""];
        //        self.videoMainView.hidden = false;
        //
        
        //
        //
        //        AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
        //        self.videoCanvasMainView = videoCanvas;
        //        videoCanvas.uid = uid;
        //        videoCanvas.view = self.videoMainView;
        //        videoCanvas.renderMode = AgoraVideoRenderModeHidden ;
        //        weakSelf.videoMainView.frame = weakSelf.videoMainView.superview.bounds;
        //        if([self.agoraKit setupRemoteVideo:videoCanvas]<0) NSLog(@"fail");
        //
        //
        //        if([self.agoraKit setupLocalVideo:self.videoCanvasSelfView]<0) NSLog(@"fail");
        
        if(_chatMode == 1){
            
            self.videoSelfView.frame = self.localFrame;
            //self.videoSelfView.bounds = self.localBounds;
            // self.videoSelfView.center = self.localCenter;
            //self.videoSelfView.transform = self.localTransform;
            [self showAlertLabelWithString:@""];
            self.videoMainView.hidden = false;
            self.remoteVideoMutedIndicator.hidden = true;
            AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
            videoCanvas.uid = uid;
            videoCanvas.view = self.videoMainView;
            videoCanvas.renderMode = AgoraVideoRenderModeHidden ;
            weakSelf.videoMainView.frame = weakSelf.videoMainView.superview.bounds;
            if([self.agoraKit setupRemoteVideo:videoCanvas]<0) NSLog(@"fail");
            //        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:weakSelf.videoMainView];
        }
        
        
        
    }
    if(_selfUid == 10000 && _is_lecture_mode) {
        _listenerCounter++;
        if(_listenerCounter == 1) {
            [self showAlertLabelWithString:@"There is 1 person in the room"];
        } else {
            [self showAlertLabelWithString: [NSString stringWithFormat:@"There are %@ people in the room", @(_listenerCounter)]];
        }
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason
{
    
    __weak __typeof(self) weakSelf = self;
    self.peerJoined = false;
    //    NSInteger index = [weakSelf.uids indexOfObject:@(uid)];
    //    if (index != NSNotFound) {
    //        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    //        [weakSelf.uids removeObjectAtIndex:index];
    //        [weakSelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    //    }
    if(!_is_lecture_mode) {
        
        
        
        
        weakSelf.videoSelfView.frame = weakSelf.videoSelfView.superview.bounds;
        [self showAlertLabelWithString: [NSString stringWithFormat:@"等待%@加入", self.peerAccountName]];
    }
    else if(uid == 10000 && _selfUid != 10000) {
        weakSelf.videoMainView.hidden = true;
        [self showAlertLabelWithString: @"Waiting for the lecturer"];
    } else if(_selfUid == 10000 && _is_lecture_mode) {
        _listenerCounter--;
        if(_listenerCounter == 0) {
            [self showAlertLabelWithString:@"Waiting for audience"];
        } else if (_listenerCounter == 1) {
            [self showAlertLabelWithString:@"There is 1 person in the room"];
        } else {
            [self showAlertLabelWithString: [NSString stringWithFormat:@"There are %@ people in the room", @(_listenerCounter)]];
        }
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid
{
    __weak __typeof(self) weakSelf = self;
    NSLog(@"user %@ mute video: %@", @(uid), muted ? @"YES" : @"NO");
    self.remoteVideoMutedIndicator.hidden = !muted;
    [weakSelf.videoMuteForUids setObject:@(muted) forKey:@(uid)];
    [weakSelf.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:[weakSelf.uids indexOfObject:@(uid)] inSection:0]]];
}


- (void)rtcEngineConnectionDidLost:(AgoraRtcEngineKit *)engine
{
    __weak __typeof(self) weakSelf = self;
    [weakSelf showAlertLabelWithString:NSLocalizedString(@"no_network", nil)];
    weakSelf.videoSelfView.hidden = YES;
    weakSelf.dataTrafficLabel.text = @"0KB/s";
    _completionHandler(@"onConnectionLost",@"0KB/s");
}

- (void)rtcEngineVideoDidStop:(AgoraRtcEngineKit *_Nonnull)engine
{
//    if(_chatMode == 1){
//
//        [_agoraKit disableVideo];
//        [self setChatMode:2];
//        [self hideOnAudioMode];
//    }
    
    
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine reportRtcStats:(AgoraChannelStats*)stats
{
    __weak __typeof(self) weakSelf = self;
    // Update talk time
    if (weakSelf.duration == 0 && !weakSelf.durationTimer) {
        weakSelf.talkTimeLabel.text = @"00:00";
        weakSelf.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(updateTalkTimeLabel) userInfo:nil repeats:YES];
    }
    
    NSUInteger traffic = (stats.txBytes + stats.rxBytes - lastStat_.txBytes - lastStat_.rxBytes) / 1024;
    NSUInteger speed = traffic / (stats.duration - lastStat_.duration);
    NSString *trafficString = [NSString stringWithFormat:@"%@KB/s", @(speed)];
    weakSelf.dataTrafficLabel.text = trafficString;
    
    lastStat_ = stats;
    
    NSDictionary *jsonDictionary = @{
                                     @"trafficString" : trafficString,
                                     @"totalDuration" : @(stats.duration)
                                     
                                     };
    NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
    _completionHandler(@"onRtcStats",jsonString);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraErrorCode)errorCode
{
    NSDictionary *jsonDictionary = @{
                                     @"errorCode":[[NSNumber numberWithInt:((unsigned long)errorCode)] stringValue]
                                     
                                     };
    NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
    _completionHandler(@"onError",jsonString);
    
    __weak __typeof(self) weakSelf = self;
    if (errorCode == AgoraErrorCodeInvalidAppId) {
        [weakSelf.agoraKit leaveChannel:nil];
        [weakSelf.errorKeyAlert show];
    }
}

- (void)setUpBlocks
{
    //    [self.agoraKit rtcStatsBlock:^(AgoraRtcStats *stat) {
    //        // Update talk time
    //        if (self.duration == 0 && !self.durationTimer) {
    //            self.talkTimeLabel.text = @"00:00";
    //            self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTalkTimeLabel) userInfo:nil repeats:YES];
    //        }
    
    //        NSUInteger traffic = (stat.txBytes + stat.rxBytes - lastStat_.txBytes - lastStat_.rxBytes) / 1024;
    //        NSUInteger speed = traffic / (stat.duration - lastStat_.duration);
    //        NSString *trafficString = [NSString stringWithFormat:@"%@KB/s", @(speed)];
    //        self.dataTrafficLabel.text = trafficString;
    
    //        lastStat_ = stat;
    
    //        NSDictionary *jsonDictionary = @{
    //                                      @"trafficString" : trafficString
    
    
    //                                     };
    //         NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
    //         _completionHandler(@"onRtcStats",jsonString);
    
    //    }];
    
    [self.agoraKit rejoinChannelSuccessBlock:^(NSString* channel,NSUInteger uid, NSInteger elapsed) {
        
        
        NSDictionary *jsonDictionary = @{
                                         @"channel" : channel,
                                         @"uid" :  @(uid),
                                         @"elapsed" :  @(elapsed),
                                         };
        NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
        _completionHandler(@"onRejoinChannelSuccess",jsonString);
    }];
    
    
    
    
    
    //    [self.agoraKit userJoinedBlock:^(NSUInteger uid, NSInteger elapsed) {
    //        [self hideAlertLabel];
    //        [self.uids addObject:@(uid)];
    //
    //        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.uids.count-1 inSection:0]]];
    //
    //        NSDictionary *jsonDictionary = @{
    //
    //                                         @"uid" :  @(uid),
    //                                         @"elapsed" :  @(elapsed),
    //                                         };
    //        NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
    //        _completionHandler(@"onUserJoined",jsonString);
    //    }];
    
    //    [self.agoraKit userOfflineBlock:^(NSUInteger uid) {
    //        NSInteger index = [self.uids indexOfObject:@(uid)];
    //        if (index != NSNotFound) {
    //            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    //            [self.uids removeObjectAtIndex:index];
    //            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    //        }
    //
    //        NSDictionary *jsonDictionary = @{
    //
    //                                         @"uid" :  @(uid)
    //
    //                                         };
    //        NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
    //        _completionHandler(@"onUserOffline",jsonString);
    //    }];
    
    
    
    [self.agoraKit connectionLostBlock:^{
        [self showAlertLabelWithString:NSLocalizedString(@"no_network", nil)];
        self.videoMainView.hidden = YES;
        self.dataTrafficLabel.text = @"0KB/s";
        
        NSDictionary *jsonDictionary = @{};
        NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
        _completionHandler(@"onConnectionLost",jsonString);
    }];
    
    //    [self.agoraKit userMuteVideoBlock:^(NSUInteger uid, BOOL muted) {
    //        NSLog(@"user %@ mute video: %@", @(uid), muted ? @"YES" : @"NO");
    //
    //        [self.videoMuteForUids setObject:@(muted) forKey:@(uid)];
    //        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.uids indexOfObject:@(uid)] inSection:0]]];
    //        NSDictionary *jsonDictionary = @{
    //                                         @"uid":@(uid),
    //                                         @"muted":muted? @"YES":@"NO"
    //                                         };
    //        NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
    //        _completionHandler(@"onUserMuteVideo",jsonString);
    //
    //    }];
    
    //    [self.agoraKit firstLocalVideoFrameBlock:^(NSInteger width, NSInteger height, NSInteger elapsed) {
    //        NSLog(@"local video display");
    //        self.videoMainView.frame = self.videoMainView.superview.bounds; // video view's autolayout cause crash
    //
    //        NSDictionary *jsonDictionary = @{
    //                                         @"width":@(width),
    //                                         @"height":[NSString stringWithFormat: @"%ld", (long)height],
    //                                         @"elapsed":[NSString stringWithFormat: @"%ld", (long)elapsed]
    //                                         };
    //        NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
    //        _completionHandler(@"onFirstLocalVideoFrame",jsonString);
    //
    //    }];
}
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurWarning:(AgoraWarningCode)warningCode{
    NSDictionary *jsonDictionary = @{
                                     @"warningCode":[[NSNumber numberWithInt:((unsigned long)warningCode)] stringValue]
                                     
                                     };
    NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
    _completionHandler(@"onWarning",jsonString);
    
    
}


- (void)rtcEngineConnectionDidInterrupted:(AgoraRtcEngineKit *)engine
{
    
    NSDictionary *jsonDictionary = @{
                                     
                                     
                                     };
    NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
    _completionHandler(@"onConnectionInterrupted",jsonString);
    
}



#pragma mark -

- (void)showAlertLabelWithString:(NSString *)text;
{
    self.alertLabel.hidden = NO;
    self.alertLabel.text = text;
}

- (void)hideAlertLabel
{
    self.alertLabel.hidden = YES;
}

- (void)updateTalkTimeLabel
{
    self.duration++;
    NSUInteger seconds = self.duration % 60;
    NSUInteger minutes = (self.duration - seconds) / 60;
    self.talkTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (unsigned long)minutes, (unsigned long)seconds];
}

#pragma mark -



- (void)resetHideButtonsTimer {
    [AGDChatViewController cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideControlButtons) withObject:nil afterDelay:3];
}
- (void)hideControlButtons {
    //self.controlButtons.hidden = true;
}
- (IBAction) showControlButtons:(UIView*)view {
    self.controlButtons.hidden = false;
}
// - (IBAction)didClickSpeakerButton:(UIButton *)btn
// {
//     [self.agoraKit setEnableSpeakerphone:!self.agoraKit.isSpeakerphoneEnabled];
//     [self selectSpeakerButtons:!self.agoraKit.isSpeakerphoneEnabled];
// }

- (IBAction)didClickAudioMuteButton:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    
    [self.agoraKit setEnableSpeakerphone:sender.selected];
    [self resetHideButtonsTimer];
}

- (IBAction)didClickVideoMuteButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.agoraKit muteLocalVideoStream:sender.selected];
    self.videoSelfView.hidden = sender.selected;
    //    self.localVideoMutedBg.hidden = !sender.selected;
    self.localVideoMutedIndicator.hidden = !sender.selected;
    [self resetHideButtonsTimer];
}




// - (IBAction)didClickSwitchButton:(UIButton *)btn
// {
//     [self.agoraKit switchCamera];
// }

- (IBAction)didClickSwitchCameraButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.agoraKit switchCamera];
    [self resetHideButtonsTimer];
}


- (IBAction)didClickHungUpButton:(UIButton *)btn
{
    int uid = 0;
    
    [self.signalEngine   channelInviteEnd:self.channel account:self.peerAccount uid:uid];
    [self finishChat];
    
    
    
}


- (void) finishChat{
    [self showAlertLabelWithString:@"退出"];
    __weak __typeof(self) weakSelf = self;
    [self.agoraKit leaveChannel:^(AgoraChannelStats *stat) {
        // Myself leave status
        [weakSelf.durationTimer invalidate];
        [weakSelf.navigationController popViewControllerAnimated:YES];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }];
    [self dismissViewControllerAnimated:true completion:Nil];
}
- (void) disableVideo{
    [self showAlertLabelWithString:@"退出"];
    __weak __typeof(self) weakSelf = self;
    [self.agoraKit disableVideo];
    [self hideOnAudioMode];
}

- (IBAction)didClickBackView:(id)sender
{
    [self showAlertLabelWithString:NSLocalizedString(@"exiting", nil)];
    __weak __typeof(self) weakSelf = self;
    [self.agoraKit leaveChannel:^(AgoraChannelStats *stat) {
        // Myself leave status
        [weakSelf.durationTimer invalidate];
        [weakSelf.navigationController popViewControllerAnimated:YES];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }];
}


- (IBAction)didClickAudioButton:(UIButton *)btn
{
    // Start audio chat
    [self.agoraKit disableVideo];
    self.type = AGDChatTypeAudio;
}

- (IBAction)didClickVideoButton:(UIButton *)btn
{
    // Start video chat
    [self.agoraKit enableVideo];
    self.type = AGDChatTypeVideo;
    if (self.cameraControlButton.selected) {
        self.cameraControlButton.selected = NO;
    }
}

#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.uids.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AGDChatCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    cell.type = self.type;
    
    // Get info
    NSNumber *uid = [self.uids objectAtIndex:indexPath.row];
    NSNumber *videoMute = [self.videoMuteForUids objectForKey:uid];
    
    if (self.type == AGDChatTypeVideo) {
        if (videoMute.boolValue) {
            cell.type = AGDChatTypeAudio;
        } else {
            cell.type = AGDChatTypeVideo;
            AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
            videoCanvas.uid = uid.unsignedIntegerValue;
            videoCanvas.view = cell.videoView;
            videoCanvas.renderMode = AgoraVideoRenderModeHidden ;
            [self.agoraKit setupRemoteVideo:videoCanvas];
        }
    } else {
        cell.type = AGDChatTypeAudio;
    }
    
    // Audio
    cell.nameLabel.text = uid.stringValue;
    return cell;
}

#pragma mark -

- (void)setType:(AGDChatType)type
{
    _type = type;
    if (type == AGDChatTypeVideo) {
        // Control buttons
        self.videoControlView.hidden = NO;
        self.audioControlView.hidden = YES;
        
        // Video/Audio switch button
        self.videoButton.selected = YES;
        self.audioButton.selected = NO;
        
        //
        self.videoMainView.hidden = NO;
    } else {
        // Control buttons
        self.videoControlView.hidden = YES;
        self.audioControlView.hidden = NO;
        
        // Video/Audio switch button
        self.videoButton.selected = NO;
        self.audioButton.selected = YES;
        
        //
        self.videoMainView.hidden = YES;
    }
    [self.collectionView reloadData];
}

- (void)selectSpeakerButtons:(BOOL)selected
{
    for (UIButton *btn in self.speakerControlButtons) {
        btn.selected = selected;
    }
}

- (void)selectAudioMuteButtons:(BOOL)selected
{
    for (UIButton *btn in self.audioMuteControlButtons) {
        btn.selected = selected;
    }
}

- (UIAlertView *)errorKeyAlert
{
    if (!_errorKeyAlert) {
        _errorKeyAlert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:NSLocalizedString(@"wrong_key", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"done", nil)
                                          otherButtonTitles:nil];
    }
    return _errorKeyAlert;
}

-(void)dismissMyselfCompletely
{
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}


- (void) hideOnAudioMode{
        self.localVideoMutedIndicator.hidden = false;
    self.localVideoMutedBg.hidden = true;
    //     self.remoteVideoMutedIndicator.hidden = true;
    self.videoSelfView.hidden = true;
    self.videoMainView.hidden = true;
    self.remoteVideoMutedIndicator.hidden = false;
    self.videoMuteButton.hidden = true;
    self.cameraSwitchButton.hidden=true;
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didVideoEnabled:(BOOL)enabled byUid:(NSUInteger)uid{
    
//    if(_chatMode == 1){
//
//        [self.agoraKit enableVideo];
//    }
//    else{
//
//        [self.agoraKit disableVideo];
//    }
    
}

@end
