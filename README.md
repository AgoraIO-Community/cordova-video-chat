# cordova-plugin-agora

A cordova plugin, a JS version of Agora SDK

# Author
山西蚨坤科技有限公司 贾之光码农

# Feature
使用agora 信令包和音视频包实现一对一视频通话。 类似微信的视频通话。 接受通话时，可以从视频降级到音频。
IOS 包括了pushkit 和 localNotification 功能。 接收到来电时候，从后台唤醒。

# Example
无

# 安装
1. 从[这里](https://github.com/AgoraIO-Community/cordova-video-chat/releases/tag/1.0.0)下载demo自带的相关sdk，并置入iOS与Android对应的目录里

2. ```cordova plugin add cordova-plugin-agora```

3. ```cordova build ios``` or ```cordova build android```

4. (iOS only) 

# Usage
我使用的是typeScript

## 先声明agora变量
```Javascript
declare var Agora
```

## 设置消息回调函数

Agora.setCallBack((event) => {
	 let eventName = event["eventName"]
     let eventData = event["data"] // eventData 也是string， 可以在发布前调用json.parse() 	
	// 这里可以放置预处理代码
	this.events.publish(eventName, eventData)
})



Agora.setCallBack 比较笨拙。 实际上可以在插件的agora.js里面直接使用events.publish， 然后在app代码中使用events.subscribe来提交事件处理函数。 然后用events.unSubscribe 来取消事件处理函数。 


如果有时间， 可以把这个优化一下， 如果没有， 这样做也没有问题。 收到native端的消息以后， 再publish

event 内容详见native code. 是json 格式数据。 包括eventName 和 eventData

以下是eventName定义：实际上eventName都是agora java sdk 的回调方法名， data是回调送回来的各个data 放在了json结构里面
```
export var AGORA_EVENTS = {
    onRejoinChannelSuccess: "onRejoinChannelSuccess",
    onWarning: "onWarning",
    onApiCallExecuted: "onApiCallExecuted",
    onCameraReady: "onCameraReady",
    onVideoStopped: "onVideoStopped",
    onAudioQuality: "onAudioQuality",
    onAudioVolumeIndication: "onAudioVolumeIndication",
    onNetworkQuality: "onNetworkQuality",
    onUserMuteAudio: "onUserMuteAudio",
    onRemoteVideoStat: "onRemoteVideoStat",
    onLocalVideoStat: "onLocalVideoStat",
    onFirstRemoteVideoFrame: "onFirstRemoteVideoFrame",
    onFirstLocalVideoFrame: "onFirstLocalVideoFrame",
    onConnectionInterrupted: "onConnectionInterrupted",
    onConnectionLost: "onConnectionLost",
    onError: "onError",
    onFirstRemoteVideoDecoded: "onFirstRemoteVideoDecoded",
    onUserJoined: "onUserJoined",
    onUserOffline: "onUserOffline",
    onUserMuteVideo: "onUserMuteVideo",
    onRtcStats: "onRtcStats",
    onLeaveChannel: "onLeaveChannel",
    onLoginSuccess: "onLoginSuccess",
    onLoginFailed: "onLoginFailed",
    runtimeError: "runtimeError",
    onInviteFailed: "onInviteFailed",
    onInviteReceived: "onInviteReceived",
    onInviteReceivedByPeer: "onInviteReceivedByPeer",
    onInviteAcceptedByPeer: "onInviteAcceptedByPeer",
    onInviteRefusedByPeer: "onInviteRefusedByPeer",
    onInviteEndByPeer: "onInviteEndByPeer",
    onInviteEndByMyself: "onInviteEndByMyself",
    onQueryUserStatusResult: "onQueryUserStatusResult",
    onJoinChannelSuccess:"onJoinChannelSuccess",
    didUpdatePushCredentials: "didUpdatePushCredentials", // ios only
    didReceiveIncomingPushWithPayload: "didReceiveIncomingPushWithPayload",// ios only


}

```


## agora.js 和native code 通信
有几个函数的参数写的很长。有些参数可能不必要。
还有些函数不必要。 例如 setKey
 每次需要appid和token的场合， 都必须把他们从javascript端送到native端。 native不储存。 
有些送进去的successCallback 和 failCallback 在native 端执行完以后，并没有被调用。 因为native sdk 全部是异步调用。 如果觉得不妥，可以加上。 不过每次nativecode的 onApiCallExecuted 的回调都被送回javascript端。

## 登陆
```
Agora.login(appId, token,  account, expiredTime, successCallback, failCallback)
```

## 邀请对方通话
```
Agora.channelInviteUser(appId,  token,  channel,  optionalUID,   account,  accountName, extra, chatMode,successCallback, failCallback)
```
在native端， 邀请对方的同时，己方就设置了通话环境，并加入channel等待对方反应。同时调用信令端查看对方是否在线。 不在线的话，event会送回来， 在javascript端口可以调用推送消息通知对方等等。

## 接收到邀请加入
```
joinChannel(appId,  token,  channel,  optionalUID,   peerAccount,  peerName, chatMode, successCallback, failCallback)

```

## 清理native 代码

native代码中有很多不用的code， 对native不太熟悉， 只是修改了某些一对一通信能用到的。 其他的都leave it as it is. 希望Agora的同学能清理下， 不然看着很乱。


## 有些resource觉得不合适的可以清理掉

图片之类的。 特别是ios的界面适配。 在从视频转到音频的时候， 哪几个不需要的按钮去掉之后，怎么重排按钮， 这个我不太懂。
