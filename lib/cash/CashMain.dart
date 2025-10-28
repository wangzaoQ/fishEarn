import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/cash/CashItemView.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/data/UserData.dart';
import 'package:fish_earn/task/TaskManager.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../config/EventConfig.dart';
import '../config/global.dart';
import '../data/GameData.dart';
import '../event/NotifyEvent.dart';
import '../utils/ClickManager.dart';
import '../utils/LocalCacheUtils.dart';
import '../utils/net/EventManager.dart';
import '../view/pop/CashProcessPop.dart';
import '../view/pop/CashSuccessPop.dart';
import '../view/pop/PopManger.dart';
import 'CashPage.dart';

class CashMain extends StatefulWidget {
  const CashMain({super.key});

  @override
  State<CashMain> createState() => _CashMainState();
}

class _CashMainState extends State<CashMain> {
  late GameData gameData;
  late UserData userData;

  var taskName = "";


  @override
  void initState() {
    super.initState();
    gameData = LocalCacheUtils.getGameData();
    userData = LocalCacheUtils.getUserData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userData.new6) {
        Future.delayed(Duration(milliseconds: 500), () {
          showMarkNew6();
        });
      } else if (userData.new7) {
        Future.delayed(Duration(milliseconds: 500), () {
          showMarkNew7();
        });
      }
    });
    taskName = TaskManager.instance.getCurrentTaskName();
    EventManager.instance.postEvent(EventConfig.cash_page);
    _subscription = eventBus.on<NotifyEvent>().listen((event) {
      if (event.message == EventConfig.refreshCoin) {
        setState(() {
          gameData = LocalCacheUtils.getGameData();
          userData = LocalCacheUtils.getUserData();
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // 0 paypal 1 cash
  var payType = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false, // 禁止默认返回
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            if (tutorialCoachMark?.isShowing ?? false) {
              // 自定义逻辑
              tutorialCoachMark?.skip(); // 关闭当前教程
            }else{
              Navigator.pop(context);
            }
          }
        },
        child:Scaffold(
      body: Stack(
        children: [
          //金币
          Image.asset(
            "assets/images/bg_cash.webp",
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 54.h,
            left: 24.w,
            child: Container(
              padding: EdgeInsets.fromLTRB(28.w, 2.h, 14, 2.h),
              height: 25.h,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg_to_bar_coin.webp"),
                  fit: BoxFit.fill,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                GameManager.instance.getCoinShow(gameData.coin),
                style: TextStyle(
                  color: const Color(0xFFF4FF72),
                  fontSize: 15.sp,
                  fontFamily: "AHV",
                ),
              ),
            ),
          ),
          Positioned(
            left: 8.w,
            top: 43.h,
            child: Image.asset(
              "assets/images/ic_coin4.webp",
              width: 45.w,
              height: 45.h,
              fit: BoxFit.cover,
            ),
          ),
          //珍珠
          Positioned(
            top: 54.h,
            left: 166.w,
            child: SizedBox(
              width: 65.w,
              height: 25.h,
              child: Stack(
                children: [
                  Image.asset(
                    "assets/images/bg_to_bar_coin.webp",
                    height: 25.h,
                    fit: BoxFit.fill,
                  ),
                  Center(
                    child: Text(
                      "${gameData.pearlCount}",
                      style: TextStyle(
                        color: const Color(0xFFF4FF72),
                        fontSize: 15.sp,
                        fontFamily: "AHV",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 150.w,
            top: 50.h,
            child: Image.asset(
              "assets/images/ic_pearl2.webp",
              width: 32.w,
              height: 32.h,
              fit: BoxFit.cover,
            ),
          ),
          //Home
          Positioned(
            top: 44.h,
            right: 14.w,
            child: SizedBox(
              width: 48.w,
              height: 48.h,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                pressedOpacity: 0.7,
                child: Image.asset(
                  "assets/images/ic_to_home.webp",
                  width: 48.w,
                  height: 48.h,
                  fit: BoxFit.cover,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Positioned(
            left: 15.w,
            right: 15.w,
            top: 113.h,
            child: SizedBox(
              width: double.infinity,
              height: 125.h,
              child: Stack(
                children: [
                  Image.asset(
                    "assets/images/bg_cash_top.webp",
                    width: 345.w,
                    height: 125.h,
                    fit: BoxFit.fill,
                  ),
                  Positioned(
                    left: 14.w,
                    top: 14.h,
                    child: GameText(
                      showText: "${"app_balance".tr()}:",
                      strokeColor: Colors.black,
                      strokeWidth: 0.7.h,
                      fontSize: 18.sp,
                    ),
                  ),
                  Center(
                    child: GameText(
                      showText:
                      "\$ ${GameManager.instance.getCoinShow(gameData.coin)}",
                      strokeWidth: 1.5.h,
                      strokeColor: Colors.black,
                      fontSize: 29.sp,
                      fillColor: Color(0xFF33FFDB),
                    ),
                  ),
                  taskName != "task6"?SizedBox.shrink():Positioned(
                    right: 3.h,
                    bottom: 8.h,
                    child: SizedBox(
                      width: 80.w,
                      height: 80.h,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        pressedOpacity: 0.7,
                        child: Image.asset("assets/images/ic_toRank.webp",width: 80.w,
                          height: 80.h,fit: BoxFit.fill,),
                        onPressed: () async {
                          if (!ClickManager.canClick(context: context)) return;
                          EventManager.instance.postEvent(EventConfig.cash_queue);
                          var type = LocalCacheUtils.getInt(LocalCacheConfig.cashMoneyType,defaultValue: 1);
                          //1 500 2 800 3 1000
                          var money = 500;
                          if(type == 1){
                            money = 500;
                          }else if(type == 2){
                            money = 800;
                          }else if(type == 3){
                            money = 1000;
                          }
                          var result = await PopManager().show(context: context,
                              child: CashProcessPop(money: money,));
                          if(result == 0){
                            PopManager().show(context: context,
                                child: CashSuccessPop());
                            LocalCacheUtils.putString(LocalCacheConfig.taskCurrentKey,"");
                            taskName = TaskManager.instance.getCurrentTaskName();
                            setState(() {

                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 208.w,
            bottom: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                Image.asset(
                  "assets/images/bg_cash_bottom.webp",
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fill,
                ),
                Positioned(
                  left: 14.w,
                  top: 8.h,
                  child: Text(
                    "app_withdrawal".tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontFamily: "AHV",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  left: 15.w,
                  right: 15.w,
                  top: 37.h,
                  child: SizedBox(
                    key: globalKeyNew6,
                    width: double.infinity,
                    height: 56.h,
                    child: Stack(
                      children: [
                        Image.asset(
                          payType == 0
                              ? "assets/images/bg_cash_channel1.webp"
                              : "assets/images/bg_cash_channel2.webp",
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Positioned(
                          left: 20.w,
                          top: 0,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            pressedOpacity: 0.7,
                            child: Image.asset(
                              "assets/images/ic_paypal.webp",
                              width: 78.w,
                              height: 22.h,
                            ),
                            onPressed: () {
                              setState(() {
                                payType = 0;
                              });
                            },
                          ),
                        ),
                        Positioned(
                          right: 20.w,
                          top: 2.h,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            pressedOpacity: 0.7,
                            child: Image.asset(
                              "assets/images/ic_cash.webp",
                              width: 96.w,
                              height: 21.h,
                            ),
                            onPressed: () {
                              setState(() {
                                payType = 1;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //提现列表
                Positioned(
                  top: 106.h,
                  left: 12.w,
                  right: 12.w,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
                          children: [
                            CashItemView(
                              key: globalKeyNew7,
                              gameData: gameData,
                              payType: payType,
                              money: 500,
                              payStatus: 0,
                            ),
                            SizedBox(height: 4.h),
                            CashItemView(
                              gameData: gameData,
                              payType: payType,
                              money: 800,
                              payStatus: 1,
                            ),
                            SizedBox(height: 4.h),
                            CashItemView(
                              gameData: gameData,
                              payType: payType,
                              money: 1000,
                              payStatus: 2,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  TutorialCoachMark? tutorialCoachMark;
  late List<TargetFocus> globalKeyNew6Keys;
  GlobalKey globalKeyNew6 = GlobalKey();
  GlobalKey globalKeyNew7 = GlobalKey();

  StreamSubscription<NotifyEvent>? _subscription;

  void showMarkNew6() {
    EventManager.instance.postEvent(EventConfig.new_guide,params: {"pop_step": "pop7"});
    globalKeyNew6Keys = [];
    globalKeyNew6Keys.add(
      TargetFocus(
        identify: "guide6",
        keyTarget: globalKeyNew6,
        shape: ShapeLightFocus.RRect,
        radius: 12.0,
        // 圆角半径，自行调整
        contents: [
          TargetContent(
            align: ContentAlign.bottom, // 内容在高亮 widget 下方
            child: Stack(
              clipBehavior: Clip.none, // 防止溢出裁剪
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(0, 60.h, 0, 0),
                    child: Image.asset(
                      "assets/images/ic_fish_tips.webp",
                      width: 75.w,
                      height: 75.h,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(68.w, 50.h, 0, 0),
                    child: Container(
                      width: 268.w,
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      height: 72.h, // 让高度自适应文字
                      child: Stack(
                        children: [
                          Image.asset(
                            "assets/images/bg_level_up.webp",
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.fill,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(30.w, 0, 20.w, 0),
                            child: Center(
                              child: Text(
                                "app_mask6_tips".tr(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF651922),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    tutorialCoachMark = TutorialCoachMark(
      targets: globalKeyNew6Keys,
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: "",
      paddingFocus: 0,
      onFinish: () {
      },
      onClickTarget: (target) async {
        if (!ClickManager.canClick(context: context)) return;
        EventManager.instance.postEvent(EventConfig.new_guide_c,params: {"pop_step": "pop7"});
        showMarkNew7();
      },
    );
    tutorialCoachMark?.show(context: context);
  }

  void showMarkNew7() {
    EventManager.instance.postEvent(EventConfig.new_guide,params: {"pop_step": "pop8"});
    userData.new6 = false;
    LocalCacheUtils.putUserData(userData);
    globalKeyNew6Keys = [];
    globalKeyNew6Keys.add(
      TargetFocus(
        identify: "guide7",
        keyTarget: globalKeyNew7,
        shape: ShapeLightFocus.RRect,
        radius: 12.0,
        // 圆角半径，自行调整
        contents: [
          TargetContent(
            align: ContentAlign.top, // 内容在高亮 widget 下方
            child: Stack(
              clipBehavior: Clip.none, // 防止溢出裁剪
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 50.h),
                    child: Image.asset(
                      "assets/images/ic_fish_tips.webp",
                      width: 75.w,
                      height: 75.h,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(68.w, 0, 0, 60.h),
                    child: Container(
                      width: 268.w,
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      height: 72.h, // 让高度自适应文字
                      child: Stack(
                        children: [
                          Image.asset(
                            "assets/images/bg_level_up.webp",
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.fill,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(30.w, 0, 20.w, 0),
                            child: Center(
                              child: Text(
                                "app_mask7_tips".tr(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF651922),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    tutorialCoachMark = TutorialCoachMark(
      targets: globalKeyNew6Keys,
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: "",
      paddingFocus: 0,
      onFinish: () {
      },
      onClickTarget: (target) {
        if (!ClickManager.canClick(context: context)) return;
        var userData = LocalCacheUtils.getUserData();
        userData.new7 = false;
        LocalCacheUtils.putUserData(userData);
        Navigator.pop(context);
        EventManager.instance.postEvent(EventConfig.new_guide_c,params: {"pop_step": "pop8"});
      },
    );
    tutorialCoachMark?.show(context: context);
  }
}
