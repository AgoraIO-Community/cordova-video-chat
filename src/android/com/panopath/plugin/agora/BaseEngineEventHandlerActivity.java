package com.panopath.plugin.agora;

import io.agora.rtc.IRtcEngineEventHandler;

public class BaseEngineEventHandlerActivity extends BaseActivity {


    public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
    }

    public void onRejoinChannelSuccess(String channel, int uid, int elapsed) {
    }

    public void onWarning(int warn) {
    }

    public void onApiCallExecuted( int error, String api, String result) {
    }

    public void onError(int err) {
    }

    public void onCameraReady() {
    }

    public void onVideoStopped() {
    }

    public void onConnectionInterrupted() {
    }

    public void onAudioQuality(int uid, int quality, short delay, short lost) {
    }

    public void onAudioTransportQuality(int uid, short delay, short lost) {
    }

    public void onVideoTransportQuality(int uid, short delay, short lost) {
    }

    public void onLeaveChannel(IRtcEngineEventHandler.RtcStats stats) {
    }

    public void onUpdateSessionStats(IRtcEngineEventHandler.RtcStats stats) {
    }

    public void onRecap(byte[] recap) {
    }

    public void onAudioVolumeIndication(IRtcEngineEventHandler.AudioVolumeInfo[] speakers, int totalVolume) {
    }

    public void onNetworkQuality(int 	uid,
								 int 	txQuality,
								 int 	rxQuality) {
    }

    public void endChat(){}
    public void fallbackToAudioMode(){}
    public void onUserJoined(int uid, int elapsed) {
    }

    public void onUserOffline(int uid) {
    }

    public void onUserMuteAudio(int uid, boolean muted) {
    }

    public void onUserMuteVideo(int uid, boolean muted) {
    }

    public void onAudioRecorderException(int nLastTimeStamp) {
    }

    public void onRemoteVideoStat(int uid, int frameCount, int delay, int receivedBytes) {
    }

    public void onLocalVideoStat(int sentBytes, int sentFrames) {
    }

    public void onFirstRemoteVideoFrame(int uid, int width, int height, int elapsed) {
    }

    public void onFirstLocalVideoFrame(int width, int height, int elapsed) {
    }

    public void onFirstRemoteVideoDecoded(int uid, int width, int height, int elapsed) {
    }

    public void onConnectionLost() {
    }

    public void onMediaEngineEvent(int code) {
    }

}
