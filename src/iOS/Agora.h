#import <Cordova/CDVPlugin.h>
#import "AGDChatViewController.h"
#import <PushKit/PushKit.h>
@interface AgoraPlugin : CDVPlugin <PKPushRegistryDelegate>
@property (nonatomic, retain) NSString *appId;
@property (nonatomic, retain) NSString *account;
@property (nonatomic, retain) AGDChatViewController* chat_instance;
@property (nonatomic, retain) void (^_completionHandler)(NSString* someParameter, NSString* otherParameter);

- (void) setKey:(CDVInvokedUrlCommand*)command;
- (void) joinChannel: (CDVInvokedUrlCommand*)command;
- (void) startLecture:(CDVInvokedUrlCommand *)command;
- (void) joinLecture:(CDVInvokedUrlCommand *)command;
- (void) listenForEvents:(CDVInvokedUrlCommand *)command;
- (void) login:(CDVInvokedUrlCommand *)command;
- (void) logout:(CDVInvokedUrlCommand *)command;
- (void) unMuteLocalStream:(CDVInvokedUrlCommand *)command;
- (void) channelInviteUser:(CDVInvokedUrlCommand *)command;
- (void) channelInviteEnd:(CDVInvokedUrlCommand *)command;
- (void) queryUserStatus:(CDVInvokedUrlCommand *)command;
- (void) channelInviteRefuse:(CDVInvokedUrlCommand *)command;
- (void) channelInviteAccept:(CDVInvokedUrlCommand *)command;
- (void) disableVideo:(CDVInvokedUrlCommand *)command;
@end
