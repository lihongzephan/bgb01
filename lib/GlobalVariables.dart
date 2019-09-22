// This program stores ALL global variables required by ALL darts

// Imports

// Import Flutter Darts
import 'dart:io';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:camera/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import Self Darts
import 'LangStrings.dart';
import 'Utilities.dart';

// Import Pages

enum GVActions {
  Increment
} // The reducer, which takes the previous count and increments it in response to an Increment action.

int reducerRedux(int intSomeInteger, dynamic action) {
  if (action == GVActions.Increment) {
    return intSomeInteger + 1;
  }
  return intSomeInteger;
}

enum TtsState { playing, stopped }

class gv {
  // Important Vars
  static String strVersion = '010101';
  static int intDbVersion = 1;
  static String strServerVersion = '010101';
  static String strAppDownloadURL = '';

  // Current Page
  // gstrCurPage stores the Current Page to be loaded
  static var gstrCurPage = 'SelectLanguage';
  static var gstrLastPage = 'SelectLanguage';

  // Init gintBottomIndex
  // i.e. Which Tab is selected in the Bottom Navigator Bar
  static var gintBottomIndex = 1;

  // Declare Language
  // i.e. Language selected by user
  static var gstrLang = '';

  // bolLoading is used by the 'package:modal_progress_hud/modal_progress_hud.dart'
  // Inside a particular page that use Modal_Progress_Hud  :
  // Set it to true to show the 'Loading' Icon
  // Set it to false to hide the 'Loading' Icon
  static bool bolLoading = false;

  // Defaults

  // Allow Duplicate Login?
  // static const bool bolAllowDuplicateLogin = false;

  // Min / Max of Fields
  // User ID from 3 to 20 Bytes
  static const int intDefUserIDMinLen = 3;
  static const int intDefUserIDMaxLen = 20;

  // Password from 6 to 20 Bytes
  static const int intDefUserPWMinLen = 6;
  static const int intDefUserPWMaxLen = 20;

  // Nick Name from 3 to 20 Bytes
  static const int intDefUserNickMinLen = 3;
  static const int intDefUserNickMaxLen = 20;
  static const int intDefEmailMaxLen = 60;

  // Activation Code Length
  static const int intDefActivateLength = 6;

  // Declare STORE here for Redux

  // Store for Redux
  static Store<int> storeMain = new Store<int>(reducerRedux, initialState: 0);
  static Store<int> storeSettingsMain =
      new Store<int>(reducerRedux, initialState: 0);
  static Store<int> storePerInfo =
      new Store<int>(reducerRedux, initialState: 0);
  static Store<int> storeSelectFiles =
      new Store<int>(reducerRedux, initialState: 0);
  static Store<int> storeHome = new Store<int>(reducerRedux, initialState: 0);

  // Declare SharedPreferences && Connectivity && Camera
  static var NetworkStatus;
  static SharedPreferences pref;
  static List<CameraDescription> cameras;
  static Directory dirPathExternal;
  static Directory dirPathApp;
  static String strMoviePath;
  static String strImagePath;
  static String strPhotoDefPath;

  // Database Related
  static var timLastHB = DateTime.now().millisecondsSinceEpoch;
  static int intMainThreadTimer = 30000;
  static int intMainThreadTimerDefault = 30000;

  static Future<void> Init() async {
    pref = await SharedPreferences.getInstance();

    // Detect Connectivity
    NetworkStatus = await (Connectivity().checkConnectivity());
    if (NetworkStatus == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      ut.funDebug('Mobile Network');
    } else if (NetworkStatus == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      ut.funDebug('WiFi Network');
    }

    // Camera
    cameras = await availableCameras();

    // Init listSelectFiles
    for (var i = 0; i < 100; i++) {
      listSelectFiles.add('List: ' + i.toString());
    }
    if (Platform.isAndroid) {
      ut.funDebug('Running Android');
      dirPathExternal = await getExternalStorageDirectory();
    } else {
      ut.funDebug('Running IOS');
      dirPathExternal = await getApplicationDocumentsDirectory();
    }

    dirPathApp = await getApplicationDocumentsDirectory();
    strMoviePath = '${gv.dirPathApp.path}/Movies';
    strImagePath = '${gv.dirPathApp.path}/Images';
    await Directory(strMoviePath).create(recursive: true);
    await Directory(strImagePath).create(recursive: true);
    try {
      if (Platform.isAndroid) {
        ut.funDebug('Platform is Android');
        strPhotoDefPath = '${gv.dirPathExternal.path}/DCIM/Camera';
        await Directory(strPhotoDefPath).create(recursive: true);
      } else if (Platform.isIOS) {
        ut.funDebug('Platform is IOS');
        strPhotoDefPath = '${gv.dirPathExternal.path}/DCIM/Camera';
        await Directory(strPhotoDefPath).create(recursive: true);
      }
    } catch (err) {
      strPhotoDefPath = '';
      ut.funDebug('External Path Creation Error: ' + err.toString());
    }

    //TTS Related
    flutterTts.setStartHandler(() {
      ttsState = TtsState.playing;
      ut.funDebug('TTS Speak Start');
    });

    flutterTts.setCompletionHandler(() async {
      ttsState = TtsState.stopped;
      timHomeFinishAction = DateTime.now().millisecondsSinceEpoch;
//      bolWebRtcShouldInit = true;
//      storeMain.dispatch(Actions.Increment);
      ut.funDebug('TTS Speak Stopped');
    });

    flutterTts.setErrorHandler((msg) {
      ttsState = TtsState.stopped;
      gv.timHomeFinishAction = DateTime.now().millisecondsSinceEpoch;
      ut.funDebug('TTS Speak Error in setErrorHandler: ' + msg.toString());
    });
  }

  static getString(strKey) {
    var strResult = '';
    strResult = pref.getString(strKey) ?? '';
    return strResult;
  }

  static setString(strKey, strValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(strKey, strValue);
  }

  // Vars For Pages

  // Var For Activate
  static var strActivateError = '';
  static var aryActivateResult = [];
  static var timActivate = DateTime.now().millisecondsSinceEpoch;

  // Var For Change Password
  static var strChangePWError = '';
  static var aryChangePWResult = [];
  static var timChangePW = DateTime.now().millisecondsSinceEpoch;

  // Var For Forget Password
  static var strForgetPWError = '';
  static var aryForgetPWResult = [];
  static var timForgetPW = DateTime.now().millisecondsSinceEpoch;

  // Vars for Home
  static bool bolHomeVideoTimerStart = false;
  static double dblHomeVDSliderValueMS = 0.0;
  static bool bolHomeRecording = false;
  static var timHomeCameraStart = DateTime.now().millisecondsSinceEpoch;
  static String strHomeFileJustPicked = '';
  static String strHomeImageFileWithPath = '';
  static String strHomeMovieFileNoPath = '';
  static String strHomeCurrentPlayingVideoFilePath = '';
  static int intHomeVDDurationMS = 0;
  static String strHomeAction = 'Default';
  static String strHomeTTS = 'Hello';
  static FlutterTts flutterTts = new FlutterTts();
  static TtsState ttsState = TtsState.stopped;
  static String strHomeImageUrl = '';

  static bool bolHomeTakePhotoStart = false;
  static bool bolHomeTakePhotoEnd = true;

  static int intHomeCameraCountDown = 3;

  // Var For Login
  static var strLoginID = '';
  static var strLoginPW = '';
  static var strLoginError = '';
  static var aryLoginResult = [];
  static var strLoginStatus = '';
  static var bolFirstTimeCheckLogin = false;
  static var timLogin = DateTime.now().millisecondsSinceEpoch;

  // Var For PersonalInformation
  static var strPerInfoError = ls.gs('ChangeEmailNeedActivateAgain');
  static var aryPerInfoResult = [];
  static var timPerInfo = DateTime.now().millisecondsSinceEpoch;
  static var strPerInfoUsr_NickL = '';
  static var strPerInfoUsr_EmailL = '';
  static var ctlPerInfoUserNick = TextEditingController();
  static var ctlPerInfoUserEmail = TextEditingController();
  static var strPerInfoUsr_Expiry = '';
  static var intPerInfoUsr_VDMinLeft = 0;
  static bool bolPerInfoFirstCall = false;

  // Read Only for that page
  static var strPerInfoUserID = '';
  static var strPerInfoExpiry = '';
  static var strPerInfoMinLeft = '';

  // Var For Register
  static var strRegisterError = ls.gs('EmailAddressRegisterWarning');
  static var aryRegisterResult = [];
  static var timRegister = DateTime.now().millisecondsSinceEpoch;

  // Var For SelectFiles
  static List<String> listSelectFiles = [];
  static int intSelectFilesEach = 10;
  static int intSelectFilesLast = 10;
  static bool bolSelectFilesFirstInit = true;
  static var arySelectFilesFiles;
  static var arySelectFilesMovies;
  static var arySelectFilesImages;
  static String strSelectFilesLastVideo = '';
  static bool bolSelectFilesAllowMMS = false;
  static var ctlSelectFilesCheckPassword = TextEditingController();
  static List<String> arySelectFilesDuration = [];

  // Var For BottomBar
  static const int intHomeBottomIndex = 0;
  static const int intSettingsMainBottomIndex = 1;

  // Var For ShowDialog
  static int intShowDialogIndex = 0;

  // socket.io related
  static const String URI = 'http://www.zephan.top:10531';
  static bool gbolSIOConnected = false;
  static SocketIOManager manager = SocketIOManager();
  static SocketIO socket;
  static SocketIO socketLast;
  static int intSocketTimeout = 10000;
  static int intHBInterval = 500;
  static int intHBFinalInterval = 5000;
  static bool bolUploadingToSocketIOServer = false;

  // WebRTC Related
  static String strWebRtcIP = 'www.zephan.top';
  static String strWebRtcSelfID = '';
  static bool bolWebRtcInCalling = false;
  static String strWebRtcDisplayName = 'BigAIBot';
  static List<dynamic> lstWebRtcPeers;

//  static bool bolWebRtcShouldInit = true;

  static initSocket() async {
    if (!gbolSIOConnected) {
      ut.funDebug('Before socket CreateInstance');
      try {
        await gv.manager.clearInstance(gv.socketLast);
      } catch (err) {
        ut.funDebug('manager.clearInstance socketLast in initSocket Error: ' +
            err.toString());
      }
      try {
        await gv.manager.clearInstance(gv.socket);
      } catch (err) {
        ut.funDebug('manager.clearInstance socket in initSocket Error: ' +
            err.toString());
      }
      socket = await manager.createInstance(SocketOptions(
          URI, transports: [Transports.WEB_SOCKET, Transports.POLLING]));
      socketLast = socket;
      ut.funDebug('After socket CreateInstance');

      socket.onConnect((data) {
        gbolSIOConnected = true;
        ut.funDebug('onConnect');
        ut.showToast(ls.gs('NetworkConnected'));

        if (!bolFirstTimeCheckLogin) {
          bolFirstTimeCheckLogin = true;
          // Check Login Again if strLoginID != ''
          if (strLoginID != '') {
            timLogin = DateTime
                .now()
                .millisecondsSinceEpoch;
            socket.emit('LoginToServer', [strLoginID, strLoginPW, false]);
          }
        }
      });
      socket.onConnectError((data) {
        gv.funDisconnect(socket);
        ut.funDebug('onConnectError');
      });
      socket.onConnectTimeout((data) {
        gv.funDisconnect(socket);
        ut.funDebug('onConnectTimeout');
      });
      socket.onError((data) {
        gv.funDisconnect(socket);
        ut.funDebug('onError');
      });
      socket.onDisconnect((data) {
        gv.funDisconnect(socket);
        ut.funDebug('onDisconnect');
        if (socket == socketLast) {
          ut.showToast('网络已断开');
        }
      });

      // Socket Return from socket.io server
      socket.on('HBReturn', (data) async {
        try {
          ut.funDebug('HBReturn Received');
          timLastHBReceived = DateTime
              .now()
              .millisecondsSinceEpoch;
          // strLoginID = data[0];
          // storeHome.dispatch(GVActions.Increment);
        } catch (err) {
          ut.funDebug('HBReturn Error: ' +
              err.toString());
        }
      });


      // Socket Return from socket.io server

      socket.on('ActivateResult', (data) {
        // Check if the result comes back too late
        if (DateTime
            .now()
            .millisecondsSinceEpoch - timActivate >
            intSocketTimeout) {
          ut.funDebug('Activate result timeout');
          return;
        }
        aryActivateResult = data;
      });

      socket.on('ChangePasswordResult', (data) {
        // Check if the result comes back too late
        if (DateTime
            .now()
            .millisecondsSinceEpoch - timChangePW >
            intSocketTimeout) {
          ut.funDebug('ChangePasswordResult Timeout');
          return;
        }
        aryChangePWResult = data;
      });

      socket.on('ChangePerInfoResult', (data) {
        // Check if the result comes back too late
        if (DateTime
            .now()
            .millisecondsSinceEpoch - timPerInfo >
            intSocketTimeout) {
          ut.funDebug('ChangePerInfo Result Timeout');
          return;
        }
        aryPerInfoResult = data;
      });

      socket.on('ForceLogoutByServer', (data) {
        // Force Logout By Server (Duplicate Login)

        // Clear User ID
        strLoginID = '';
        strLoginPW = '';
        strLoginStatus = '';
        setString('strLoginID', strLoginID);
        setString('strLoginPW', strLoginPW);

        // Show Long Toast
        ut.showToast(ls.gs('LoginErrorReLogin'), true);

        // Reset States
        resetStates();
      });

      socket.on('ForgetPasswordResult', (data) {
        // Check if the result comes back too late
        if (DateTime
            .now()
            .millisecondsSinceEpoch - timForgetPW >
            intSocketTimeout) {
          ut.funDebug('ForgetPasswordResult Timeout');
          return;
        }
        aryForgetPWResult = data;
      });

      socket.on('GetPerInfoResult', (data) {
        // Check if the result comes back too late
        if (DateTime
            .now()
            .millisecondsSinceEpoch - timPerInfo >
            intSocketTimeout) {
          ut.funDebug('GetPerInfo Result Timeout');
          return;
        }
        aryPerInfoResult = data;

        strPerInfoUsr_NickL = gv.aryPerInfoResult[1][0]['usr_nick'];
        strPerInfoUsr_EmailL = gv.aryPerInfoResult[1][0]['usr_email'];

        bolLoading = false;
        ctlPerInfoUserNick.text = gv.strPerInfoUsr_NickL;
        ctlPerInfoUserEmail.text = gv.strPerInfoUsr_EmailL;
      });

      socket.on('LoginResult', (data) {
        try {
          // Check if the result comes back too late
          if (DateTime
              .now()
              .millisecondsSinceEpoch - timLogin >
              intSocketTimeout) {
            ut.funDebug('login result timeout');
            return;
          }

          // Get User Info
          if (data[2].length != 0) {
            // Get Login Status
            strLoginStatus = data[2][0]['usr_status'];
            ut.funDebug('strLoginStatus: ' + strLoginStatus);
          }

          if (data[1] != true) {
            // Not the First Time Login, but a Re-Login
            // Change SettingsMain Login/Logout State
            if (data[0] == '0000') {
              // Re-Login Successful
              // Nothing Changed
              if (strLoginStatus == 'A' && gstrCurPage == 'SettingsMain') {
                storeSettingsMain.dispatch(GVActions.Increment);
              }
            } else {
              // Re-Login Failed
              strLoginID = '';
              strLoginPW = '';
              strLoginStatus = '';
              setString('strLoginID', strLoginID);
              setString('strLoginPW', strLoginPW);
              if (gstrCurPage == 'SettingsMain') {
                storeSettingsMain.dispatch(GVActions.Increment);
              }
              // Display Toast Message

            }
          } else {
            // First Time Login, return aryLoginResult
            aryLoginResult = data;
          }
        } catch (err) {
          ut.funDebug('LoginResult Error: ' + err.toString());
        }
      });

      socket.on('RegisterResult', (data) {
        // Check if the result comes back too late
        if (DateTime
            .now()
            .millisecondsSinceEpoch - timRegister >
            intSocketTimeout) {
          ut.funDebug('Register result timeout');
          return;
        }
        aryRegisterResult = data;
      });

      socket.on('SendEmailAgainResult', (data) {
        // Check if the result comes back too late
        if (DateTime
            .now()
            .millisecondsSinceEpoch - timActivate >
            intSocketTimeout) {
          ut.funDebug('Send Email Again Timeout');
          return;
        }
        aryActivateResult = data;
      });

      socket.on('TtsStart', (data) async {
        ut.funDebug('Tts Start receive from Server');
        try {
          if (gstrCurPage == 'Home') {
            strHomeAction = 'TTS';
            strHomeTTS = data[0];

            ut.funDebug('Tts String from Server: ' + strHomeTTS);

            // Stop Previous TTS
            try {
              if (ttsState == TtsState.playing) {
                var result = await flutterTts.stop();
                if (result == 1) {
                  ttsState = TtsState.stopped;
                }
              }
            } catch (err) {}

//          bolWebRtcShouldInit = false;
            bolHomeStartAction = true;
            timHomeFinishAction = DateTime
                .now()
                .millisecondsSinceEpoch + 60000;

            // Speak New TTS
            try {
              ut.funDebug('Before TTS Start in socket');
              //await flutterTts.setLanguage("en-US");
              //var result = await flutterTts.speak('Hello, I am Bigaibot.');
              var result = await flutterTts.speak(strHomeTTS);
              ;
              if (result == 1) {
                ttsState = TtsState.playing;
              }
              ut.funDebug('After TTS Start in socket');
            } catch (err) {}

            // Dispatch
            storeHome.dispatch(GVActions.Increment);
          }
        } catch (err) {}
      });
      socket.on('TtsStop', (data) async {
        funStopTTS();
      });

      socket.on('ShowImage', (data) async {
        ut.funDebug('ShowImage receive from Server');
        try {
          if (gstrCurPage == 'Home') {
            if (strHomeAction == 'TTS') {
              funStopTTS();
            }

            strHomeAction = 'ShowImage';

            ut.funDebug('Data: ' + data[0]);

            //strHomeImageUrl = data[0][1];
            strHomeImageUrl = data;

            ut.funDebug('Image Url from Server: ' + strHomeImageUrl);

            // Dispatch
            bolHomeStartAction = true;
            timHomeFinishAction = DateTime
                .now()
                .millisecondsSinceEpoch;
            storeHome.dispatch(GVActions.Increment);
          } else {
            ut.funDebug('gstrCurPage: ' + gstrCurPage);
          }
        } catch (err) {
          ut.funDebug(('ShowImage Error in socket: ' + err.toString()));
        }
      });

      socket.on('TakePhoto', (data) async {
        ut.funDebug('TakePhoto receive from Server');
        try {
          if (gstrCurPage == 'Home') {
            if (strHomeAction == 'TTS') {
              funStopTTS();
            }

            strHomeAction = 'TakePhoto';
            // strHomeImageUrl = data[0][1];

            // ut.funDebug('Image Url from Server: ' + strHomeImageUrl);

            // Dispatch
            bolHomeStartAction = true;
            timHomeStartAction = DateTime
                .now()
                .millisecondsSinceEpoch;
            timHomeFinishAction = DateTime
                .now()
                .millisecondsSinceEpoch;

            bolHomeTakePhotoStart = true;
            bolHomeTakePhotoEnd = false;
            intHomeCameraCountDown = 3;

            // Take Photo Should not init WebRTC
//          bolWebRtcShouldInit = false;

            // storeHome OK
            storeHome.dispatch(GVActions.Increment);

            // storeMain NOT OK
//          storeMain.dispatch(GVActions.Increment);

          } else {
            ut.funDebug('gstrCurPage: ' + gstrCurPage);
          }
        } catch (err) {
          ut.funDebug(('TakePhoto Error in socket: ' + err.toString()));
        }
      });
      socket.on('TakePhotoAndClassify', (data) async {
        ut.funDebug('TakePhotoAndClassify receive from Server');
        try {
          if (gstrCurPage == 'Home') {
            if (strHomeAction == 'TTS') {
              funStopTTS();
            }

            strHomeAction = 'TakePhotoAndClassify';
            // strHomeImageUrl = data[0][1];

            // ut.funDebug('Image Url from Server: ' + strHomeImageUrl);

            // Dispatch
            bolHomeStartAction = true;
            timHomeStartAction = DateTime
                .now()
                .millisecondsSinceEpoch;
            timHomeFinishAction = DateTime
                .now()
                .millisecondsSinceEpoch;

            bolHomeTakePhotoStart = true;
            bolHomeTakePhotoEnd = false;
            intHomeCameraCountDown = 3;

//          storeHome.dispatch(Actions.Increment);
            // Take Photo Should not init WebRTC
//          bolWebRtcShouldInit = false;

            storeHome.dispatch(GVActions.Increment);
          } else {
            ut.funDebug('gstrCurPage: ' + gstrCurPage);
          }
        } catch (err) {
          ut.funDebug(
              ('TakePhotoAndClassify Error in socket: ' + err.toString()));
        }
      });

      // Connect Socket
      socket.connect();
    }
    // Create a thread to send HeartBeat
    //var threadHB = new Thread(funTimerHeartBeat);
    //threadHB.start();
  } // End of initSocket()


  static int timLastDisconnect = DateTime.now().millisecondsSinceEpoch;
  static void funDisconnect(SocketIO socketBeingDisconnect) async {
    try {
      timLastDisconnect = DateTime.now().millisecondsSinceEpoch;
      if (socketBeingDisconnect == socketLast) {
        gbolSIOConnected = false;
      }
      ut.funDebug('Before Disconnect');
      await gv.manager.clearInstance(gv.socket);
      ut.funDebug('After Disconnect');
    } catch (err) {
    }
  }


  static void funStopTTS() async {
    try {
      if (ttsState == TtsState.playing) {
        var result = await flutterTts.stop();
        gv.timHomeFinishAction = DateTime.now().millisecondsSinceEpoch;
        if (result == 1) {
          ttsState = TtsState.stopped;
        }
      }
    } catch (err) {}
  }

  // HeartBeat Timer
  static int timLastHBSent = DateTime.now().millisecondsSinceEpoch;
  static bool bolHomeStartAction = false;
  static int timHomeStartAction = DateTime.now().millisecondsSinceEpoch;
  static int timHomeFinishAction = DateTime.now().millisecondsSinceEpoch;
  static int intHomeActionWaitToDefault = 10000;
  static int intHBFinalTimeout = 30000;
  // HeartBeat Timer
  static int intHBActualInterval = 10000;
  static int intHBNoResponseTimeout = 30000;
  static int timLastHBReceived = DateTime.now().millisecondsSinceEpoch;

  // Reset All variables
  static void resetVars() {
    // Reset Vars for Activate
    strActivateError = ls.gs('ActivationCodeWarning');

    // Reset Vars for Login
    strLoginError = '';

    // Reset Vars for Register
    strRegisterError = ls.gs('EmailAddressRegisterWarning');

    // Reset Vars for Per Info
    strPerInfoError = ls.gs('ChangeEmailNeedActivateAgain');

    // Reset Vars for Change Password
    strChangePWError = '';

    // Reset Vars for Forget Password
    strForgetPWError = '';
  }

  // Reset All states
  static void resetStates() {
    switch (gstrCurPage) {
      case 'PersonalInformation':
        storeSettingsMain.dispatch(GVActions.Increment);
        break;
      case 'SettingsMain':
        storeSettingsMain.dispatch(GVActions.Increment);
        break;
      default:
        break;
    }
  }
} // End of class gv
