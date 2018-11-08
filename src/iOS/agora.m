#import "Agora.h"
#import "AGDChatViewController.h"
#import "AgoraSigKit/AgoraSigKit.h"
#import <UserNotifications/UserNotifications.h>
@interface AgoraPlugin()
@property (nonatomic, retain)  AgoraAPI *signalEngine;
@property (nonatomic, retain)  PKPushRegistry *pushRegistry; 
@property (nonatomic, retain)  NSString *tokenStr;
 
@end

@implementation AgoraPlugin

-(CDVPlugin*) pluginInitialize:(UIWebView*)theWebView
{
    //    self = [super initWithWebView:theWebView];
    
    _signalEngine = nil;
    _chat_instance = nil;
    __completionHandler = nil;
    _pushRegistry = nil;
   

    return self;
}

- (void)setKey:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    NSString* name = [[command arguments] objectAtIndex:0];
    NSString* msg = [NSString stringWithFormat: @"Hello, %@", name];
    
    self.appId = name;
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:msg];
    
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}


// String , String  , String , int , String ,  String
- (void)joinChannelImplementation:(BOOL) is_lecture_mode appId:(NSString*)appId token:(NSString*)token   channel:(NSString*)channel  optionalUID:(int)optionalUID peerAccount:(NSString*)peerAccount  peerAccountName:(NSString*)peerAccountName chatMode:(int)chatMode
{
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ChatView" bundle:nil];
    AGDChatViewController* chat = (AGDChatViewController*)[sb instantiateViewControllerWithIdentifier:@"ChatViewController"];
    
    [chat setAppId: appId];
    [chat setToken: token];
    [chat setChn:channel];
    [chat setChatMode:chatMode];
    [chat setPeerAccount:peerAccount];
    [chat setAccount:self.account];
    [chat setPeerAccountName:peerAccountName];
    
    [chat setCallback: __completionHandler];
    [chat setSignalEngine: self.signalEngine];
    
    [chat setLecture:is_lecture_mode];
    [chat setUid:optionalUID];
    self.chat_instance = chat;
    [self.viewController presentViewController:chat animated:YES completion:nil];
}

-(void) joinChannel:(CDVInvokedUrlCommand *)command
{
    NSString* appId = [[command arguments] objectAtIndex:0];
    NSString* token = [[command arguments] objectAtIndex:1];
    NSString* channel = [[command arguments] objectAtIndex:2];
    int optionalUID = [[[command arguments] objectAtIndex:3] intValue];
    NSString* peerAccount = [[command arguments] objectAtIndex:4];
    NSString* peerAccountName = [[command arguments] objectAtIndex:5];
    int chatMode = [[[command arguments] objectAtIndex:6] intValue];
    int uid = 0;
    
    
//    if(![optionalUID isEqualToString:@"null"]){
//
//        uid = [optionalUID intValue];
//    }
//
    
    
    [self joinChannelImplementation:false appId:appId token:token   channel:channel  optionalUID:optionalUID==0?nil:optionalUID peerAccount:peerAccount  peerAccountName:peerAccountName chatMode:chatMode
     ];
    
    
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
-(void) startLecture:(CDVInvokedUrlCommand *)command
{
    // [self joinChannelImplementation:command mode:true uid:10000];
}

-(void) joinLecture:(CDVInvokedUrlCommand *)command
{
    // [self joinChannelImplementation:command mode:true uid:0];
}

-(void) listenForEvents:(CDVInvokedUrlCommand *)command
{
    NSString* callbackId = [command callbackId];
    void (^handler)(NSString*, NSString*) = ^(NSString* eventName, NSString* data){
        
        NSDictionary *jsonDictionary = @{
                                         @"eventName" : eventName,
                                         @"data" :  data
                                         
                                         };
        NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
        CDVPluginResult* res = [CDVPluginResult
                                resultWithStatus:CDVCommandStatus_OK
                                messageAsString:jsonString];
        [res setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:res callbackId:callbackId];
    };
    self._completionHandler = handler;
    
    handler (@"", @"");
}
- (void) login:(CDVInvokedUrlCommand *)command{
    NSString* appId = [[command arguments] objectAtIndex:0];
   
    NSString* token = [[command arguments] objectAtIndex:1];
    NSString* account = [[command arguments] objectAtIndex:2];
    _account = account;
    
    if(![self.appId isEqualToString:appId]){
        
        self.appId = appId;
        if(self.self.signalEngine != nil){
            
            // [self.signalEngine logout];
            
        }
        else{
            
            self.signalEngine = [AgoraAPI getInstanceWithoutMedia:appId];
            if(self.self.signalEngine != nil){
            
                    // [self.signalEngine logout];
                    self.signalEngine.onLoginSuccess = ^(uint32_t uid, int fd) {
                
                                    self._completionHandler(@"onLoginSuccess", @"");
                     };
            
                    self.signalEngine.onLoginFailed = ^(AgoraEcode ecode) {
                
                            if(ecode == 208){
                                return ;
                            }
                            self._completionHandler(@"onLoginFailed", @((unsigned long)ecode));
                    };
                    self.signalEngine.onError = ^(NSString* name,AgoraEcode ecode,NSString* desc) {
            
                            NSDictionary *jsonDictionary = @{
                                             @"name" :  name,
                                             @"ecode":  [[NSNumber numberWithInt:((unsigned long)ecode)] stringValue],
                                             @"desc" :  desc
                                             
                                             };
                            NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
            
                            self._completionHandler(@"onError", jsonString);
                    };
        
                    self.signalEngine.onInviteFailed = ^(NSString* channelID,NSString* account,uint32_t uid,AgoraEcode ecode,NSString* extra) {
            
                        NSDictionary *jsonDictionary = @{
                                             @"channelID" :  channelID,
                                             @"account" :  account,
                                             @"uid" :  [[NSNumber numberWithInt:((unsigned long)uid)] stringValue],
                                             @"ecode": [[NSNumber numberWithInt:((unsigned long)ecode)] stringValue],
                                             @"extra" :  extra
                                             
                                             };
                        NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.chat_instance finishChat];
                        });
                        self._completionHandler(@"onInviteFailed", jsonString);
                    };
        
        
                    self.signalEngine.onQueryUserStatusResult = ^(NSString* name,NSString* status)  {
                        
                        NSDictionary *jsonDictionary = @{
                                             @"name" :  name,
                                             @"status" :  status
                                             
                                             };
                        NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
            
                        self._completionHandler(@"onQueryUserStatusResult", jsonString);
                    };
        
                    
                    self.signalEngine.onInviteReceived = ^(NSString* channelID,NSString* account,uint32_t uid, NSString* extra)   {
            
                        NSDictionary *jsonDictionary = @{
                                             @"channelID" :  channelID,
                                             @"account" :  account,
                                             @"uid" :  [[NSNumber numberWithInt:((unsigned long)uid)] stringValue],
                                             
                                             @"extra" :  extra
                                             };
                        NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
            
                        self._completionHandler(@"onInviteReceived", jsonString);
                    };
                    self.signalEngine.onInviteReceivedByPeer = ^(NSString* channelID,NSString* account,uint32_t uid)   {
            
                        NSDictionary *jsonDictionary = @{
                                             @"channelID" :  channelID,
                                             @"account" :  account,
                                             @"uid" :  [[NSNumber numberWithInt:((unsigned long)uid)] stringValue]
                                             };
                        NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
            
                        self._completionHandler(@"onInviteReceivedByPeer", jsonString);
                    };
        
                    self.signalEngine.onInviteAcceptedByPeer = ^(NSString* channelID,NSString* account,uint32_t uid,NSString* extra)    {
            
                        NSDictionary *jsonDictionary = @{
                                             @"channelID" :  channelID,
                                             @"account" :  account,
                                             @"uid" : [[NSNumber numberWithInt:((unsigned long)uid)] stringValue],
                                             
                                             @"extra" :  extra
                                             };
                        NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
            
                        self._completionHandler(@"onInviteAcceptedByPeer", jsonString);
                    };
        
                    self.signalEngine.onInviteRefusedByPeer = ^(NSString* channelID,NSString* account,uint32_t uid,NSString* extra)     {
            
                        NSDictionary *jsonDictionary = @{
                                             @"channelID" :  channelID,
                                             @"account" :  account,
                                             @"uid" :  [[NSNumber numberWithInt:((unsigned long)uid)] stringValue],
                                              @"extra" :  extra
                                             };
                        NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.chat_instance finishChat];
                        });
                        self._completionHandler(@"onInviteRefusedByPeer", jsonString);
                    };
        
                    self.signalEngine.onInviteEndByPeer = ^(NSString* channelID,NSString* account,uint32_t uid,NSString* extra)      {
            
                        NSDictionary *jsonDictionary = @{
                                             @"channelID" :  channelID,
                                             @"account" :  account,
                                             @"uid" :  [[NSNumber numberWithInt:((unsigned long)uid)] stringValue],
                                             
                                             @"extra" :  extra
                                             };
                        NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.chat_instance finishChat];
                        });
                        
                        self._completionHandler(@"onInviteEndByPeer", jsonString);
                    };
                    self.signalEngine.onInviteEndByMyself = ^(NSString* channelID,NSString* account,uint32_t uid)    {
            
                        NSDictionary *jsonDictionary = @{
                                             @"channelID" :  channelID,
                                             @"account" :  account,
                                             @"uid" :  [[NSNumber numberWithInt:((unsigned long)uid)] stringValue],
                                             };
                        NSString *jsonString = [self DataTOjsonString: jsonDictionary];;
            
                        self._completionHandler(@"onInviteEndByMyself", jsonString);
                    };
                }
        
            
        }
        
    

    }
    
    [self registerPushkit];
    
    if(self.signalEngine != nil){

        [self.signalEngine login:appId account:account token:token uid:0 deviceID:nil];
        
    }
    else{
        self._completionHandler(@"onLoginFailed", @"signalEngine is nil");

    }
    
}



- (void) logout:(CDVInvokedUrlCommand *)command{
    
    if(self.signalEngine){
        
        [self.signalEngine logout];
    }
    
}
- (void) unMuteLocalStream:(CDVInvokedUrlCommand *)command{
    
    if(self.chat_instance != nil){
        
        [self.chat_instance.agoraKit muteLocalAudioStream:false];
        [self.chat_instance.agoraKit muteLocalVideoStream:false];
        
    }
    
    
}
- (void) channelInviteUser:(CDVInvokedUrlCommand *)command{
    NSString* appId = [[command arguments] objectAtIndex:0];
    NSString* token = [[command arguments] objectAtIndex:1];
    NSString* channel = [[command arguments] objectAtIndex:2];
    int uid  = [[[command arguments] objectAtIndex:3] intValue];
    NSString* peerAccount = [[command arguments] objectAtIndex:4];
    NSString* peerAccountName = [[command arguments] objectAtIndex:5];
    NSString* extra = [[command arguments] objectAtIndex:6];
    int chatMode = [[[command arguments] objectAtIndex:7] intValue];
    
   
    // if(![optionalUID isEqualToString:@"null"]){
        
    //     uid = [optionalUID intValue];
    // }
    
    // NSDictionary *extraDic = @{
    //                            @"_require_peer_online" :  @(0),
    //                            @"_timeout":  @(30),
    //                            @"srcNum" :  peerAccountName
                               
    //                            };
    
    
    [self.signalEngine channelInviteUser2:channel account:peerAccount extra:extra];
    [self.signalEngine queryUserStatus:peerAccount];
    [self joinChannelImplementation:false
                              appId:appId token:token   channel:channel  optionalUID:uid peerAccount:peerAccount  peerAccountName:peerAccountName chatMode:chatMode
     ];
    
    
}

- (void)channelInviteEnd:(CDVInvokedUrlCommand *)command{
     NSString* channelID = [[command arguments] objectAtIndex:0];
     NSString* account = [[command arguments] objectAtIndex:1];
     int uid =  [[[command arguments] objectAtIndex:2] intValue];
    
    [self.signalEngine   channelInviteEnd:channelID account:account uid:uid];
}
- (void) queryUserStatus:(CDVInvokedUrlCommand *)command{
    NSString* account = [[command arguments] objectAtIndex:0];
    [self.signalEngine queryUserStatus:account];
    
}
- (void) channelInviteRefuse:(CDVInvokedUrlCommand *)command{
    NSString* channelID = [[command arguments] objectAtIndex:0];
    NSString* account = [[command arguments] objectAtIndex:1];
    int uid = [[[command arguments] objectAtIndex:2] intValue ];
    NSString* extra = [[command arguments] objectAtIndex:3];
     [self.signalEngine channelInviteRefuse:channelID account:account uid:uid extra:extra];
}
- (void) channelInviteAccept:(CDVInvokedUrlCommand *)command{
   
    NSString* channelID = [[command arguments] objectAtIndex:0];
    NSString* account = [[command arguments] objectAtIndex:1];
    int uid = [[[command arguments] objectAtIndex:2] intValue ];
    NSString* extra = [[command arguments] objectAtIndex:3];
    [self.signalEngine channelInviteAccept:channelID account:account uid:uid extra:extra];
}

- (void) disableVideo:(CDVInvokedUrlCommand *)command{
      NSString* callbackId = [command callbackId];
      [self.chat_instance disableVideo];
      CDVPluginResult* res = [CDVPluginResult
                                resultWithStatus:CDVCommandStatus_OK
                                messageAsString:@"calling executed"];
      [self.commandDelegate sendPluginResult:res callbackId:callbackId];
}


-(void) registerPushkit
{

           if(_pushRegistry == nil){

                 PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:nil];
                 pushRegistry.delegate = self;
                _pushRegistry = pushRegistry;
               
           }
           

            _pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
           
          
     
}
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials  forType:(PKPushType)type;{
        NSString *str = [NSString stringWithFormat:@"%@",pushCredentials.token];
        _tokenStr = [
                     [
                         [str stringByReplacingOccurrencesOfString:@"<" withString:@""] 
                         stringByReplacingOccurrencesOfString:@">" withString:@""
                     ] 
                     stringByReplacingOccurrencesOfString:@" " withString:@""
                    ];
    self._completionHandler(@"didUpdatePushCredentials", _tokenStr);
} //这个代理方法是获取了设备的唯tokenStr，是要给服务器的

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type{

     _pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
} // 重新获取token

- (void)pushRegistry:(PKPushRegistry *)registry 
        didReceiveIncomingPushWithPayload:(PKPushPayload *)payload 
        forType:(PKPushType)type 
        withCompletionHandler:(void (^)(void))completion {
          
    
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground ){
        //ios 10
//        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
//        content.title = [NSString localizedUserNotificationStringForKey:@"Hello!" arguments:nil];
//        content.body = [NSString localizedUserNotificationStringForKey:@"Hello_message_body"
//                                                             arguments:nil];
//        content.sound = [UNNotificationSound defaultSound];
//
//        // Deliver the notification in five seconds.
//        UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
//                                                      triggerWithTimeInterval:5 repeats:NO];
//        UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
//                                                                              content:content trigger:trigger];
//
//        // Schedule the notification.
//        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
//
//
//        void (^handler)(NSError*) = ^(NSError* data){
//
//
//        };
//
//       [center addNotificationRequest:request withCompletionHandler:(void (^)(NSError *error))handler];
        
        NSDictionary* dictionaryPayload = payload.dictionaryPayload;
        
        NSString* allertBody = dictionaryPayload[@"aps"][@"alert"][@"body"];
        UILocalNotification*   localNotification = [UILocalNotification alloc] ;
        localNotification.alertBody = allertBody;
        localNotification.applicationIconBadgeNumber = 1;
        localNotification.soundName = @"ios_ring.caf";//UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow: localNotification ] ;
        
    }
        
    NSString* payloadString =  [self DataTOjsonString:payload.dictionaryPayload ];
   
    self._completionHandler(@"didReceiveIncomingPushWithPayload", payloadString);
       if(completion != nil){

         completion();
       }
       
}
- (void)applicationWillTerminate:(UIApplication *)application {
     if(self.signalEngine){
        
        [self.signalEngine logout];
    }
}



@end
