// Import Flutter Darts
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

// Import Self Darts
import 'GlobalVariables.dart';
import 'LangStrings.dart';
import 'ScreenVariables.dart';
import 'Utilities.dart';

// Import Pages
import 'PageActivate.dart';
import 'PageChangePassword.dart';
import 'PageForgetPassword.dart';
import 'PageHome.dart';
import 'PageLogin.dart';
import 'PagePersonalInformation.dart';
import 'PageRegister.dart';
import 'PageSelectLanguage.dart';
import 'PageSettingsMain.dart';



// Main Program
Future <void> main() async {
  ut.funDebug('Main Start');

  // Set Orientation to PortraitUp
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  await SystemChrome.setEnabledSystemUIOverlays([]);

  // In order to get the window.physicalSize, we have to wait 1 second before running sv.Init()
  // Because in Release Mode, sv.Init() run faster than the system loads the window.physicalSize
  new Future.delayed(new Duration(milliseconds: 1000), () async {
    ut.funDebug('Finish waiting sv.Init()');
    main2();
  });

  ut.funDebug('Main End');
}


Future <void> main2() async {
  ut.funDebug('Start main2');

  // Init Screen Variables
  await sv.Init();

  ut.funDebug('Finish sv Init');

  // Init Global Vars and SharedPreference
  await gv.Init();

  ut.funDebug('Finish gv Init');

  // Get Previous Selected Language from SharedPreferences, if any
  gv.gstrLang = gv.getString('strLang');
  gv.strLoginID = gv.getString('strLoginID');
  gv.strLoginPW = gv.getString('strLoginPW');
  gv.strServerVersion = gv.getString('ServerVersion');
  gv.strAppDownloadURL = gv.getString('AppDownloadURL');
  if (gv.gstrLang != '') {
    // Set Current Language
    ls.setLang(gv.gstrLang);

    // Already has Current Language, so set first page to SettingsMain
    gv.gstrCurPage = 'SettingsMain';
    gv.gstrLastPage = 'SettingsMain';

    if (gv.strServerVersion != '' && gv.strServerVersion != gv.strVersion) {
      gv.gstrCurPage = 'UpgradeApp';
      gv.gstrLastPage = 'UpgradeApp';
    }
  } else {
    ut.funDebug('First Time Use');

    // First Time Use, set Current Language to English
    ls.setLang('EN');
    gv.gstrCurPage = 'SelectLanguage';
    gv.gstrLastPage = 'SelectLanguage';
  }



  // Init socket.io
  //await gv.initSocket();


// ********** Important ****************
  // Cannot initSocket in thread
  int intCounter = 0;
  Future <void> funTimerMain() async {
    try {
      intCounter += 1;

      if (intCounter == 1) {
        await gv.initSocket();
      } else {
        if (!gv.gbolSIOConnected) {
          if (DateTime.now().millisecondsSinceEpoch - gv.timLastDisconnect > gv.intHBActualInterval) {
            ut.funDebug('Try to create new socket and timer');
            gv.timLastDisconnect = DateTime.now().millisecondsSinceEpoch;
            await gv.initSocket();
            ut.funDebug('Try to create new socket and timer end');
          }
        }
      }

      if (DateTime.now().millisecondsSinceEpoch - gv.timLastHBReceived > gv.intHBNoResponseTimeout) {
        gv.timLastHBReceived = DateTime.now().millisecondsSinceEpoch;
        gv.funDisconnect(gv.socket);
      }

      // Check time and send HB
      if (DateTime.now().millisecondsSinceEpoch - gv.timLastHBSent > gv.intHBActualInterval) {
        gv.timLastHBSent = DateTime.now().millisecondsSinceEpoch;
        try {
          if (gv.socket != null) {
              ut.funDebug('Sending HB...' + DateTime.now().toString());
              ut.funDebug('WebRTC Self ID: ' + gv.strWebRtcSelfID);
              gv.socket.emit('HB', [gv.strLoginID, gv.strWebRtcSelfID]);
              gv.timLastHBSent = DateTime.now().millisecondsSinceEpoch;
          }

          if (DateTime.now().millisecondsSinceEpoch - gv.timLastHBReceived >
              gv.intHBFinalTimeout) {
            ut.funDebug('HB Timeout Disconnect Start');
            gv.timLastHBReceived  = DateTime.now().millisecondsSinceEpoch;
            gv.gbolSIOConnected = false;
            gv.socket.connect();
          }

          // Check should show eye
          try {
            if (gv.bolHomeStartAction) {
              if (DateTime.now().millisecondsSinceEpoch - gv.timHomeFinishAction >
                  gv.intHomeActionWaitToDefault) {
                gv.bolHomeStartAction = false;
                gv.strHomeAction = 'Default';
                if (gv.gstrCurPage == 'Home') {
                  gv.storeHome.dispatch(GVActions.Increment);
                  ut.funDebug('storeHome Dispatched for Default');
                }
              }
            }
          } catch (err) {
            // ???
          }

          // Check Camera CountDown
          if (!gv.bolHomeTakePhotoEnd && gv.gstrCurPage == 'Home') {
            if (DateTime.now().millisecondsSinceEpoch - gv.timHomeStartAction > 1000) {
              gv.timHomeStartAction = DateTime.now().millisecondsSinceEpoch;
              gv.intHomeCameraCountDown -= 1;
              gv.storeHome.dispatch(GVActions.Increment);
              ut.funDebug('storeHome Dispatched for Count Down');
            }
          }

        } catch (err) {

        }
      }

      // Check STT
//      if (DateTime.now().millisecondsSinceEpoch - gv.timLastResult > gv.intSTTWaitTime) {
//        gv.timLastResult = DateTime.now().millisecondsSinceEpoch;
//        await gv.sttStop();
//        new Future.delayed(new Duration(milliseconds: 500), () async {
//          gv.sttStart();
//        });
//      }
    } catch (err) {
      ut.funDebug('Main Timer Error: ' + err.toString());
    }
    new Future.delayed(new Duration(milliseconds: gv.intHBInterval), () async {
      funTimerMain();
    });
  }

  funTimerMain();




  ut.funDebug('Start runApp');

  runApp(StoreProvider(
    store: gv.storeMain,
    child: StoreConnector<int, int>(
      builder: (BuildContext context, int intTemp) {
        return ClsMyAppBase(intTemp);
      },
      converter: (Store<int> sintTemp) {
        return sintTemp.state;
      },
    ),
  ));
}
class ClsMyAppBase extends StatelessWidget {
  final intState;

  ClsMyAppBase(this.intState);

  @override
  Widget build(BuildContext context) {
    ut.funDebug('Enter MyApp');

    return MyApp();
  }
}
// Main App
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppLifecycleState _lastLifecycleState;

  @override
  initState() {
    super.initState();
    try {
      WidgetsBinding.instance.addObserver(this);
    } catch (err) {}
  }

  @override
  void dispose() async {
    super.dispose();
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (err) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    _lastLifecycleState = state;
    print('**********   Main Life Cycle State: ' +
        _lastLifecycleState.toString() +
        '   **********');
    if (_lastLifecycleState.toString() == 'AppLifecycleState.paused') {
      try {} catch (err) {}
    } else if (_lastLifecycleState.toString() == 'AppLifecycleState.resumed') {
      await SystemChrome.setEnabledSystemUIOverlays([]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ut.funDebug('Start Main Body');

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable Show Debug

      home: MainBody(),
    );
  }
}



class MainBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Here Return Page According to gv.gstrCurPage
    ut.funDebug('Enter MainBody');
    switch (gv.gstrCurPage) {
      case 'ActivateAccount':
        return ClsActivateAccount();
        break;
      case 'ChangePassword':
        return ClsChangePassword();
        break;
      case 'ForgetPassword':
        return ClsForgetPassword();
        break;
      case 'Home':
        return StoreProvider(
          store: gv.storeHome,
          child: StoreConnector<int, int>(
            builder: (BuildContext context, int intTemp) {
              return ClsHomeBase(intTemp);
            },
            converter: (Store<int> sintTemp) {
              return sintTemp.state;
            },
          ),
        );
        break;
      case 'Login':
        return ClsLogin();
        break;
      case 'PersonalInformation':
        return StoreProvider(
          store: gv.storePerInfo,
          child: StoreConnector<int, int>(
            builder: (BuildContext context, int intTemp) {
              return ClsPersonalInformation(intTemp);
            },
            converter: (Store<int> sintTemp) {
              return sintTemp.state;
            },
          ),
        );
        break;
      case 'Register':
        return ClsRegister();
        break;
      case 'SelectLanguage':
        return ClsSelectLanguage();
        break;
      case 'SettingsMain':
        return StoreProvider(
          store: gv.storeSettingsMain,
          child: StoreConnector<int, int>(
            builder: (BuildContext context, int intTemp) {
              return ClsSettingsMain(intTemp);
            },
            converter: (Store<int> sintTemp) {
              return sintTemp.state;
            },
          ),
        );
        break;
      default:
        break;
    }
    return ClsHome();
  }
}
