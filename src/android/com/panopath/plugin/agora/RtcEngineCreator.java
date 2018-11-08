package com.panopath.plugin.agora;

import android.content.Context;
import io.agora.AgoraAPIOnlySignal;
import io.agora.rtc.RtcEngine;

public class RtcEngineCreator {
    private String appId;
	private String token = null; 
    private MessageHandler messageHandler;

    private Context applicationContext;
    private RtcEngine rtcEngine = null;


    public MessageHandler getMessageHandler() {
        return messageHandler;
    }

    public RtcEngineCreator() {
        messageHandler = new MessageHandler();
		
    }

    public Context getApplicationContext() {
        return applicationContext;
    }

    public void setApplicationContext(Context applicationContext) {
        this.applicationContext = applicationContext;
    }

    public void unMuteLocalStream(){

         if(this.rtcEngine != null){

             this.rtcEngine.muteLocalAudioStream(false);
             this.rtcEngine.muteLocalVideoStream(false);
            }

    }
    public String getAppId() {
        return appId;
    }

    public void setAppId(String appId) {


        if(appId != this.appId){
            this.appId = appId;
            if(this.rtcEngine != null){

                this.destroyRtcEngine();
                
            }
            this.setRtcEngine();
        }
       
    }

    public void disableVideo(){
            
            
            if(rtcEngine != null)
            { rtcEngine.disableVideo();}
            if (messageHandler.getActivity() != null){

                messageHandler.getActivity().fallbackToAudioMode();
            }
            
    }
	public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public void setRtcEngine() {
        if (rtcEngine == null) {
			
			try{
				
                // rtcEngine = RtcEngine.create(applicationContext, "2f4796015c4f4145a089ed6be575dee1", messageHandler);
				rtcEngine = RtcEngine.create(applicationContext, getAppId(), messageHandler);
			}
			catch(Exception e){
				
				messageHandler.onError(999);
			}
            
        }
    }

    
	public void destroyRtcEngine() {
        if (rtcEngine != null) {
			
			try{
				
				RtcEngine.destroy();
				rtcEngine = null;
			}
			catch(Exception e){
				
				messageHandler.onError(999);
			}
            
        }
    }
    public RtcEngine getRtcEngine() {
		
		
        return rtcEngine;
    }

    public void setEngineEventHandlerActivity(BaseEngineEventHandlerActivity engineEventHandlerActivity) {
        messageHandler.setActivity(engineEventHandlerActivity);
    }

 
    
    private static final RtcEngineCreator holder = new RtcEngineCreator();

    public static RtcEngineCreator getInstance() {
        return holder;
    }

}