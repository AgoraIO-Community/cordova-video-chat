package com.panopath.plugin.agora;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.util.Log;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.ImageButton;
import android.graphics.PorterDuff;
import io.agora.rtc.*;
import io.agora.rtc.video.VideoCanvas;
import android.media.MediaPlayer;
import android.media.AudioManager;
import android.content.Context;
public class VideoActivity extends BaseEngineEventHandlerActivity {

    Activity self = this;
    FrameLayout mainFrame, localVideoFrame;
    TextView waitingNotification;
    RtcEngine mRtcEngine;
    SurfaceView localView, remoteView;
    ImageButton btn_video, btn_switch_camera,btn_speaker;
    String lectureMode = "";
    int chatMode = -1;
    Integer userCount = 0;
    Boolean lecturerInRoom = false;
	String peerName = "未知";
    Boolean remoteJoined = false;
    MediaPlayer mp = null;
    AudioManager am;
    @SuppressLint("SetTextI18n")
    private void updateNotificationText() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (userCount == 0) {
                    if (lectureMode.equals("no")) {
                        waitingNotification.setText(peerName + "\n正在等待对方接受邀请");
                    } else if (lectureMode.equals("start")) {
                        waitingNotification.setText("正在等待听众");
                    }
                } else {
                    if (lectureMode.equals("no") || lectureMode.equals("join")) {
                        waitingNotification.setText("");
                    } else {
                        waitingNotification.setText("当前有" + userCount + "位听众\n" + userCount + " " + (userCount == 1 ? "person" : "people") + " in the room.");
                    }
                }

                if (lectureMode.equals("join") && (!lecturerInRoom)) {
                    waitingNotification.setText("正在等待主讲人\nWaiting for the lecturer");
                }
            }
        });
    }

    @Override
    public void onLeaveChannel(IRtcEngineEventHandler.RtcStats stats) {
        try {
            super.onLeaveChannel(stats);
             RtcEngineCreator.getInstance().destroyRtcEngine();
         RtcEngineCreator.getInstance().setEngineEventHandlerActivity(null);
            finish();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onFirstRemoteVideoDecoded(final int uid, int width, int height, int elapsed) {
        super.onFirstRemoteVideoDecoded(uid, width, height, elapsed);
    }

    @Override
    public void onUserJoined(int uid, int elapsed) {
         this.stopPlaying();
        this.remoteJoined = true;
        if (lectureMode.equals("start")) {
            //发起讲座时不设置remote
        } else if (lectureMode.equals("join")) {
            //参与讲座时，
            //只有10000加入时才设置
            if (uid == 10000)
                setRemoteToUid(uid);
        } else {
            //普通聊天时均设置
            setRemoteToUid(uid);
        }


        userCount++;

        if (lectureMode.equals("join") && uid == 10000) {
            lecturerInRoom = true;
        }

        updateNotificationText();
        super.onUserJoined(uid, elapsed);

    }

    @Override
    public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
       this.playAudio();
        super.onJoinChannelSuccess(channel, uid, elapsed);
    }
   public void playAudio(){

     Bundle bundle = getIntent().getExtras();
        FakeR fakeR = new FakeR(this);
        boolean playAudio = bundle.getBoolean("playAudio", false);

        if(playAudio){
              mp = MediaPlayer.create(this,  fakeR.getId("raw", "ios_7_apple"));
        
              mp.setLooping(true);       
              
              
             mp.start();

        }
   }

    @Override
    public void onUserOffline(final int uid) {

        if (lectureMode.equals("join") && uid == 10000) {
            lecturerInRoom = false;
        }

        this.remoteJoined = false;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                userCount--;
                updateNotificationText();

                if (lectureMode.equals("no")) {

                    //非讲座模式，需要移除remoteView
                    //如果是讲座模式,
                    //是主讲人的话，根本没有remoteView，无需移除
                    //是参与者的话，要判断uid是否为10000
                    if (remoteView.getParent() != null)
                        ((ViewGroup) remoteView.getParent()).removeView(remoteView);

                    //刷新localView (否则程序会崩溃)
                    if (localView.getParent() != null)
                        ((ViewGroup) localView.getParent()).removeView(localView);

                    mainFrame.addView(localView, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));

                } else if (lectureMode.equals("join")) {

                    //讲座模式，判断uid是否为10000，是的话移除remoteView
                    if (uid == 10000)
                        if (remoteView.getParent() != null)
                            ((ViewGroup) remoteView.getParent()).removeView(remoteView);

                }
            }
        });
        super.onUserOffline(uid);
    }


    void setRemoteToUid(final int uid) {

        if(this.chatMode != 1){
            return ;
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {

                //localView 在 remoteView 前先加，否则remoteView会把localView覆盖掉
                if (lectureMode.equals("no")) {
                    //非讲座模式时，要有左下角小框能看到自己，所以设置localView

                    if (localView.getParent() != null)
                        ((ViewGroup) localView.getParent()).removeView(localView);

                    localVideoFrame.addView(localView, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
                }


                //设置remoteView （这仅仅在非讲座模式/参与别人讲座时会触发。自己开讲座时不会触发。）
                mRtcEngine.setupRemoteVideo(new VideoCanvas(remoteView, VideoCanvas.RENDER_MODE_ADAPTIVE, uid));

                if (remoteView.getParent() != null)
                    ((ViewGroup) remoteView.getParent()).removeView(remoteView);

                mainFrame.addView(remoteView, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
            }
        });
    }


    @Override
    public void onBackPressed() {
          if(RtcEngineCreator.getInstance().getToken() !=null){
                    Bundle bundle = getIntent().getExtras();
                   String channel =   bundle.getString("channel");
                   String account =   bundle.getString("account");
                   int uid = 0;
                   
                   Agora.channelInviteEnd( channel, account, uid);
           }
                 
        this.endChat();
        
    }

    @Override
    public void endChat(){


                
              if(mRtcEngine!=null){
                mRtcEngine.leaveChannel();}

       
         this.stopPlaying();

        
        //  getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
       
        

    }


    


    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);

      
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        FakeR fakeR = new FakeR(this);
        // am = (AudioManager)getSystemService(Context.AUDIO_SERVICE);
       


        // int result = am.requestAudioFocus(afChangeListener, AudioManager.STREAM_MUSIC, 
        //         AudioManager.AUDIOFOCUS_GAIN);
        
       
        // if(result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED)
       
        Bundle bundle = getIntent().getExtras();
        lectureMode = bundle.getString("lectureMode", "no");

        this.chatMode = bundle.getInt("chatMode", 1);
		this.peerName = bundle.getString("peerName", this.peerName);
        

        setContentView(fakeR.getId("layout", "video"));

        mainFrame = (FrameLayout) findViewById(fakeR.getId("id", "mainFrame"));
        localVideoFrame = (FrameLayout) findViewById(fakeR.getId("id", "localVideoFrame"));
        waitingNotification = (TextView) findViewById(fakeR.getId("id", "waiting_notification"));

        
       

       
       
		
        RtcEngineCreator.getInstance().setRtcEngine();
        mRtcEngine = RtcEngineCreator.getInstance().getRtcEngine();

        RtcEngineCreator.getInstance().setEngineEventHandlerActivity(this);

        
        if(mRtcEngine == null){

            Agora.notifyEvent("onRtcCreateErr","rtcEngine not created");
            this.finish();
        }
        
        if (!lectureMode.equals("join") )
        {


            if(chatMode == 1){

                mRtcEngine.enableVideo();
            }
            else{
                mRtcEngine.disableVideo();

            }
             
        }
           

         
         mRtcEngine.muteLocalAudioStream(true);
         if(chatMode == 1)
         {
            // mRtcEngine.muteLocalVideoStream(true);

         }
         


        localView = RtcEngine.CreateRendererView(getApplicationContext());
        remoteView = RtcEngine.CreateRendererView(getApplicationContext());


        if (lectureMode.equals("join")) {
            localVideoFrame.setVisibility(View.GONE);
        } else {

             if(chatMode == 1){
                 mRtcEngine.setupLocalVideo(new VideoCanvas(localView));
                 mainFrame.addView(localView, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));

             }
           
        }

        Integer UID = 0;

        if (lectureMode.equals("no")) {
            UID = bundle.getInt("optionalUID", 0);
        } else if (lectureMode.equals("start")) {
            UID = 10000;
        } else if (lectureMode.equals("join")) {
            UID = 0;
        }

        
        String token = RtcEngineCreator.getInstance().getToken();
        int ret =  mRtcEngine.joinChannel(token=="null"?null:token,
                bundle.getString("channel"),
                "",
                UID
        );
        Agora.notifyEvent("join channel ",""+ ret + " " + RtcEngineCreator.getInstance().getToken() + " " +  RtcEngineCreator.getInstance().getAppId() );
        
        
        updateNotificationText();  

        if(chatMode == 1){



            final View switchCameraBtn = findViewById(fakeR.getId("id", "btn_switch_camera"));
           
             switchCameraBtn.setOnClickListener(new View.OnClickListener() {
                 @Override
                public void onClick(View view) {
                mRtcEngine.switchCamera();
                 }
             });


            // final View muteVideoButton = findViewById(fakeR.getId("id", "btn_video"));
            //   muteVideoButton.setOnClickListener(new View.OnClickListener() {
            //         @Override
            //         public void onClick(View view) {
             
            //          onLocalVideoMuteClicked(view);
            //        }
            //        });

          }
          else{
            // final View muteVideoButton = findViewById(fakeR.getId("id", "btn_video"));
            final View switchCameraBtn = findViewById(fakeR.getId("id", "btn_switch_camera"));
             
            // if(muteVideoButton != null)   muteVideoButton. setVisibility(View.GONE);
            if(switchCameraBtn != null)  switchCameraBtn. setVisibility(View.GONE);
            //this.onVideoStopped();
          }
        
          final ImageButton goBackBtn = (ImageButton) findViewById(fakeR.getId("id", "btn_go_back"));
             
          goBackBtn.setOnClickListener(new View.OnClickListener() {
                 @Override
                    public void onClick(View view) {
                     onBackPressed();
                }
            });
       
       
        //  final View mutVoiceBtn = findViewById(fakeR.getId("id", "btn_mic"));
        //  mutVoiceBtn.setOnClickListener(new View.OnClickListener() {
        //     @Override
        //     public void onClick(View view) {
        //           onLocalAudioMuteClicked(view);
        //     }
        // }); 

         final View speakerBtn = findViewById(fakeR.getId("id", "btn_speaker"));
         speakerBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                  onSpeakerButtonClicked(view);
            }
        }); 
         


       
    }
    @Override
     public void stopPlaying() {
            if (mp != null) {
                mp.stop();
                mp.release();
                mp = null;
           }
        }
     public void onLocalVideoMuteClicked(View view) {
        FakeR fakeR = new FakeR(this);
        ImageButton iv = (ImageButton) view;
        if (iv.isSelected()) {
            iv.setSelected(false);
            iv.clearColorFilter();
        } else {
            iv.setSelected(true);
            iv.setColorFilter(getResources().getColor( fakeR.getId("color", "colorPrimary" )), PorterDuff.Mode.MULTIPLY);
        }

        mRtcEngine.muteLocalVideoStream(iv.isSelected());

        String frameName = null;
        if(this.remoteJoined == true){

            frameName = "localVideoFrame";
        }
        else{
            frameName = "mainFrame";

        }
        FrameLayout container = (FrameLayout) findViewById(fakeR.getId("id", frameName) );
        SurfaceView surfaceView = (SurfaceView) container.getChildAt(0);
        surfaceView.setZOrderMediaOverlay(!iv.isSelected());
        surfaceView.setVisibility(iv.isSelected() ? View.GONE : View.VISIBLE);
        Agora.notifyEvent("onMuteLocalVideoStream","已停止");
    }

  public void onSpeakerButtonClicked(View view) {
     FakeR fakeR = new FakeR(this);
        ImageButton iv = (ImageButton) view;
        if (iv.isSelected()) {
            iv.setSelected(false);
            iv.clearColorFilter();
        } else {
            iv.setSelected(true);
            iv.setColorFilter(getResources().getColor( fakeR.getId("color", "colorPrimary" )), PorterDuff.Mode.MULTIPLY);
        }

        mRtcEngine.setEnableSpeakerphone(iv.isSelected());

 }
    // Tutorial Step 9
    public void onLocalAudioMuteClicked(View view) {
        FakeR fakeR = new FakeR(this);
        ImageButton iv = (ImageButton) view;
        if (iv.isSelected()) {
            iv.setSelected(false);
            iv.clearColorFilter();
        } else {
            iv.setSelected(true);
            iv.setColorFilter(getResources().getColor( fakeR.getId("color", "colorPrimary" )), PorterDuff.Mode.MULTIPLY);
        }

        mRtcEngine.muteLocalAudioStream(iv.isSelected());
    }

   public void 	onVideoStopped (){
     FakeR fakeR = new FakeR(this);
    //    if(mRtcEngine !=null){

    //        if(this.chatMode == 1){
    //            mRtcEngine.disableVideo();
    //            this.chatMode = 2;
    //        }
    //    }
     
   }
     @Override
    public void enableVideo(){

         mRtcEngine.enableVideo();
    }
      @Override
    public void disableVideo(){

         mRtcEngine.disableVideo();
    }
     @Override
    public void fallbackToAudioMode(){
         FakeR fakeR = new FakeR(this);
          final View switchCameraBtn = findViewById(fakeR.getId("id", "btn_switch_camera"));
        runOnUiThread(new Runnable() {
            @Override
            public void run() { 

                             if( mRtcEngine!=null && chatMode == 1)
        {
            
              
              chatMode = 2;
            
             
           
            if(switchCameraBtn != null)  switchCameraBtn. setVisibility(View.GONE);
            mRtcEngine.muteLocalVideoStream(true);
            
            mainFrame.setVisibility(View.GONE);
            localVideoFrame.setVisibility(View.GONE);
        }

         }

            });
       
   
    }
}
