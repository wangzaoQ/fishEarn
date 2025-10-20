import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/config/LocalConfig.dart';
import 'package:fish_earn/game/GamePage.dart';
import 'package:fish_earn/task/CashManager.dart';
import 'package:fish_earn/task/RewardManager.dart';
import 'package:fish_earn/task/TaskManager.dart';
import 'package:fish_earn/utils/AudioUtils.dart';
import 'package:fish_earn/utils/FishNFManager.dart';
import 'package:fish_earn/utils/GlobalDataManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/utils/LogUtils.dart';
import 'package:fish_earn/utils/NetWorkManager.dart';
import 'package:fish_earn/utils/TimeUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'FishStartPage.dart';
import 'config/GlobalListener.dart';
import 'config/global.dart';
import 'model/GameViewModel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalCacheUtils.init();
  await EasyLocalization.ensureInitialized();
  // if (Platform.isAndroid) {
  //   try {
  //     await Firebase.initializeApp();
  //     FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  //
  //     // 捕获 async / isolate 全局错误
  //     PlatformDispatcher.instance.onError = (error, stack) {
  //       FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //       return true;
  //     };
  //   } catch (e) {
  //     LogUtils.logD("Firebase init error");
  //   }
  // }
  GlobalDataManager.instance.init();
  TimeUtils.dataReset();

  TaskManager.instance.init(null);
  CashManager.instance.init(null);
  RewardManager.instance.init(null);
  // 延迟3秒执行
  Future.delayed(const Duration(seconds: 3), () async {
    await FishNFManager.instance.init();
    var allowNF = await FishNFManager.instance.allowNF();
    if(allowNF){
      FishNFManager.instance.startNF();
    }
  });
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en')],
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

  var TAG = "APP_TAG";

  Timer? timeoutTimer;
  bool isNeedAd = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 根据生命周期状态处理逻辑
    if (state == AppLifecycleState.resumed) {
      timeoutTimer?.cancel();
      isForeground = true;
      LogUtils.logD("$TAG App isForeground:${isForeground}");
      var allowBgm = LocalCacheUtils.getBool(
        LocalCacheConfig.allowBGMKey,
        defaultValue: true,
      );
      if (allowBgm) {
        AudioUtils().playBGM("audio/bg1.mp3");
      }
      if(isNeedAd&&mounted && globalContext!=null){
        isNeedAd = false;
        if(currentRouteName  != "StartPage" && !adIsPlay){
          allowShowStart = true;
        }else{
          allowShowStart = false;
        }
        LogUtils.logD("$TAG App resume start allowStart:${allowShowStart} currentRouteName:${currentRouteName} isPlay:${adIsPlay}");
        if(globalContext != null && allowShowStart){
          WidgetsBinding.instance.addPostFrameCallback((_) {
            LogUtils.logD("$TAG App resume start2");
            adIsPlay = false;
            Navigator.push(
              globalContext!,
              MaterialPageRoute(builder: (_) => FishStartPage(type: 1),settings: const RouteSettings(name: "StartPage"),),
            );
          });
        }
      }
    } else if (state == AppLifecycleState.paused) {
      isForeground = false;
      LogUtils.logD("$TAG App isForeground:${isForeground}");
      AudioUtils().pauseBGM();
      timeoutTimer?.cancel();
      timeoutTimer = Timer(Duration(seconds: 3), () {
        isNeedAd = true;
        LogUtils.logD("$TAG App AppLifecycleState.paused isNeedAd:${isNeedAd} ");
      });
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
              builder: EasyLoading.init(), // 👈 在这里
              initialRoute: 'StartPage',
              routes: {
                'StartPage': (context) => const FishStartPage(type: 0),
              },
            ),
          ),
        );
      },
    );
  }

  void initSdk() {
    Future.microtask(() async {
      try {
        var allowBgm = LocalCacheUtils.getBool(
          LocalCacheConfig.allowBGMKey,
          defaultValue: true,
        );
        if (allowBgm) {
          AudioUtils().playBGM("audio/bg1.mp3");
        }
      } catch (e) {
        LogUtils.logD("$TAG playBGM error");
      }
      try {
        NetWorkManager().initNetworkListener();
      } catch (e) {
        LogUtils.logD("$TAG NetWorkManager init error");
      }
    });
  }
}


String? currentRouteName;

class SimpleRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    currentRouteName = route.settings.name ?? route.runtimeType.toString();
    debugPrint("didPush -> currentRouteName: $currentRouteName");
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    currentRouteName = previousRoute?.settings.name ?? previousRoute?.runtimeType.toString();
    debugPrint("didPop -> currentRouteName: $currentRouteName");
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    currentRouteName = newRoute?.settings.name ?? newRoute?.runtimeType.toString();
    debugPrint("didReplace -> currentRouteName: $currentRouteName");
  }
}

