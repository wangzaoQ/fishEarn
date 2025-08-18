import 'dart:io';

import 'package:applovin_max/applovin_max.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/LocalConfig.dart';
import 'package:fish_earn/game/GamePage.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'StartPage.dart';
import 'config/GlobalListener.dart';
import 'model/GameViewModel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalCacheUtils.init();
  await EasyLocalization.ensureInitialized();
  if (Platform.isAndroid) {
    // AppLovinMAX.setTestDeviceAdvertisingIds(["fb6469a3-b062-43dc-a53a-24d7cd4d08ce"]);
    MaxConfiguration? sdkConfiguration = await AppLovinMAX.initialize(LocalConfig.maxKey);
    // AppLovinMAX.showMediationDebugger();
    // AppLovinMAX.setVerboseLogging(true);
  }
  // GlobalUtils.dataReset();
  // if (Platform.isAndroid) {
  //   try {
  //     FirebaseManager.instance.init();
  //   } catch (e) {
  //     LogUtils.logD("Firebase init error");
  //   }
  //   try {
  //     FlutterCustomFacebook.instance.initFaceBook(
  //       facebookId: CommonConfig.facebookId,
  //       facebookToken: CommonConfig.facebookToken,
  //       facebookAppName: CommonConfig.facebookName,
  //     );
  //   } catch (e) {
  //     LogUtils.logD("facebook init error");
  //   }
  // }
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('pt')],
      path:
      'assets/translations', // <-- change the path of the translation files
      fallbackLocale: Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GameViewModel()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            debugPaintSizeEnabled = false; // 👈 关闭调试边框线

            return MyApp();
          },
        ),
      ),
    ),
  );
  // runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
// This widget is the root of your application.
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 添加观察者
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initSdk();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 移除观察者
    super.dispose();
  }

  int pauseTime = 0;
  bool isForeground = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 根据生命周期状态处理逻辑
    if (state == AppLifecycleState.resumed) {
      // isForeground = true;
      // LogUtils.logD("App 进入前台:isForeground:${isForeground}");
      // var allowBgm = CacheManager.getBool(
      //   CacheConfig.cacheBGMKey,
      //   defaultValue: true,
      // );
      // if (allowBgm) {
      //   AudioManager().playBGM("audio/bgm.mp3");
      // }
      // if(pauseTime == 0){
      //   pauseTime = DateTime.now().millisecondsSinceEpoch;
      // }
      // if((DateTime.now().millisecondsSinceEpoch - pauseTime)>2000 && mounted){
      //   LogUtils.logD("App resume start");
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     LogUtils.logD("App resume start2");
      //     Navigator.push(
      //       globalContext!,
      //       MaterialPageRoute(builder: (_) => StartPage(type: 1)),
      //     );
      //   });
      // }
      // pauseTime = 0;
    } else if (state == AppLifecycleState.paused) {
      // isForeground = false;
      // LogUtils.logD("App 进入后台");
      // AudioManager().pauseBGM();
      // LogUtils.logD("App 进入后台 设置 pauseTime isPlay:${isPlay}");
      // Future.delayed(Duration(seconds: 1), () {
      //   if(!isPlay && !isForeground){
      //     pauseTime = DateTime.now().millisecondsSinceEpoch;
      //   }
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: GlobalListener(
            child: MaterialApp(
              navigatorObservers: [LocalConfig.routeObserver],
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              navigatorKey: LocalConfig.navigatorKey,
              // home: StartPage(type: 0),
              home: GamePage(),
            ),
          ),
        );
      },
    );
  }

  void initSdk() {}
}

