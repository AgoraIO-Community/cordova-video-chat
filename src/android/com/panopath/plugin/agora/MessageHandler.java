package com.panopath.plugin.agora;

import org.json.JSONException;
import org.json.JSONStringer;
import io.agora.AgoraAPI;
import io.agora.IAgoraAPI;
import android.util.Log;
import io.agora.rtc.IRtcEngineEventHandler;

public class MessageHandler extends IRtcEngineEventHandler {
    private final String TAG = "MessageHandler";
    private BaseEngineEventHandlerActivity mHandlerActivity;
    
    @Override
    public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("channel");
            jsonText.value(channel);
            jsonText.key("uid");
            jsonText.value(uid);
            jsonText.key("elapsed");
            jsonText.value(elapsed);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onJoinChannelSuccess", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onJoinChannelSuccess(channel, uid, elapsed);
        }
    }
    @Override
    public void onUserEnableVideo(int uid, boolean enabled){
        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            if(!enabled)
            {
                  activity.fallbackToAudioMode();
            }
            
           
        }
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("uid");
            jsonText.value(uid);
            jsonText.key("enabled");
            jsonText.value(enabled);
           
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onUserEnableVideo", jsonText.toString());

    }

    @Override
    public void onRejoinChannelSuccess(String channel, int uid, int elapsed) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("channel");
            jsonText.value(channel);
            jsonText.key("uid");
            jsonText.value(uid);
            jsonText.key("elapsed");
            jsonText.value(elapsed);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onRejoinChannelSuccess", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onRejoinChannelSuccess(channel, uid, elapsed);
        }
    }

    @Override
    public void onWarning(int warn) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("warningCode");
            jsonText.value(warn);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onWarning", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onWarning(warn);
        }
    }


    @Override
	    public void onApiCallExecuted(int 	error,
								  String 	api,
								  String 	result ) {
   
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("api");
            jsonText.value(api);
            jsonText.key("error");
            jsonText.value(error);
			jsonText.key("result");
            jsonText.value(result);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        // Agora.notifyEvent("onApiCallExecuted", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onApiCallExecuted(error, api, result );
        }
    }

    @Override
    public void onCameraReady() {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onCameraReady", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onCameraReady();
        }
    }
//     @Override
//     public void onUserEnableVideo(int uid, boolean enabled){

//         // if(enabled){
          
//         //     getActivity().enableVideo();
//         // }else{
           
//         //     getActivity().disableVideo();

//         // }
//      //
   
//    }
    @Override
    public void onVideoStopped() {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onVideoStopped", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onVideoStopped();
        }
    }

    @Override
    public void onAudioQuality(int uid, int quality, short delay, short lost) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("uid");
            jsonText.value(uid);
            jsonText.key("quality");
            jsonText.value(quality);
            jsonText.key("delay");
            jsonText.value(delay);
            jsonText.key("lost");
            jsonText.value(lost);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onAudioQuality", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onAudioQuality(uid, quality, delay, lost);
        }
    }

    @Override
    public void onAudioVolumeIndication(IRtcEngineEventHandler.AudioVolumeInfo[] speakers, int totalVolume) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("speakers");
            jsonText.array();
            for (IRtcEngineEventHandler.AudioVolumeInfo speaker : speakers) {
                flattenAudioVolumeInfo(speaker, jsonText);
            }
            jsonText.value(speakers);
            jsonText.endArray();
            jsonText.key("totalVolume");
            jsonText.value(totalVolume);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onAudioVolumeIndication", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onAudioVolumeIndication(speakers, totalVolume);
        }
    }

    @Override
    public void onNetworkQuality(int 	uid,
								 int 	txQuality,
								 int 	rxQuality ) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("uid");
            jsonText.value(uid);
			jsonText.key("txQuality");
            jsonText.value(txQuality);
			jsonText.key("rxQuality");
            jsonText.value(rxQuality);
			
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        // Agora.notifyEvent("onNetworkQuality", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onNetworkQuality(uid, txQuality, rxQuality );
        }
    }

    @Override
    public void onUserMuteAudio(int uid, boolean muted) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("uid");
            jsonText.value(uid);
            jsonText.key("muted");
            jsonText.value(muted);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onUserMuteAudio", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onUserMuteAudio(uid, muted);
        }
    }

    @Override
    public void onRemoteVideoStat(int uid, int delay, int receivedBitrate, int receivedFrameRate) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("uid");
            jsonText.value(uid);
            jsonText.key("delay");
            jsonText.value(delay);
            jsonText.key("receivedBitrate");
            jsonText.value(receivedBitrate);
            jsonText.key("receivedFrameRate");
            jsonText.value(receivedFrameRate);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onRemoteVideoStat", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onRemoteVideoStat(uid, delay, receivedBitrate, receivedFrameRate);
        }
    }

    @Override
    public void onLocalVideoStat(int sentBitrate, int sentFrameRate) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("sentBitrate");
            jsonText.value(sentBitrate);
            jsonText.key("sentFrameRate");
            jsonText.value(sentFrameRate);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onLocalVideoStat", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onLocalVideoStat(sentBitrate, sentFrameRate);
        }
    }

    @Override
    public void onFirstRemoteVideoFrame(int uid, int width, int height, int elapsed) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("uid");
            jsonText.value(uid);
            jsonText.key("width");
            jsonText.value(width);
            jsonText.key("height");
            jsonText.value(height);
            jsonText.key("elapsed");
            jsonText.value(elapsed);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onFirstRemoteVideoFrame", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onFirstRemoteVideoFrame(uid, width, height, elapsed);
        }
    }

    @Override
    public void onFirstLocalVideoFrame(int width, int height, int elapsed) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("width");
            jsonText.value(width);
            jsonText.key("height");
            jsonText.value(height);
            jsonText.key("elapsed");
            jsonText.value(elapsed);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onFirstLocalVideoFrame", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onFirstLocalVideoFrame(width, height, elapsed);
        }
    }

    @Override
    public void onConnectionInterrupted() {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onConnectionInterrupted", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onConnectionInterrupted();
        }
    }

    @Override
    public void onConnectionLost() {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onConnectionLost", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onConnectionLost();
        }
    }

    @Override
    public void onError(int err) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("errorCode");
            jsonText.value(err);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onError", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onError(err);
        }
    }

    @Override
    public void onFirstRemoteVideoDecoded(int uid, int width, int height, int elapsed) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("uid");
            jsonText.value(uid);
            jsonText.key("width");
            jsonText.value(width);
            jsonText.key("height");
            jsonText.value(height);
            jsonText.key("elapsed");
            jsonText.value(elapsed);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onFirstRemoteVideoDecoded", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onFirstRemoteVideoDecoded(uid, width, height, elapsed);
        }
    }

    //用户进入
    @Override
    public void onUserJoined(int uid, int elapsed) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("uid");
            jsonText.value(uid);
            jsonText.key("elapsed");
            jsonText.value(elapsed);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

      
        Agora.notifyEvent("onUserJoined", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onUserJoined(uid, elapsed);
        }
    }

    //用户退出
    @Override
    public void onUserOffline(int uid, int reason) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("uid");
            jsonText.value(uid);
            jsonText.key("reason");
            jsonText.value(reason);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onUserOffline", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onUserOffline(uid);
        }
    }

    //监听其他用户是否关闭视频
    @Override
    public void onUserMuteVideo(int uid, boolean muted) {

        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("uid");
            jsonText.value(uid);
            jsonText.key("muted");
            jsonText.value(muted);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onUserMuteVideo", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onUserMuteVideo(uid, muted);
        }
    }

    //更新聊天数据
    @Override
    public void onRtcStats(RtcStats stats) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            flattenRtcStats(stats, jsonText);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onRtcStats", jsonText.toString());

        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onUpdateSessionStats(stats);
        }
    }


    @Override
    public void onLeaveChannel(RtcStats stats) {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            flattenRtcStats(stats, jsonText);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        Agora.notifyEvent("onLeaveChannel", jsonText.toString());
        
        BaseEngineEventHandlerActivity activity = getActivity();

        if (activity != null) {
            activity.onLeaveChannel(stats);
        }
    }


    public void setActivity(BaseEngineEventHandlerActivity activity) {
        this.mHandlerActivity = activity;
    }

    public BaseEngineEventHandlerActivity getActivity() {
        return mHandlerActivity;
    }


    private void flattenRtcStats(RtcStats stats, JSONStringer stringer) {
        try {

            stringer.key("totalDuration");
            stringer.value(stats.totalDuration);

            stringer.key("txBytes");
            stringer.value(stats.txBytes);

            stringer.key("rxBytes");
            stringer.value(stats.rxBytes);

            stringer.key("txKBitRate");
            stringer.value(stats.txKBitRate);

            stringer.key("rxKBitRate");
            stringer.value(stats.rxKBitRate);

            // stringer.key("lastmileDelay");
            // stringer.value(stats.lastmileDelay);

            stringer.key("users");
            stringer.value(stats.users);

            stringer.key("cpuTotalUsage");
            stringer.value(stats.cpuTotalUsage);

            stringer.key("cpuAppUsage");
            stringer.value(stats.cpuAppUsage);
        } catch (JSONException ignored) {

        }
    }

    private void flattenAudioVolumeInfo(AudioVolumeInfo audioVolumeInfo, JSONStringer stringer) {
        try {
            stringer.key("uid");
            stringer.value(audioVolumeInfo.uid);

            stringer.key("volume");
            stringer.value(audioVolumeInfo.volume);
        } catch (JSONException ignored) {

        }
    }
	
 

	public void addSignalingCallback() {

       Agora.getAgoraAPIOnlySignal().callbackSet(new AgoraAPI.CallBack() {

            @Override
            public void onLoginSuccess(int i, int i1) {
                Log.i(TAG, "onLoginSuccess " + i + "  " + i1);
				Agora.notifyEvent("onLoginSuccess", "");
            }

            @Override
            public void onLoginFailed(int ecode) {
                Log.i(TAG, "onLoginFailed " + ecode);
                // RtcEngineCreator.getInstance().destroyRtcEngine();
                Agora.notifyEvent("onLoginFailed", ""+ ecode);
            }


            @Override
            public void onError(String name,int ecode,String desc) {
                Log.i(TAG, "onError s:" + ecode + " desc:" + desc);
				JSONStringer jsonText = new JSONStringer();

				try {
					jsonText.object();
					jsonText.key("name");
					jsonText.value(name);
					jsonText.key("ecode");
					jsonText.value(ecode);
					jsonText.key("desc");
					jsonText.value(desc);
			
					jsonText.endObject();
				} catch (JSONException ignored) {
				
				}
				
				
				Agora.notifyEvent("onError",  jsonText.toString());
				// if(this.getActivity()!=null) this.getActivity().endChat();
            }
			
			@Override
			public void onInviteFailed(String channelID,String account,int uid,int ecode, String extra){
				JSONStringer jsonText = new JSONStringer();

				try {
					jsonText.object();
					jsonText.key("channelID");
					jsonText.value(channelID);
					jsonText.key("account");
					jsonText.value(account);
					jsonText.key("ecode");
					jsonText.value(ecode);
					jsonText.key("extra");
					jsonText.value(extra);
			
					jsonText.endObject();
                   
				} catch (JSONException ignored) {
				
				}
				Agora.notifyEvent("onInviteFailed", jsonText.toString());

			    if(getActivity()!=null) getActivity().endChat();
				
			}
            @Override
            public void onQueryUserStatusResult(String name,String status){

                JSONStringer jsonText = new JSONStringer();

				try {
					jsonText.object();
					jsonText.key("name");
					jsonText.value(name);
					jsonText.key("status");
					jsonText.value(status);
					
					
			
					jsonText.endObject();
				} catch (JSONException ignored) {
				
				}
				Agora.notifyEvent("onQueryUserStatusResult", jsonText.toString());


            }
			@Override
			public void onInviteReceived(String channelID,String account,int uid,String extra){
				
				JSONStringer jsonText = new JSONStringer();

				try {
					jsonText.object();
					jsonText.key("channelID");
					jsonText.value(channelID);
					jsonText.key("account");
					jsonText.value(account);
					jsonText.key("extra");
					jsonText.value(extra);
                    
					jsonText.endObject();
				} catch (JSONException ignored) {
				
				}
               
				Agora.notifyEvent("onInviteReceived",  jsonText.toString());
			}
			@Override
			public void onInviteReceivedByPeer(String channelID,String account,int uid){
				
				JSONStringer jsonText = new JSONStringer();

				try {
					jsonText.object();
					jsonText.key("channelID");
					jsonText.value(channelID);
					jsonText.key("account");
					jsonText.value(account);
					
			
					jsonText.endObject();
				} catch (JSONException ignored) {
				
				}
				Agora.notifyEvent("onInviteReceivedByPeer", jsonText.toString() );
				
			}
			
			@Override
			public void onInviteAcceptedByPeer(String channelID,String account,int uid, String extra){
			
				JSONStringer jsonText = new JSONStringer();

				try {
                    
					jsonText.object();
					jsonText.key("channelID");
					jsonText.value(channelID);
					jsonText.key("account");
					jsonText.value(account);
					jsonText.key("uid");
					jsonText.value(uid);
					jsonText.key("extra");
					jsonText.value(extra);
			
					jsonText.endObject();
				} catch (JSONException ignored) {
				
				}
                 if(mHandlerActivity!=null)
                 { mHandlerActivity.stopPlaying();}
				Agora.notifyEvent("onInviteAcceptedByPeer",  jsonText.toString());
			}
			@Override
			public void onInviteRefusedByPeer(String channelID,String account,int uid, String extra){
				JSONStringer jsonText = new JSONStringer();

				try {
					jsonText.object();
					jsonText.key("channelID");
					jsonText.value(channelID);
					jsonText.key("account");
					jsonText.value(account);
					jsonText.key("uid");
					jsonText.value(uid);
					jsonText.key("extra");
					jsonText.value(extra);
			
					jsonText.endObject();
				} catch (JSONException ignored) {
				
				}
                
				Agora.notifyEvent("onInviteRefusedByPeer", jsonText.toString());
                //RtcEngineCreator.getInstance().destroyRtcEngine();
                if(mHandlerActivity!=null){
                    mHandlerActivity.stopPlaying();
                    mHandlerActivity.endChat();
                }
				
			}
			
			@Override
			public void onInviteEndByPeer(String channelID,String account,int uid, String extra){
				
				JSONStringer jsonText = new JSONStringer();

				try {
					jsonText.object();
					jsonText.key("channelID");
					jsonText.value(channelID);
					jsonText.key("account");
					jsonText.value(account);
					jsonText.key("uid");
					jsonText.value(uid);
					jsonText.key("extra");
					jsonText.value(extra);
			
					jsonText.endObject();
				} catch (JSONException ignored) {
				
				}
            
             if(mHandlerActivity!=null){

                    mHandlerActivity.endChat();
                }
                // RtcEngineCreator.getInstance().destroyRtcEngine();
				Agora.notifyEvent("onInviteEndByPeer", jsonText.toString());
				
			}
			
			@Override
			public void onInviteEndByMyself(String channelID,String account,int uid){
				JSONStringer jsonText = new JSONStringer();

				try {
					jsonText.object();
					jsonText.key("channelID");
					jsonText.value(channelID);
					jsonText.key("account");
					jsonText.value(account);
					jsonText.key("uid");
					jsonText.value(uid);
					
			
					jsonText.endObject();
				} catch (JSONException ignored) {
				
				}
                // RtcEngineCreator.getInstance().destroyRtcEngine();
				Agora.notifyEvent("onInviteEndByMyself", jsonText.toString() );
				
			}
        });
    }

    
}
