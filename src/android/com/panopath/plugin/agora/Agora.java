package com.panopath.plugin.agora;


import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.SurfaceView;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import io.agora.rtc.*;
import io.agora.rtc.video.VideoCanvas;
import io.agora.AgoraAPIOnlySignal;
import io.agora.AgoraAPI;
import io.agora.IAgoraAPI;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONStringer;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Date;
import io.agora.rtc.RtcEngine;
public class Agora extends CordovaPlugin {
    public static final String TAG = "CDVAgora";
    // protected RtcEngine mRtcEngine;
    protected SurfaceView surfaceView;
    protected Activity appActivity;
    protected Context appContext;
    private static CallbackContext eventCallbackContext;
	private static AgoraAPIOnlySignal m_agoraAPI = null;
    @Override
    protected void pluginInitialize() {
        appContext = this.cordova.getActivity().getApplicationContext();
        appActivity = cordova.getActivity();
        super.pluginInitialize();
        RtcEngineCreator.getInstance().setApplicationContext(appContext);
		
    }

    public static String getToken(String appId, String certificate, String account, long expiredTsInSeconds) throws NoSuchAlgorithmException {

        StringBuilder digest_String = new StringBuilder().append(account).append(appId).append(certificate).append(expiredTsInSeconds);
        MessageDigest md5 = MessageDigest.getInstance("MD5");
        md5.update(digest_String.toString().getBytes());
        byte[] output = md5.digest();
        String token = hexlify(output);
        String token_String = new StringBuilder().append("1").append(":").append(appId).append(":").append(expiredTsInSeconds).append(":").append(token).toString();
        return token_String;
    }

    public static String hexlify(byte[] data) {

        char[] DIGITS_LOWER = {'0', '1', '2', '3', '4', '5',
                '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
        char[] toDigits = DIGITS_LOWER;
        int l = data.length;
        char[] out = new char[l << 1];
        // two characters form the hex value.
        for (int i = 0, j = 0; i < l; i++) {
            out[j++] = toDigits[(0xF0 & data[i]) >>> 4];
            out[j++] = toDigits[0x0F & data[i]];
        }
        return String.valueOf(out);
    }
	
    @Override
    public boolean execute(String action, JSONArray args,
                           final CallbackContext callbackContext) throws JSONException {

        Log.d(TAG, action + " called");
		
		
        if (action.equals("setKey")) {
            String appId = args.getString(0);
			
			
           
			RtcEngineCreator.getInstance().setAppId(appId);
			callbackContext.success();
            return true;
        }

		if (action.equals("login")) {
            
			String appId = args.getString(0);
			String token  = args.getString(1);
			String account = args.getString(2);
            
           
            // appId =  "2f4796015c4f4145a089ed6be575dee1";
            // String certificate =  "a4388710702c4d948b5781ebbcb99933";

                //  try{

                //   Agora. getToken( appId, certificate,  account,  expiredTsInSeconds);
                // Agora. getToken( appId, certificate,  account,  expiredTsInSeconds);
                  if(this.login(appId, token, account )){
                  //callbackContext.success(appId);   
            }
            else{

                //  callbackContext.error("log fail");
            }
            //    }
            //    catch(NoSuchAlgorithmException e){

            //     return false;
            //    }
              
           
			
			
            return true;
        }
		
		if (action.equals("logout")) {
            
			this.logout();
			
            return true;
        }
		
        if (action.equals("leaveChannel")) {
            RtcEngineCreator.getInstance().getRtcEngine().leaveChannel();
          
        }
        // if (action.equals("channelLeave")) {

        //    final String channel = args.getString(0);
        //    this.channelLeave(channel);
          
        // }



        if (action.equals("joinChannel")) {
			final String appId = args.getString(0);
			final String agoraMediaToken = args.getString(1);
            final String channel = args.getString(2);
            final int optionalUID = Integer.parseInt( args.getString(3));
			final String account = args.getString(4);
			final String peerName = args.getString(5);
			final int chatMode = Integer.parseInt( args.getString(6));
			
		   boolean playAudio = false;
		   this.joinChannel(appId, agoraMediaToken, channel, optionalUID,  account, peerName, chatMode, playAudio );
        }
        if (action.equals("unMuteLocalStream")) {
					
		   this.unMuteLocalStream();
        }


        
        if (action.equals("startLecture")) {
            if (RtcEngineCreator.getInstance().getAppId().equals("")) {
                callbackContext.error("call setKey() first!");
                return false;
            }

            final String channel = args.getString(0);

            appActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Intent myIntent = new Intent(appActivity, VideoActivity.class);
                    Bundle bundle = new Bundle();
                    bundle.putString("channel", channel);
                    bundle.putString("lectureMode", "start");
                    myIntent.putExtras(bundle);
                    appActivity.startActivity(myIntent);
                }
            });
            return true;
        }

        if (action.equals("joinLecture")) {
            if (RtcEngineCreator.getInstance().getAppId().equals("")) {
                callbackContext.error("call setKey() first!");
                return false;
            }

            final String channel = args.getString(0);

            appActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Intent myIntent = new Intent(appActivity, VideoActivity.class);
                    Bundle bundle = new Bundle();
                    bundle.putString("channel", channel);
                    bundle.putString("lectureMode", "join");
                    myIntent.putExtras(bundle);
                    appActivity.startActivity(myIntent);
                }
            });
            return true;
        }

		 if (action.equals("channelInviteUser")) {
			final String appId = args.getString(0);
			final String agoraMediaToken = args.getString(1);
            final String channel = args.getString(2);
            final int optionalUID = Integer.parseInt( args.getString(3));
			final String account = args.getString(4);
			final String accountName = args.getString(5); 
            final String extra = args.getString(6); 
            final int chatMode = Integer.parseInt( args.getString(7));
         
            this.channelInviteUser( appId,  agoraMediaToken,  channel,  optionalUID,   account,  accountName, extra,chatMode);
            callbackContext.success(chatMode);
        }
        
         if (action.equals("channelInviteEnd")) {
			final String channelID = args.getString(0);
			final String account = args.getString(1);
             final int uid = Integer.parseInt( args.getString(2));
            this.channelInviteEnd( channelID, account, uid);
        }

        
        if (action.equals("queryUserStatus")) {
		
			final String account = args.getString(0);
			
            this.queryUserStatus(account);

            callbackContext.success();

        }

		 if (action.equals("channelInviteRefuse")) {
			
            final String channel = args.getString(0);
           
			final String account = args.getString(1);
            final int uid = Integer.parseInt( args.getString(2));
			final String extra = args.getString(3); 
			
            this.channelInviteRefuse( channel, account, uid, extra);
        }
		 if (action.equals("channelInviteAccept")) {
			
            final String channelID = args.getString(0);
           
			final String account = args.getString(1);
            final int uid = Integer.parseInt( args.getString(2));
			final String extra = args.getString(3); 
			
            this.channelInviteAccept(  channelID, account, uid, extra);
        }
        
		
        if (action.equals("listenForEvents")) {
            eventCallbackContext = callbackContext;
            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, 0);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);
            return true;
        }

         if (action.equals("disableVideo")) {
            RtcEngineCreator.getInstance().disableVideo();
            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, "calling executed");
            
            callbackContext.sendPluginResult(pluginResult);
            return true;
        }

        
        return super.execute(action, args, callbackContext);
    }


	
	public static AgoraAPIOnlySignal getAgoraAPIOnlySignal(){
		
		return m_agoraAPI;
	}
    public static void notifyEvent(String event, String data) {
    
       


        final   String  aEvent = event;
        final   String  aData = data;

         if (eventCallbackContext != null) {
        //    new Thread(new Runnable() {
        //         @Override
        //         public void run() {
        JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("eventName");
            jsonText.value(aEvent);
            jsonText.key("data");
            jsonText.value(aData);
            jsonText.endObject();
        } catch (JSONException ignored) {
        }

        PluginResult result = new PluginResult(PluginResult.Status.OK, jsonText.toString());
        result.setKeepCallback(true);
        eventCallbackContext.sendPluginResult(result);
                // }
            // }).start();
         }
    }
	
    public static void channelInviteEnd(String channelID,String account,int uid) {
        if(m_agoraAPI != null){

           m_agoraAPI. channelInviteEnd( channelID, account, uid);

        }

        RtcEngineCreator.getInstance().destroyRtcEngine();
       
     }

    private boolean login(String appId,String token, String account  ) {
		 
          
           
		 try {
				m_agoraAPI = AgoraAPIOnlySignal.getInstance(this.appContext, appId);
                
                RtcEngineCreator.getInstance().getMessageHandler().addSignalingCallback();

               
				} 
			catch (Exception e) {
					Log.e(TAG, Log.getStackTraceString(e));
                    
					return false;
					// appActivity.finish();	
					
		}

           	
            //    int expiredTsInSeconds =( (int) new Date().getTime()/1000) +  3600*24;
              
                  // token = Agora. getToken( appId, certificate,  account,  expiredTsInSeconds);
                   m_agoraAPI.login2(appId, account, token, 0, "", 30, 3);
              
			
			
			
		   
           
           
			if(appId != RtcEngineCreator.getInstance().getAppId()){
				
				if(RtcEngineCreator.getInstance().getRtcEngine() != null){
					RtcEngineCreator.getInstance().destroyRtcEngine();
				}
				
			}
			RtcEngineCreator.getInstance().setAppId(appId);
			
			return true;
		 
	 }
	  private void logout() {
		 
		 if(m_agoraAPI!=null){
			 
			 m_agoraAPI.logout();
		 }
		 
	 }
	 
	public void queryUserStatus(String account){

        this.m_agoraAPI.queryUserStatus(account);

     }
      private void channelInviteUser(String appId, String token, String channelID, int optionalUID,  String account, String accountName, String extra, int chatMode) {
		
		  JSONStringer jsonText = new JSONStringer();

        try {
            jsonText.object();
            jsonText.key("_require_peer_online");
            jsonText.value(0);
			
            jsonText.key("_timeout");
            jsonText.value(30);
			jsonText.key("srcNum");
            jsonText.value(accountName);
			
            jsonText.endObject();
        } catch (JSONException ignored) {
        }
	
        boolean playAudio = true;
		this.joinChannel(appId, token, channelID, optionalUID,  account, accountName, chatMode, playAudio );
        
        this.m_agoraAPI.channelInviteUser2(channelID, account, extra);
        this.queryUserStatus(account);

        
        
	 }
	 
	 private void channelInviteRefuse(String channelID,String account,int uid, String extra){
		 
		this.m_agoraAPI.channelInviteRefuse(channelID, account, uid, extra); 
		 
	 }
	 private void joinChannel(String appId, String  token, String channel, int optionalUID, String account,  String peerAccountName, int chatMode, boolean playAudio) {
		
       
		 if (RtcEngineCreator.getInstance().getAppId().equals("") || RtcEngineCreator.getInstance().getAppId() == null) {
                this.notifyEvent("onAppIdInValid", "call setKey() first!");
                return;
            }
		

             RtcEngineCreator.getInstance().setAppId(appId);
			 RtcEngineCreator.getInstance().setToken(token);
			 
			  final String achannel = channel;
              final int aoptionalUID = optionalUID;
              final String apeerAccountName = peerAccountName;
              final String aaccount = account; // 对方的account， 自己加入频道不用account
              final int achatMode = chatMode;
             final boolean aplayAudio = playAudio;
             
             
              appActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Intent myIntent = new Intent(appActivity, VideoActivity.class);
                    Bundle bundle = new Bundle();
                    bundle.putString("channel", achannel);
					
                    bundle.putInt("optionalUID", aoptionalUID);
					
					bundle.putString("peerName", apeerAccountName);
                    bundle.putString("account", aaccount);
                    bundle.putInt("chatMode", achatMode);
                    
                    bundle.putBoolean("playAudio", aplayAudio);
                    bundle.putString("lectureMode", "no");
                    myIntent.putExtras(bundle);
                    appActivity.startActivity(myIntent);
                    
                }
            });
            return;
	 }
	 

      private void unMuteLocalStream() {
		
		
			RtcEngineCreator.getInstance().unMuteLocalStream();
			

         
	 }
	 
	 
     public void channelInviteAccept(String channelID,String account,int uid,String extra){

         this.m_agoraAPI.channelInviteAccept( channelID, account, uid, extra);
     }


}
