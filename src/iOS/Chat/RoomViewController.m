//
//  RoomViewController.m
//  NongXianYunTu
//
//  Created by Qingfeng on 2017/4/21.
//  Copyright © 2017年 rongxinhulian. All rights reserved.
//

#import "RoomViewController.h"
#import "VideoSession.h"
#import "VideoViewLayouter.h"
#import "KeyCenter.h"

@interface RoomViewController () <AgoraRtcEngineDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *flowViews;
@property (weak, nonatomic) IBOutlet UILabel *roomNameLabel;

@property (weak, nonatomic) IBOutlet UIView *controlView;

@property (weak, nonatomic) IBOutlet UIButton *muteVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *muteAudioButton;

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *speakerButton;

@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *backgroundTap;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *backgroundDoubleTap;

@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;
@property (strong, nonatomic) NSMutableArray<VideoSession *> *videoSessions;
@property (strong, nonatomic) VideoSession *doubleClickFullSession;
@property (strong, nonatomic) VideoViewLayouter *videoViewLayouter;

@property (assign, nonatomic) BOOL shouldHideFlowViews;
@property (assign, nonatomic) BOOL audioMuted;
@property (assign, nonatomic) BOOL videoMuted;
@property (assign, nonatomic) BOOL speakerEnabled;

@end

@implementation RoomViewController
- (void)setShouldHideFlowViews:(BOOL)shouldHideFlowViews {
    _shouldHideFlowViews = shouldHideFlowViews;
    if (self.flowViews.count) {
        for (UIView *view in self.flowViews) {
            view.hidden = shouldHideFlowViews;
        }
    }
}

- (void)setDoubleClickFullSession:(VideoSession *)doubleClickFullSession {
    _doubleClickFullSession = doubleClickFullSession;
    if (self.videoSessions.count >= 3) {
        [self updateInterfaceWithSessions:self.videoSessions targetSize:self.containerView.frame.size animation:YES];
    }
}

- (VideoViewLayouter *)videoViewLayouter {
    if (!_videoViewLayouter) {
        _videoViewLayouter = [[VideoViewLayouter alloc] init];
    }
    return _videoViewLayouter;
}

- (void)setAudioMuted:(BOOL)audioMuted {
    _audioMuted = audioMuted;
    [self.muteAudioButton setImage:[UIImage imageNamed:(audioMuted ? @"btn_mute_blue" : @"btn_mute")] forState:UIControlStateNormal];
    [self.agoraKit muteLocalAudioStream:audioMuted];
}

- (void)setVideoMuted:(BOOL)videoMuted {
    _videoMuted = videoMuted;
    [self.muteVideoButton setImage:[UIImage imageNamed:(videoMuted ? @"btn_video" : @"btn_voice")] forState:UIControlStateNormal];
    self.cameraButton.hidden = videoMuted;
    self.speakerButton.hidden = !videoMuted;
    
    [self.agoraKit muteLocalVideoStream:videoMuted];
    
    [self setVideoMuted:videoMuted forUid:0];
    [self updateSelfViewVisiable];
}

- (void)setSpeakerEnabled:(BOOL)speakerEnabled {
    _speakerEnabled = speakerEnabled;
    [self.speakerButton setImage:[UIImage imageNamed:(speakerEnabled ? @"btn_speaker_blue" : @"btn_speaker")] forState:UIControlStateNormal];
    [self.speakerButton setImage:[UIImage imageNamed:(speakerEnabled ? @"btn_speaker" : @"btn_speaker_blue")] forState:UIControlStateHighlighted];
    
    [self.agoraKit setEnableSpeakerphone:speakerEnabled];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoSessions = [[NSMutableArray alloc] init];
    
    self.roomNameLabel.text = self.roomName;
    [self.backgroundTap requireGestureRecognizerToFail:self.backgroundDoubleTap];
    
    [self loadAgoraKit];
}

- (IBAction)doMuteVideoPressed:(UIButton *)sender {
    self.videoMuted = !self.videoMuted;
}

- (IBAction)doMuteAudioPressed:(UIButton *)sender {
    self.audioMuted = !self.audioMuted;
}

- (IBAction)doCameraPressed:(UIButton *)sender {
    [self.agoraKit switchCamera];
}

- (IBAction)doSpeakerPressed:(UIButton *)sender {
    self.speakerEnabled = !self.speakerEnabled;
}

- (IBAction)doClosePressed:(UIButton *)sender {
    [self leaveChannel];
}

- (IBAction)doBackTapped:(UITapGestureRecognizer *)sender {
    self.shouldHideFlowViews = !self.shouldHideFlowViews;
}

- (IBAction)doBackDoubleTapped:(UITapGestureRecognizer *)sender {
    if (!self.doubleClickFullSession) {
        NSInteger tappedIndex = [self.videoViewLayouter responseIndexOfLocation:[sender locationInView:self.containerView]];
        if (tappedIndex >= 0 && tappedIndex < self.videoSessions.count) {
            self.doubleClickFullSession = self.videoSessions[tappedIndex];
        }
    } else {
        self.doubleClickFullSession = nil;
    }
}

- (void)updateInterfaceWithSessions:(NSArray *)sessions targetSize:(CGSize)targetSize animation:(BOOL)animation {
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            [self updateInterfaceWithSessions:sessions targetSize:targetSize];
            [self.view layoutIfNeeded];
        }];
    } else {
        [self updateInterfaceWithSessions:sessions targetSize:targetSize];
    }
}

- (void)updateInterfaceWithSessions:(NSArray *)sessions targetSize:(CGSize)targetSize {
    if (!sessions.count) {
        return;
    }
    
    VideoSession *selfSession = sessions.firstObject;
    self.videoViewLayouter.selfView = selfSession.hostingView;
    self.videoViewLayouter.selfSize = selfSession.size;
    self.videoViewLayouter.targetSize = targetSize;
    
    NSMutableArray *peerVideoViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 1; i < sessions.count; ++i) {
        VideoSession *session = sessions[i];
        [peerVideoViews addObject:session.hostingView];
    }
    self.videoViewLayouter.videoViews = peerVideoViews;
    self.videoViewLayouter.fullView = self.doubleClickFullSession.hostingView;
    self.videoViewLayouter.containerView = self.containerView;
    
    [self.videoViewLayouter layoutVideoViews];
    [self updateSelfViewVisiable];
    
    if (sessions.count >= 3) {
        self.backgroundDoubleTap.enabled = YES;
    } else {
        self.backgroundDoubleTap.enabled = NO;
        self.doubleClickFullSession = nil;
    }
}

- (void)setIdleTimerActive:(BOOL)active {
    [UIApplication sharedApplication].idleTimerDisabled = !active;
}

- (void)addLocalSession {
    VideoSession *localSession = [VideoSession localSession];
    [self.videoSessions addObject:localSession];
    [self.agoraKit setupLocalVideo:localSession.canvas];
    [self updateInterfaceWithSessions:self.videoSessions targetSize:self.containerView.frame.size animation:YES];
}

- (VideoSession *)fetchSessionOfUid:(NSUInteger)uid {
    for (VideoSession *session in self.videoSessions) {
        if (session.uid == uid) {
            return session;
        }
    }
    return nil;
}

- (VideoSession *)videoSessionOfUid:(NSUInteger)uid {
    VideoSession *fetchedSession = [self fetchSessionOfUid:uid];
    if (fetchedSession) {
        return fetchedSession;
    } else {
        VideoSession *newSession = [[VideoSession alloc] initWithUid:uid];
        [self.videoSessions addObject:newSession];
        [self updateInterfaceWithSessions:self.videoSessions targetSize:self.containerView.frame.size animation:YES];
        return newSession;
    }
}

- (void)setVideoMuted:(BOOL)muted forUid:(NSUInteger)uid {
    VideoSession *fetchedSession = [self fetchSessionOfUid:uid];
    fetchedSession.isVideoMuted = muted;
}

- (void)updateSelfViewVisiable {
    UIView *selfView = self.videoSessions.firstObject.hostingView;
    if (self.videoSessions.count == 2) {
        selfView.hidden = self.videoMuted;
    } else {
        selfView.hidden = false;
    }
}

- (void)alertString:(NSString *)string {
    if (!string.length) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)leaveChannel {
    [self.agoraKit setupLocalVideo:nil];
    [self.agoraKit leaveChannel:nil];
    [self.agoraKit stopPreview];
    
    for (VideoSession *session in self.videoSessions) {
        [session.hostingView removeFromSuperview];
    }
    [self.videoSessions removeAllObjects];
    
    [self setIdleTimerActive:YES];
    
    if ([self.delegate respondsToSelector:@selector(roomVCNeedClose:)]) {
        [self.delegate roomVCNeedClose:self];
    }
    [self dismissViewControllerAnimated:true completion:Nil];
}

//MARK: - Agora Media SDK
- (void)loadAgoraKit {

    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:[KeyCenter AppId] delegate:self];
    [self.agoraKit setChannelProfile:AgoraRtc_ChannelProfile_Communication];
    [self.agoraKit enableVideo];
    [self.agoraKit setVideoProfile:self.videoProfile swapWidthAndHeight:NO];
    
    [self addLocalSession];
    [self.agoraKit startPreview];
    
    int code = [self.agoraKit joinChannelByKey:nil channelName:self.roomName info:nil uid:0 joinSuccess:nil];
    if (code == 0) {
        [self setIdleTimerActive:NO];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertString:[NSString stringWithFormat:@"Join channel failed: %d", code]];
        });
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed {
    VideoSession *userSession = [self videoSessionOfUid:uid];
    userSession.size = size;
    [self.agoraKit setupRemoteVideo:userSession.canvas];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed {
    if (self.videoSessions.count) {
        VideoSession *selfSession = self.videoSessions.firstObject;
        selfSession.size = size;
        [self updateInterfaceWithSessions:self.videoSessions targetSize:self.containerView.frame.size animation:NO];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraRtcUserOfflineReason)reason {
    VideoSession *deleteSession;
    for (VideoSession *session in self.videoSessions) {
        if (session.uid == uid) {
            deleteSession = session;
        }
    }
    
    if (deleteSession) {
        [self.videoSessions removeObject:deleteSession];
        [deleteSession.hostingView removeFromSuperview];
        [self updateInterfaceWithSessions:self.videoSessions targetSize:self.containerView.frame.size animation:YES];
        
        if (deleteSession == self.doubleClickFullSession) {
            self.doubleClickFullSession = nil;
        }
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid {
    [self setVideoMuted:muted forUid:uid];
}
@end
