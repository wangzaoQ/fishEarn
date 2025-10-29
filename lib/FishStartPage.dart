import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/game/GamePage.dart';
import 'package:fish_earn/utils/FishNFManager.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/GlobalTimerManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/utils/LogUtils.dart';
import 'package:fish_earn/utils/ad/ADEnum.dart';
import 'package:fish_earn/utils/ad/ADLoadManager.dart';
import 'package:fish_earn/utils/ad/ADShowManager.dart';
import 'package:fish_earn/utils/net/EventManager.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:fish_earn/view/HomeText.dart';
import 'package:fish_earn/web/WebViewPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/EventConfig.dart';
import 'config/global.dart';

class FishStartPage extends StatefulWidget {
  final int type ;
  const FishStartPage({super.key,required this.type});

  @override
  _FishStartPageState createState() => _FishStartPageState();
}

class _FishStartPageState extends State<FishStartPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  // var isFirst = true;

  var allowTips = false;

  var animalFirst = true;

  var cacheFirstKey = false;

  var isFirst = false;

  @override
  void initState() {
    super.initState();
    GameManager.instance.pauseMovement();
    GlobalTimerManager().cancelTimer();
    isLaunch = true;
    ADLoadManager.instance.preloadAll("startPage");
    allowShowStart = false;
    // ADLoadManager().preloadAll("startPage");
    cacheFirstKey = LocalCacheUtils.getBool(
      LocalCacheConfig.firstLogin,
      defaultValue: true,
    );
    isFirst = cacheFirstKey;
    LogUtils.logD("App startPage :${cacheFirstKey} isFirst");
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: cacheFirstKey? 2 : 12),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (cacheFirstKey) {
          isLaunch = false;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GamePage(),
              settings: RouteSettings(name: '/GamePage'),
            ),
          );
        } else {
          ADShowManager(adEnum: ADEnum.intAD, tag: "open", result: (type, hasValue) {
              if(!mounted)return;
              if(widget.type == 1){
                isLaunch = false;
                Navigator.pop(context, null);
              }else{
                isLaunch = false;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GamePage(),
                    settings: RouteSettings(name: '/GamePage'),
                  ),
                );
              }
            },
          ).showScreenAD(EventConfig.fixrn_launch);
        }
      }
    });
    _controller.addListener(() {
      if (!cacheFirstKey) {
        var ad = ADLoadManager.instance.getCacheAD(ADEnum.intAD);
        if (ad != null && animalFirst) {
          animalFirst = false;
          _controller.animateTo(
            1.0,
            duration: Duration(milliseconds: 1000), // 缩短时间完成动画
            curve: Curves.easeOut,
          );
        }
      }
    });
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!cacheFirstKey) {
        // 启动动画
        _controller.forward();
      }
    });
    // 异步预加载，不阻塞当前页面布局
    // Future.microtask(() {
    //   precacheImage(const AssetImage("assets/images/bg_home.webp"), context);
    // });
    Future.microtask(() async {
      await FishNFManager.instance.init();
      FishNFManager.instance.requestNF();
    });
    EventManager.instance.session();
    EventManager.instance.postEvent(EventConfig.launch_page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_start.webp',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(width: double.infinity, height: 105),
                    Image.asset(
                      'assets/images/ic_logo.webp',
                      width: 300.w,
                      height: 266.h,
                    ),
                  ],
                ),
                isFirst
                    ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 60.h),
                    child: Stack(
                      clipBehavior: Clip.none, // 如果有子内容溢出不会被裁掉
                      children: [
                        Positioned(
                          left: 101.w,
                          right: 101.w,
                          bottom: 50.h,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero, // 去掉默认内边距
                            pressedOpacity: 0.7,
                            onPressed: () {
                              EventManager.instance.postEvent(EventConfig.launch_start);
                              var cachePrivacyKey = LocalCacheUtils.getBool(
                                LocalCacheConfig.cachePrivacyKey,
                                defaultValue: true,
                              );
                              if (!cachePrivacyKey) {
                                GameManager.instance.showTips("app_login_tips".tr());
                                return;
                              }
                              setState(() {
                                isFirst = false;
                                _controller.forward();
                              });
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/bg_confirm.webp',
                                  width: double.infinity,
                                  height: 62.h,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 3.h),
                                  child: GameText(
                                    showText: "app_play_game".tr(),
                                    fontSize: 20.sp,
                                    strokeColor: const Color(0xFF197319),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: HomeText(
                            onPrivacy: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WebViewPage(
                                    url: pUrl,
                                    title: "app_privacy_policy".tr(),
                                  ),
                                ),
                              );
                            },
                            onTerms: () {
                              Navigator.push(
                                context,
                                  MaterialPageRoute(
                                    builder: (_) => WebViewPage(
                                      url: hUrl,
                                      title: "app_contact_us".tr(),
                                    ),
                                  )
                              );

                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : Positioned(
                  left: 40.w,
                  right: 40.w,
                  bottom: 135.h,
                  child: Column(
                    children: [
                      const SizedBox(width: double.infinity, height: 10),

                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // 背景图（完整进度条底图）
                              Image.asset(
                                "assets/images/bg_launch_bg.webp",
                                width: double.infinity,
                                height: 22.h,
                                fit: BoxFit.fill,
                              ),
                              // 进度图（会被裁剪宽度）
                              Padding(
                                padding: EdgeInsets.all(2.h),
                                child: AnimatedAlign(
                                  duration: Duration(milliseconds: 300),
                                  alignment: Alignment.centerLeft,
                                  child: ClipRect(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: _animation.value,
                                      child: Image.asset(
                                        "assets/images/bg_launch_progress.webp",
                                        width: double.infinity,
                                        height: 22.h,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
