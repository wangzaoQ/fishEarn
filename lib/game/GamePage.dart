import 'dart:async';
import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/cash/CashMain.dart';
import 'package:fish_earn/config/EventConfig.dart';
import 'package:fish_earn/config/GameConfig.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/config/LocalConfig.dart';
import 'package:fish_earn/task/TaskManager.dart';
import 'package:fish_earn/utils/AudioUtils.dart';
import 'package:fish_earn/utils/FishNFManager.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/GlobalDataManager.dart';
import 'package:fish_earn/utils/GlobalTimerManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/utils/NetWorkManager.dart';
import 'package:fish_earn/view/DropFadeImage.dart';
import 'package:fish_earn/view/GameProcess.dart';
import 'package:fish_earn/view/SharkWidget.dart';
import 'package:fish_earn/view/BubbleWidget.dart';
import 'package:fish_earn/view/pop/CashProcessPop.dart';
import 'package:fish_earn/view/pop/CoinAnimalPop.dart';
import 'package:fish_earn/view/pop/FirstGuidePop.dart';
import 'package:fish_earn/view/pop/GameAward.dart';
import 'package:fish_earn/view/pop/GameFailPop.dart';
import 'package:fish_earn/view/pop/GamePearlPop.dart';
import 'package:fish_earn/view/pop/LevelPop1_2.dart';
import 'package:fish_earn/view/pop/NFGuidePop.dart';
import 'package:fish_earn/view/pop/NoPearlPop.dart';
import 'package:fish_earn/view/pop/OfflinePop.dart';
import 'package:fish_earn/view/pop/PopManger.dart';
import 'package:fish_earn/web/WebViewPage.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../config/global.dart';
import '../data/GameData.dart';
import '../data/UserData.dart';
import '../event/NotifyEvent.dart';
import '../model/GameViewModel.dart';
import '../task/RewardManager.dart';
import '../utils/ArrowOverlay.dart';
import '../utils/ClickManager.dart';
import '../utils/LogUtils.dart';
import '../utils/ad/ADEnum.dart';
import '../utils/ad/ADLoadManager.dart';
import '../utils/ad/ADShowManager.dart';
import '../utils/net/EventManager.dart';
import '../view/GameLifeProgress.dart';
import '../view/GameText.dart';
import '../view/PropsProgress.dart';
import '../view/pop/BasePopView.dart';
import '../view/pop/CashTipsPop.dart';
import '../view/pop/LevelPop2_3.dart';
import '../view/pop/PropsAwardPop.dart';
import '../view/pop/ProtectPop.dart';
import '../view/pop/SettingPop.dart';
import '../view/pop/WithdrawPop.dart';
import 'AnimalGameHolder.dart';
import 'ArrowWidget.dart';
import 'GameLifePage.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late GameData gameData;
  late double progress;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  var TAG = "GamePage";

  //生命相关
  var cutTime = 0;

  //道具相关
  var propsTime = 0;
  var aliveTime = 0;
  var realShowSharkTime = 0;
  Timer? _timer = null;

  //第一次展示危险提示
  var firstShowProtectKey = true;

  //展示金币泡泡
  var showCoinBubbles = true;
  var showCoinBubbles2 = true;
  var showCoinBubbles3 = true;
  var showFoodBubbles = true;
  var showPearlBubbles1 = true;
  var showPearlBubbles2 = false;
  var timeCoinBubbles = 0;
  var timeCoinBubbles2 = 0;
  var timeCoinBubbles3 = 0;
  var timeFoodBubbles = 0;
  var timePearBubbles = 0;

  //金币泡泡给的具体金额
  var addCoin = 0.0;
  var addCoin2 = 0.0;
  var addCoin3 = 0.0;
  var oldCoin = 0;

  late UserData userData;

  int getCutTime() {
    return GameConfig.lifeDecreaseInterval;
  }

  int getProtectTime() {
    return GameConfig.protectDuration;
  }

  var allowShowNewUserGuide = false;

  @override
  void initState() {
    super.initState();
    ADLoadManager.instance.preloadAll("gamePage");
    gameData = LocalCacheUtils.getGameData();
    userData = LocalCacheUtils.getUserData();
    WidgetsBinding.instance.addObserver(this); // ✅ 注册

    AudioUtils().initTempQueue();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // firstShowProtectKey = LocalCacheUtils.getBool(
    //   LocalCacheConfig.firstShowProtectKey,
    //   defaultValue: true,
    // );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      LocalCacheUtils.putBool(LocalCacheConfig.firstLogin, false);
      registerTimer();
      try{
        await FishNFManager.instance.init();
        var allowNF = await FishNFManager.instance.allowNF();
        if(allowNF){
          FishNFManager.instance.startNF();
        }else{
          pauseTemp("show NFGuidePop");
          EventManager.instance.postEvent(EventConfig.noti_confirm_pop);

          var result = await PopManager().show(
              context: context,
              child: NFGuidePop()
          );
          if(result == 1){
            var gameData = LocalCacheUtils.getGameData();
            gameData.coin+=5;
            LocalCacheUtils.putGameData(gameData);
            await PopManager().show(
              context: context,
              needAlpha: 0,
              child: CoinAnimalPop(),
            );
          }
          resumeTemp("show NFGuidePop");
        }
      }catch(e){
        LogUtils.logD("$TAG ${e}");
      }

      var allowShowOffline = LocalCacheUtils.getBool(LocalCacheConfig.allowShowOffline,defaultValue: false);
      if(allowShowOffline){
        LocalCacheUtils.putBool(LocalCacheConfig.allowShowOffline, false);
        await PopManager().show(
          context: context,
          child: OfflinePop(),
        );
        await PopManager().show(
          context: context,
          needAlpha: 0,
          child: CoinAnimalPop(),
        );
      }
      allowShowNewUserGuide = true;
      newUserGuide();
      // TaskManager.instance.addTask("login");
    });
    eventBus.on<NotifyEvent>().listen((event) async {
      if (event.message == EventConfig.new4) {
        // setState(() {
        //   globalShowDanger2 = true;
        // });
        resumeTemp("EventConfig.new4");
        showMarkNew4();
      }else if(event.message == EventConfig.toCash){
        toCashMain(context,"EventConfig.toCash");
      }else if(event.message == EventConfig.cashTips1){
        pauseTemp("EventConfig.cashTips1");
        var result = await PopManager().show(context: context, child: WithdrawPop());
        resumeTemp("EventConfig.cashTips1");
      }else if(event.message == EventConfig.cashTips2){
        pauseTemp("EventConfig.cashTips2");
        var result = await PopManager().show(context: context, child: CashTipsPop());
        GlobalTimerManager().startTimer2();
        if(result == 1){
          await toPearlPop(context,"toPearlPop result == 1");
        }else if(result == 2){
          await toCashMain(context,"toPearlPop result == 2");
        }
        resumeTemp("EventConfig.cashTips2");
      }
    });
    EventManager.instance.postEvent(EventConfig.home_page);
  }

  var allowResume = false;

  Future<void> newUserGuide() async {
    if(!allowShowNewUserGuide)return;
    userData = LocalCacheUtils.getUserData();
    var firstShowGuide1 = LocalCacheUtils.getBool(LocalCacheConfig.firstShowGuide1,defaultValue: true);
    if(firstShowGuide1){
      pauseTemp("newUserGuide");
      var result = await BasePopView().showScaleDialog(
        context: LocalConfig.globalContext!,
        child: FirstGuidePop(),
        needAlpha: 0.7
      );
      LocalCacheUtils.putBool(LocalCacheConfig.firstShowGuide1, false);
    }
    if (userData.new1 ||
        userData.new2 ||
        userData.new3 ||
        userData.new4 ||
        userData.new5) {
      if (userData.new1) {
        GameManager.instance.swimToCenter();
        showMarkNew1();
      } else if (userData.new2) {
        showMarkNew2();
      } else if (userData.new3) {
        eventBus.fire(NotifyEvent(EventConfig.new3));
      } else if (userData.new4) {
        eventBus.fire(NotifyEvent(EventConfig.new4));
      } else if (userData.new5) {
        showMarkNew5();
      } else if (userData.new6 || userData.new7) {
        toCashMain(context,"userData.new6 || userData.new7");
      }
    }else{

    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ✅ 记得移除
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    gameData = LocalCacheUtils.getGameData();
    if (oldCoin == 0) {
      oldCoin = GameManager.instance.getCoinShow2(
        LocalCacheUtils.getGameData().coin,
      );
    }
    return PopScope(
      canPop: false, // 禁止默认返回
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (tutorialCoachMark?.isShowing ?? false) {
            // 自定义逻辑
            // tutorialCoachMark?.skip(); // 关闭当前教程
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/bg_game.webp",
                fit: BoxFit.cover,
              ),
            ),
            // top bar
            //鱼生命进度
            gameData.level == 1
                ? SizedBox.shrink()
                : Positioned(top: 310.h, left: 32.w, child: GameLifePage()),
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
            //鱼动画
            buildAnimal(),
            buildFood(),

            buildShark(),
            //setting
            Positioned(
              top: 46.h,
              right: 14.w,
              child: SizedBox(
                width: 48.w,
                height: 48.h,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  pressedOpacity: 0.7,
                  child: Image.asset(
                    "assets/images/ic_setting.webp",
                    width: 45.w,
                    height: 45.h,
                  ),
                  onPressed: () async {
                    if (!ClickManager.canClick(context: context)) return;
                    var result = await PopManager().show(
                      context: context,
                      child: SettingPop(),
                    );
                    if (result == 1) {
                      //联系我们
                    } else if (result == 0) {
                      //隐私
                    }
                  },
                ),
              ),
            ),
            //h5
            Positioned(
              top: 43.h,
              right: 65.w,
              child: SizedBox(
                width: 62.w,
                height: 54.h,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  pressedOpacity: 0.7,
                  child: Image.asset(
                    "assets/images/ic_h5.webp",
                    width: 62.w,
                    height: 54.h,
                    fit: BoxFit.fill,
                  ),
                  onPressed: () async {
                    if (!ClickManager.canClick(context: context)) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WebViewPage(
                          url: LocalConfig.h5Url,
                          title: "app_more_fun".tr(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            //progress
            Padding(
              padding: EdgeInsetsGeometry.only(
                top: gameData.level == 3 ? 94.h : 94.h,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: RepaintBoundary(
                  child: ValueListenableBuilder<double>(
                    valueListenable: globalTimeListener,
                    builder: (_, value, __) {
                      return GameProgress(
                        progress: value,
                        onConfirm: (result) {
                          if (result == 10) {
                            toCashMain(context,"GameProgress result == 10");
                          } else if(result == 99){
                            pauseTemp("GameProgress result == 99");
                          }else if(result == 100){
                            resumeTemp("GameProgress result == 100");
                          }else{
                            gameData = LocalCacheUtils.getGameData();
                            progress = GameManager.instance.getCurrentProgress(gameData);
                            globalTimeListener.value = progress;
                            setState(() {
                            });
                          }
                        },
                      ); // 只重建这一小块
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                width: double.infinity,
                height: 110.h,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        "assets/images/bg_game_bottom.webp",
                        width: double.infinity,
                        height: 76.h,
                        fit: BoxFit.fill,
                      ),
                    ),
                    // 其他内容
                    Align(
                      alignment: Alignment.center,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        pressedOpacity: 0.7,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            key: globalGuideNew1,
                            "assets/images/ic_play.webp",
                            height: 109.h,
                            width: 197.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                        onPressed: () {
                          if (!ClickManager.canClick(context: context)) return;
                          clickFood();
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsetsGeometry.only(bottom: 12.h),
                        child: Container(
                          width: 36.w,
                          height: 18.h,
                          decoration: BoxDecoration(
                            color: const Color(0x8C000000),
                            // #8C000000 (alpha first in Flutter)
                            borderRadius: BorderRadius.circular(11.0), // 11dp
                          ),
                          child: Center(
                            child: Text(
                              "${gameData.foodCount}",
                              style: TextStyle(
                                color: Color(0xFFF4FF72),
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16.w,
                      bottom: 5.h,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        pressedOpacity: 0.7,
                        child: Image.asset(
                          "assets/images/ic_pearl.webp",
                          width: 67.w,
                          height: 67.h,
                        ),
                        onPressed: () async {
                          if (!ClickManager.canClick(context: context)) return;
                          await toPearlPop(context,"click PearlPop");
                        },
                      ),
                    ),
                    Positioned(
                      right: 16.w,
                      bottom: 5.h,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        pressedOpacity: 0.7,
                        child: Image.asset(
                          "assets/images/ic_coin2.webp",
                          width: 67.w,
                          height: 67.h,
                          fit: BoxFit.cover,
                        ),
                        onPressed: () async {
                          if (!ClickManager.canClick(context: context)) return;
                          await toCashMain(context,"click Coin");
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //漂流瓶
            Positioned(
              top: 295.h,
              right: 22.w,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                pressedOpacity: 0.7,
                child: SizedBox(
                  key: globalGuideNew5,
                  width: 70.w,
                  height: 70.h,
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/images/ic_props.webp",
                        fit: BoxFit.fill,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(bottom: 2.h),
                          child: RepaintBoundary(
                            child: ValueListenableBuilder<double>(
                              valueListenable: propsNotifier,
                              builder: (_, value, __) {
                                return PropsProgress(
                                  progress: value, // 进度 0~1
                                  progressColor: GameConfig.color3,
                                ); // 只重建这一小块
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () async {
                  if (!ClickManager.canClick(context: context)) return;
                  var progress = GameManager.instance.getPropsProgress(
                    propsTime,
                  );
                  if (progress == 1 || userData.new5) {
                    pauseTemp("progress == 1 || userData.new5");
                    var result = await toPropsAwardPop();
                    if (result == 1) {
                      setState(() {
                        propsTime = 0;
                      });
                    }
                    resumeTemp("progress == 1 || userData.new5");
                  }
                },
              ),
            ),
            // Positioned(
            //   top: 400.h,
            //   right: 22.w,
            //   child: Column(children: [
            //     Image.asset("assets/images/ic_cash_tips_top.webp",width: 30.w,height: 30.h,),
            //     Text("40",style: TextStyle(fontSize: 15.sp,color: Color(0xFF651922)),),
            //   ],),
            // ),

            ValueListenableBuilder<double>(
              valueListenable: propsNotifier,
              builder: (_, value, __) {
                return Positioned(
                  top: 350.h,
                  right: 45.w,
                  child: ArrowWidget(progress: value),
                ); // 只重建这一小块
              },
            ),
            buildDanger(),
            //防护
            Positioned(
              top: 220.h,
              right: 22.w,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                pressedOpacity: 0.7,
                child: SizedBox(
                  key: globalGuideNew4,
                  width: 70.w,
                  height: 70.h,
                  child: Image.asset("assets/images/ic_protect.webp"),
                ),
                onPressed: () {
                  if (!ClickManager.canClick(context: context)) return;
                  EventManager.instance.postEvent(EventConfig.defense_c);
                  clickProtect("click ProtectButton");
                },
              ),
            ),
            Positioned(
              top: 460.h,
              right: 22.w,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                pressedOpacity: 0.7,
                child: SizedBox(
                  width: 70.w,
                  height: 70.h,
                  child: Image.asset("assets/images/ic_game.webp"),
                ),
                onPressed: () async {
                  if (!ClickManager.canClick(context: context)) return;
                  pauseTemp("web_game");
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WebViewPage(
                        url: "https://s.gamifyspace.com/tml?pid=19164&appk=ocrEzUOMoYdk2eLKgXxWIivQOWzRS02V&did=${LocalCacheUtils.getString(LocalCacheConfig.cacheGIDKey,defaultValue: "")}",
                        title: "app_game".tr(),
                      ),
                    ),
                  );
                  resumeTemp("web_game");
                },
              ),
            ),
            //现金气泡
            buildCoinBubbles(),
            buildCoinBubbles2(),
            buildCoinBubbles3(),
            showFoodBubbles
                ? Positioned(
                    left: 18.w,
                    top: 300.h,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      pressedOpacity: 0.7,
                      child: BubbleWidget(type: 1),
                      onPressed: () {
                        if (!ClickManager.canClick(context: context)) return;
                        setState(() {
                          showFoodBubbles = false;
                          gameData.foodCount += 10;
                          LocalCacheUtils.putGameData(gameData);
                          TaskManager.instance.addTask("bubbles");
                        });
                      },
                    ),
                  )
                : SizedBox.shrink(),
            showPearlBubbles1
                ? Positioned(
                    right: 26.w,
                    bottom: 300.h,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      pressedOpacity: 0.7,
                      child: BubbleWidget(type: 2),
                      onPressed: () {
                        if (!ClickManager.canClick(context: context)) return;
                        setState(() {
                          showPearlBubbles1 = false;
                          gameData.pearlCount += 1;
                          LocalCacheUtils.putGameData(gameData);
                          TaskManager.instance.addTask("bubbles");
                        });
                      },
                    ),
                  )
                : SizedBox.shrink(),
            showPearlBubbles2
                ? Positioned(
                    right: 26.w,
                    bottom: 160.h,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      pressedOpacity: 0.7,
                      child: BubbleWidget(type: 2),
                      onPressed: () {
                        if (!ClickManager.canClick(context: context)) return;
                        setState(() {
                          showPearlBubbles2 = false;
                          gameData.pearlCount += 1;
                          LocalCacheUtils.putGameData(gameData);
                          TaskManager.instance.addTask("bubbles");
                        });
                      },
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Future<void> toPearlPop(BuildContext context,String tag) async {
    pauseTemp(tag);
    var toPearlWhile = false;
    while(GlobalTimerManager().isTimer2Running()){
      toPearlWhile = true;
      var needContinue = await toPearl(context,needCutCount :true);
      if(!needContinue){
        break;
      }
    }
    if(!toPearlWhile){
      await toPearl(context);
    }
    resumeTemp(tag);
  }

  Future<bool> toPearl(BuildContext context,{bool needCutCount = false}) async {
    var needContinue = false;
    var result = await PopManager().show(
      context: context,
      child: GamePearlPop(targetIndex: 2,pearlPopType:GlobalTimerManager().isTimer2Running()?1:0),
    );
    //2 双倍 1单倍
    var awardResult = 1;
    if (result != null) {
      if (result == -2) {
        await PopManager().show(
          context: context,
          child: NoPearlPop(),
        );
      } else if (result == -1) {
        //食物
        awardResult = await PopManager().show(
          context: context,
          child: GameAwardPop(type: 1, money: 30),
        );
      } else {
        awardResult = await PopManager().show(
          context: context,
          child: GameAwardPop(type: 0, money: result),
        );
      }
      gameData = LocalCacheUtils.getGameData();
      if(result!=-2 && !needCutCount){
        gameData.pearlCount -= 1;
        LocalCacheUtils.putGameData(gameData);
      }
      if (result == -1) {
        setState(() {
          gameData.foodCount += 30;
        });
      } else if(result!=-2){
        await PopManager().show(
          context: context,
          needAlpha: 0,
          child: CoinAnimalPop(),
        );
        gameData.coin += result * awardResult;
      }
      LocalCacheUtils.putGameData(gameData);
      setState(() {

      });
      needContinue = true;
    }else{
      needContinue = false;
    }
    return needContinue;
  }

  var allowClickProtect = true;

  Future<void> clickProtect(String tag) async {
    userData = LocalCacheUtils.getUserData();
    if (userData.new4) {
      userData.new4 = false;
      LocalCacheUtils.putUserData(userData);
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (!mounted) return;
        toProtect();
      });
    } else {
      pauseTemp(tag);
      var protectType = GlobalDataManager.instance.globalData?.protectType;
      if (protectType == 0) {
        if (!allowClickProtect) return;
        allowClickProtect = false;
        ADShowManager(
          adEnum: ADEnum.rewardedAD,
          tag: "reward",
          result: (type, hasValue) {
            allowClickProtect = true;
            if (hasValue) {
              toProtect();
            }
          },
        ).showScreenAD(EventConfig.fixrn_shield_rv, awaitLoading: true);
      }else{
       var result =  await BasePopView().showScaleDialog(
          context: context,
          child: ProtectPop(),
        );
       if(result == 0 || result == 1){
         toProtect();
       }else{
         resumeTemp(tag);
       }
      }
    }
  }

  void toProtect() {
    gameData = LocalCacheUtils.getGameData();
    gameData.protectTime += getProtectTime();
    LocalCacheUtils.putGameData(gameData);
    setState(() {
      globalShowDanger2 = false;
      alreadyShowProtectPop = false;
      // ArrowOverlay.hide();
      if (globalShowDanger1) {
        GameManager.instance.hideDanger();
      }
    });
    GameManager.instance.showProtect();
    GameManager.instance.updateProtectTime(gameData.protectTime);
    resumeTemp("toProtect");
    if (userData.new5) {
      showMarkNew5();
    }
  }

  Future<void> toCashMain(BuildContext context,String tag) async {
    pauseTemp(tag);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CashMain(),
        settings: const RouteSettings(name: '/CashMain'),
      ),
    );
    resumeTemp(tag);
  }

  void resumeTemp(String tag) {
    LogUtils.logD("$TAG resumeTemp tag:${tag}");
    registerTimer();
    GameManager.instance.resumeMovement();
  }

  void pauseTemp(String tag) {
    LogUtils.logD("$TAG pauseTemp tag:${tag}");
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      GameManager.instance.pauseMovement();
      GlobalTimerManager().cancelTimer();
    });
  }

  Widget buildAnimal() {
    LogUtils.logD("${TAG} buildAnimal");
    return Positioned.fill(
      child: Center(child: AnimalGameHolder(level: gameData.level)),
    );
  }

  var guideProps = false;

  var alreadyShowProtectPop = false;

  Future<void> registerTimer() async {
    bool result = await isGameOver();
    if (result) {
      return;
    }
    GlobalTimerManager().startTimer(
      onTick: () async {
        LogUtils.logD("${TAG} startTimer allowTime:${allowTime} adIsPlay:${adIsPlay} isLaunch${isLaunch} globalShowShark:${globalShowShark}");
        if (!allowTime) return;
        if(adIsPlay || isLaunch){
          return;
        }
        LogUtils.logD("${TAG} startTimer2");
        gameData = LocalCacheUtils.getGameData();
        userData = LocalCacheUtils.getUserData();
        if (gameData.level > 0 && gameData.levelTime >= 1) {
          gameData.levelTime -= 1;
        }
        propsTime++;
        if(!globalShowDanger2){
          aliveTime++;
        }
        if (!showCoinBubbles) timeCoinBubbles++;
        if (!showCoinBubbles2) timeCoinBubbles2++;
        if (!showCoinBubbles3) timeCoinBubbles3++;
        if (!showFoodBubbles) timeFoodBubbles++;
        if (!showPearlBubbles1) timePearBubbles++;
        if (gameData.level > 1) {
          cutTime++;
          GameManager.instance.addCoin(gameData);
        }
        if (cutTime == getCutTime()) {
          cutTime = 0;
          GameManager.instance.cutLife(gameData);
          if (gameData.life <= 0) {
            GlobalTimerManager().cancelTimer();
            //游戏结束
            bool result = await isGameOver();
            if (result) return;
          }
        }
        if (gameData.protectTime > 0) {
          gameData.protectTime -= 1;
        } else {
          gameData.protectTime = 0;
        }

        LocalCacheUtils.putGameData(gameData);
        var dangerTime = GlobalDataManager.instance.globalData?.sharkAttack??60;
        if (aliveTime == dangerTime) {
          LogUtils.logD("${TAG} GlobalTimer 到达鲨鱼攻击时间:${dangerTime}");
          aliveTime = 0;
          realShowSharkTime = 0;
          EventManager.instance.postEvent(EventConfig.shark_attack);
          showDanger();
        }
        if(globalShowDanger2) {
          realShowSharkTime++;
          AudioUtils().playTempAudio("audio/danger.mp3");
          if (realShowSharkTime >= 5 && !alreadyShowProtectPop) {
            LogUtils.logD("${TAG} GlobalTimer 触发鲨鱼攻击 realShowSharkTime:${realShowSharkTime} alreadyShowProtectPop:${alreadyShowProtectPop}");
            pauseTemp("globalShowDanger2");
            alreadyShowProtectPop = true;
            var result =  await BasePopView().showScaleDialog(
              context: context,
              child: ProtectPop(),
            );
            LogUtils.logD("${TAG} ProtectPop result:${result}");
            if(result == 0 || result == 1){
              if (!userData.new5) {
                globalShowShark = true;
                EventManager.instance.postEvent(EventConfig.shark_attack_c);
                TaskManager.instance.addTask("defend");
              }
              globalShowShark = true;
              toProtect();
            }else{
              resumeTemp("globalShowDanger2");
              setState(() {
                globalShowDanger2 = false;
                alreadyShowProtectPop = false;
                // ArrowOverlay.hide();
                GameManager.instance.hideDanger();
                globalShowShark = true;
                EventManager.instance.postEvent(EventConfig.shark_attack_c);
              });
            }
            Future.delayed(const Duration(milliseconds: 2000), () async {
              globalShowShark = false;
              if (!mounted) return;
              if (!globalShowProtect) {
                bool result = await isGameOver(force: true);
                if (result) {
                  return;
                }
              } else {
                TaskManager.instance.addTask("defend");
              }
            });
          }
        }
        progress = GameManager.instance.getCurrentProgress(gameData);
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if ((gameData.coin - oldCoin) > 1 && gameData.level == 3) {
            oldCoin = GameManager.instance.getCoinShow2(gameData.coin);
            moneyListener.value = gameData.coin;
          }
          globalTimeListener.value = progress;
          lifeNotifier.value = gameData.life;
          var getPropsProgress = GameManager.instance.getPropsProgress(
            propsTime,
          );

          propsNotifier.value = getPropsProgress;
          GameManager.instance.updateCoinToGame(gameData.coin);
          GameManager.instance.updateProtectTime(gameData.protectTime);
          // if(getPropsProgress >= 1){
          //   guideProps = true;
          // }else{
          //   guideProps = false;
          // }
          var needRefresh = false;
          if (timeCoinBubbles >= RewardManager.instance.findCoinBubbleTime() &&
              !showCoinBubbles) {
            timeCoinBubbles = 0;
            needRefresh = true;
            addCoin = 0;
            showCoinBubbles = true;
          }
          if (timeCoinBubbles2 >= RewardManager.instance.findCoinBubbleTime() &&
              !showCoinBubbles2) {
            timeCoinBubbles2 = 0;
            needRefresh = true;
            addCoin2 = 0;
            showCoinBubbles2 = true;
          }
          if (timeCoinBubbles3 >= RewardManager.instance.findCoinBubbleTime() &&
              !showCoinBubbles3) {
            timeCoinBubbles3 = 0;
            needRefresh = true;
            addCoin3 = 0;
            showCoinBubbles3 = true;
          }
          if (timeFoodBubbles >= RewardManager.instance.findFoodBubbleTime() &&
              !showFoodBubbles) {
            timeFoodBubbles = 0;
            needRefresh = true;
            showFoodBubbles = true;
          }
          if (timePearBubbles >= RewardManager.instance.findPearBubbleTime() &&
              !showPearlBubbles1) {
            timePearBubbles = 0;
            needRefresh = true;
            showPearlBubbles1 = true;
          }
          if (needRefresh) {
            setState(() {
              //更新泡泡
            });
          }
        });
      },
    );
  }

  Future<bool> isGameOver({bool force = false}) async {
    if (gameData.life <= 0 || force) {
      GlobalTimerManager().cancelTimer();
      //游戏结束
      var result = await PopManager().show(
        context: context,
        child: GameFailPop(
          tag: force
              ? EventConfig.fixrn_attack_rv
              : EventConfig.fixrn_starve_rv,
        ),
      );
      if (result == 0) {
        GameManager.instance.reset(gameData);
        lifeNotifier.value = 0;
        registerTimer();
        cutTime = 0;
        aliveTime = 0;
        realShowSharkTime = 0;
        setState(() {
          LocalCacheUtils.putGameData(gameData);
        });
        return true;
      } else {
        GameManager.instance.addOneLife(gameData);
        setState(() {});
      }
    }
    return false;
  }

  buildFood() {
    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      child: globalShowFood
          ? DropFadeImage(
              key: GlobalKey(),
              child: Image.asset(
                "assets/images/ic_food.webp",
                width: 46.w,
                height: 46.h,
              ),
            )
          : SizedBox.shrink(),
    );
  }

  buildShark() {
    return globalShowShark
        ? SharkWidget(
            key: GlobalKey(),
            imagePath: "assets/images/ic_shark.webp",
            top: 420.h,
            width: 204.w,
            height: 101.h,
          )
        : SizedBox.shrink();
  }

  buildDanger() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (globalShowDanger2) {
    //     // ArrowOverlay.hide();
    //     // ArrowOverlay.show(context, ArrowWidget());
    //     firstShowProtectKey = false;
    //     LocalCacheUtils.putBool(LocalCacheConfig.firstShowProtectKey, false);
    //   }
    // });

    return Positioned.fill(
      child: globalShowDanger2
          ? Stack(
              children: [
                Positioned(
                  bottom: 110.h,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity, // 宽度，可根据需求修改
                    height: 71.h, // 高度，可根据需求修改
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xBFE5452D), // 上方不透明红色
                          Color(0x00E5452D), // 下方透明
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 200.h,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity, // 宽度，可根据需求修改
                    height: 71.h, // 高度，可根据需求修改
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xBFE5452D), // 上方不透明红色
                          Color(0x00E5452D), // 下方透明
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 280.h,
                  right: 50.w,
                  child: ArrowWidget(progress: 1),
                ),
              ],
            )
          : SizedBox.shrink(),
    );
  }


  void showDanger() {
    if (globalShowDanger2) return;
    globalShowDanger2 = true;
    setState(() {
    });
    if (!globalShowProtect) {
      GameManager.instance.pauseMovement();
      GameManager.instance.showDanger();
    }
  }

  /// 监听 App 生命周期切换
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      LogUtils.logD("${TAG} resumed");
      userData = LocalCacheUtils.getUserData();
      Future.delayed(Duration(seconds: 1), () async {
        if (!mounted) return;
        if(adIsPlay || isLaunch){
          return;
        }
        if(allowResume){
          allowResume = false;
          newUserGuide();
        }
        resumeTemp("gamePage state == AppLifecycleState.resumed");
      });

    } else if (state == AppLifecycleState.paused) {
      LogUtils.logD("${TAG} paused");
      if (tutorialCoachMark?.isShowing ?? false) {
        // 自定义逻辑
        allowResume = true;
        tutorialCoachMark?.skip(); // 关闭当前教程
      }else if(showGuide3){
        allowResume = true;
        eventBus.fire(NotifyEvent(EventConfig.cancelGuide));
      }
      pauseTemp("gamePage state == AppLifecycleState.paused");
    }
  }

  TutorialCoachMark? tutorialCoachMark;
  late List<TargetFocus> globalGuideNew1Keys;
  GlobalKey globalGuideNew1 = GlobalKey();
  GlobalKey globalGuideNew2 = GlobalKey();
  GlobalKey globalGuideNew4 = GlobalKey();
  GlobalKey globalGuideNew5 = GlobalKey();

  /**
   * 0°	0	不旋转
      45°	math.pi / 4	右上方向
      90°	math.pi / 2	向上
      180°	math.pi	倒置
      270°	3 * math.pi / 2
   */
  void showMarkNew1() {
    EventManager.instance.postEvent(
      EventConfig.new_guide,
      params: {"pop_step": "pop1"},
    );
    pauseTemp("showMarkNew1");
    globalGuideNew1Keys = [];
    globalGuideNew1Keys.add(
      TargetFocus(
        identify: "guideNew1",
        keyTarget: globalGuideNew1,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        radius: 0.3,
        // 🔹 原来是 0.5，现在更小
        paddingFocus: 0,
        // 🔹 缩紧圆圈贴近目标
        // 圆角半径，自行调整
        contents: [
          TargetContent(
            align: ContentAlign.top, // 内容在高亮 widget 下方
            child: Stack(
              children: [
                Transform.translate(
                  offset: const Offset(30, 30), // 🔹 上移 20 像素，让内容更贴近高亮圈
                  child: Transform.rotate(
                    angle: math.pi,
                    child: Image.asset(
                      "assets/images/ic_arrow.webp",
                      width: 100.w,
                      height: 100.h,
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
      targets: globalGuideNew1Keys,
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: "",
      paddingFocus: 0,
      onFinish: () {
        // eventBus.fire(NotifyEvent("new2"));
        clickFood();
        showMarkNew2();
      },
      onClickTarget: (target) {
        ClickManager.clickAudio();
        EventManager.instance.postEvent(
          EventConfig.new_guide_c,
          params: {"pop_step": "pop1"},
        );
      },
    );
    tutorialCoachMark?.show(context: context);
  }

  void showMarkNew2() {
    EventManager.instance.postEvent(
      EventConfig.new_guide,
      params: {"pop_step": "pop2"},
    );
    userData = LocalCacheUtils.getUserData();
    userData.new1 = false;
    LocalCacheUtils.putUserData(userData);
    // 创建控制器
    globalGuideNew1Keys = [];
    globalGuideNew1Keys.add(
      TargetFocus(
        identify: "guideNew2",
        keyTarget: globalGuideNew2,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        radius: 1.0,
        // 圆角半径，自行调整
        contents: [
          TargetContent(
            align: ContentAlign.bottom, // 内容在高亮 widget 下方
            child: Stack(
              children: [
                Transform.translate(
                  offset: const Offset(100, 0), // 🔹 上移 20 像素，让内容更贴近高亮圈
                  child: Image.asset(
                    "assets/images/ic_arrow.webp",
                    width: 100.w,
                    height: 100.h,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    tutorialCoachMark = TutorialCoachMark(
      targets: globalGuideNew1Keys,
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: "",
      paddingFocus: 0,
      onFinish: () {
        setState(() {
          showCoinBubbles = false;
        });
        Future.delayed(Duration(milliseconds: 500), () async {
          if (!mounted) return;
          await PopManager().show(
            context: context,
            needAlpha: 0,
            child: CoinAnimalPop(),
          );
          gameData.coin += addCoin;
          LocalCacheUtils.putGameData(gameData);
          GameManager.instance.updateCoinToGame(gameData.coin);
          eventBus.fire(NotifyEvent(EventConfig.new3));
        });
      },
      onClickTarget: (target) {
        ClickManager.clickAudio();
        EventManager.instance.postEvent(
          EventConfig.new_guide_c,
          params: {"pop_step": "pop2"},
        );
      },
    );
    tutorialCoachMark?.show(context: context);
  }

  void showMarkNew4() {
    EventManager.instance.postEvent(
      EventConfig.new_guide,
      params: {"pop_step": "pop4"},
    );


    // 创建控制器
    globalGuideNew1Keys = [];
    globalGuideNew1Keys.add(
      TargetFocus(
        identify: "guideNew4",
        keyTarget: globalGuideNew4,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        radius: 1.0,
        // 圆角半径，自行调整
        contents: [
          TargetContent(
            align: ContentAlign.bottom, // 内容在高亮 widget 下方
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(0, 253.h, 0, 0),
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
                    padding: EdgeInsetsGeometry.fromLTRB(68.w, 264.h, 0, 0),
                    child: Container(
                      width: 268.w,
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      height: 74.h, // 让高度自适应文字
                      child: Stack(
                        children: [
                          Image.asset(
                            "assets/images/bg_level_up.webp",
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.fill,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(26.w, 0, 16.w, 0),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsetsGeometry.fromLTRB(
                                  32.w,
                                  0.h,
                                  20.w,
                                  0.h,
                                ),
                                child: AutoSizeText(
                                  "app_danger_tips".tr(),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF651922),
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(0, 50.h, 0, 0),
                    child: SizedBox(
                      width: 197.w,
                      height: 197.h,
                      child: Stack(
                        children: [
                          Center(
                            child: Image.asset(
                              "assets/images/ic_animal1.png",
                              width: 160.w,
                              height: 160.h,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Center(
                            child: Image.asset(
                              "assets/images/ic_guide_danger.webp",
                              width: 197.w,
                              height: 197.h,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Transform.translate(
                  offset: Offset(180.w, 0), // 🔹 上移 20 像素，让内容更贴近高亮圈
                  child: Transform.rotate(
                    angle: math.pi / 4,
                    child: Image.asset(
                      "assets/images/ic_arrow.webp",
                      width: 100.w,
                      height: 100.h,
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
      targets: globalGuideNew1Keys,
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: "",
      paddingFocus: 0,
      onFinish: () {
        clickProtect("click showMarkNew4");
      },
      onClickTarget: (target) {
        ClickManager.clickAudio();
        EventManager.instance.postEvent(
          EventConfig.new_guide_c,
          params: {"pop_step": "pop4"},
        );
      },
    );
    tutorialCoachMark?.show(context: context);
    pauseTemp("showMarkNew4");
  }

  void showMarkNew5() {
    EventManager.instance.postEvent(
      EventConfig.new_guide,
      params: {"pop_step": "pop5"},
    );
    pauseTemp("showMarkNew5");
    // 创建控制器
    globalGuideNew1Keys = [];
    globalGuideNew1Keys.add(
      TargetFocus(
        identify: "guideNew5",
        keyTarget: globalGuideNew5,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        radius: 1.0,
        // 圆角半径，自行调整
        contents: [
          TargetContent(
            align: ContentAlign.bottom, // 内容在高亮 widget 下方
            child: Stack(
              children: [
                Transform.translate(
                  offset: Offset(180.w, 0), // 🔹 上移 20 像素，让内容更贴近高亮圈
                  child: Transform.rotate(
                    angle: math.pi / 4,
                    child: Image.asset(
                      "assets/images/ic_arrow.webp",
                      width: 100.w,
                      height: 100.h,
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
      targets: globalGuideNew1Keys,
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: "",
      paddingFocus: 0,
      onFinish: () async {
        EventManager.instance.postEvent(
          EventConfig.new_guide,
          params: {"pop_step": "pop6"},
        );
        await toPropsAwardPop();
        EventManager.instance.postEvent(
          EventConfig.new_guide_c,
          params: {"pop_step": "pop6"},
        );
        userData = LocalCacheUtils.getUserData();
        userData.new5 = false;
        LocalCacheUtils.putUserData(userData);
        toCashMain(context,"click showMarkNew5");
      },
      onClickTarget: (target) async {
        ClickManager.clickAudio();
        EventManager.instance.postEvent(
          EventConfig.new_guide_c,
          params: {"pop_step": "pop5"},
        );
      },
    );
    tutorialCoachMark?.show(context: context);
  }

  Future<int> toPropsAwardPop() async {
    var result = await PopManager().show(
      context: context,
      child: PropsAwardPop(),
    );
    if (result != null) {
      await PopManager().show(
        context: context,
        needAlpha: 0,
        child: CoinAnimalPop(),
      );
      gameData.coin += result;
      GameManager.instance.updateCoinToGame(gameData.coin);
      LocalCacheUtils.putGameData(gameData);
      return 1;
    } else {
      return 0;
    }
  }

  void clickFood() {
    if (gameData.foodCount < 10) {
      GameManager.instance.showTips("app_not_enough_food".tr());
      return;
    } else {
      var foodCount = LocalCacheUtils.getInt(
        LocalCacheConfig.cacheKeyFoodCount,
      );
      foodCount += 1;
      var showBubble = false;
      if (foodCount % 2 == 0) {
        showBubble = true;
      }
      LocalCacheUtils.putInt(LocalCacheConfig.cacheKeyFoodCount, foodCount);
      setState(() {
        if (showBubble) {
          showPearlBubbles2 = true;
        }
        if (globalShowFood) return;
        globalShowFood = true;
        gameData.foodCount -= 10;
        GameManager.instance.addLife(gameData);
        LocalCacheUtils.putGameData(gameData);
      });
      Future.delayed(Duration(seconds: 1), () {
        globalShowFood = false;
      });
      TaskManager.instance.addTask("feed");
    }
  }

  var allowCoinPopAD = true;
  var allowCoinPopAD2 = true;
  var allowCoinPopAD3 = true;

  Widget buildCoinBubbles() {
    if (addCoin == 0) {
      addCoin = RewardManager.instance.findReward(
        RewardManager.instance.rewardData?.cashBubble?.prize,
        LocalCacheUtils.getGameData().coin,
      );
    }
    return showCoinBubbles
        ? Positioned(
            left: 38.w,
            bottom: 241.h,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              pressedOpacity: 0.7,
              child: BubbleWidget(key: globalGuideNew2, type: 0, coin: addCoin),
              onPressed: () {
                if (!ClickManager.canClick(context: context)) return;
                if (!allowCoinPopAD) return;
                allowCoinPopAD = false;
                ADShowManager(
                  adEnum: ADEnum.rewardedAD,
                  tag: "reward",
                  result: (type, hasValue) async {
                    allowCoinPopAD = true;
                    if (hasValue) {
                      await PopManager().show(
                        context: context,
                        needAlpha: 0,
                        child: CoinAnimalPop(),
                      );
                      setState(() {
                        showCoinBubbles = false;
                        gameData.coin += addCoin;
                        LocalCacheUtils.putGameData(gameData);
                        TaskManager.instance.addTask("bubbles");
                      });
                    }
                  },
                ).showScreenAD(EventConfig.fixrn_pop_rv, awaitLoading: true);
              },
            ),
          )
        : SizedBox.shrink();
  }
  Widget buildCoinBubbles2() {
    if (addCoin2 == 0) {
      addCoin2 = RewardManager.instance.findReward(
        RewardManager.instance.rewardData?.cashBubble?.prize,
        LocalCacheUtils.getGameData().coin,
      );
    }
    return showCoinBubbles2
        ? Positioned(
      left: 80.w,
      bottom: 120.h,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        pressedOpacity: 0.7,
        child: BubbleWidget(type: 3, coin: addCoin2),
        onPressed: () {
          if (!ClickManager.canClick(context: context)) return;
          if (!allowCoinPopAD2) return;
          allowCoinPopAD2 = false;
          ADShowManager(
            adEnum: ADEnum.intAD,
            tag: "int",
            result: (type, hasValue) async {
              allowCoinPopAD2 = true;
              await PopManager().show(
                context: context,
                needAlpha: 0,
                child: CoinAnimalPop(),
              );
              setState(() {
                showCoinBubbles2 = false;
                gameData.coin += addCoin2;
                LocalCacheUtils.putGameData(gameData);
                TaskManager.instance.addTask("bubbles");
              });
            },
          ).showScreenAD(EventConfig.fixrn_pop_int, awaitLoading: true);
        },
      ),
    )
        : SizedBox.shrink();
  }

  Widget buildCoinBubbles3() {
    if (addCoin3 == 0) {
      addCoin3 = RewardManager.instance.findReward(
        RewardManager.instance.rewardData?.cashBubble?.prize,
        LocalCacheUtils.getGameData().coin,
      );
    }
    return showCoinBubbles3
        ? Positioned(
      left: 230.w,
      bottom: 120.h,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        pressedOpacity: 0.7,
        child: BubbleWidget(type: 0, coin: addCoin3),
        onPressed: () {
          if (!ClickManager.canClick(context: context)) return;
          if (!allowCoinPopAD3) return;
          allowCoinPopAD3 = false;
          ADShowManager(
            adEnum: ADEnum.rewardedAD,
            tag: "reward",
            result: (type, hasValue) async {
              allowCoinPopAD = true;
              if (hasValue) {
                await PopManager().show(
                  context: context,
                  needAlpha: 0,
                  child: CoinAnimalPop(),
                );
                setState(() {
                  showCoinBubbles3 = false;
                  gameData.coin += addCoin3;
                  LocalCacheUtils.putGameData(gameData);
                  TaskManager.instance.addTask("bubbles");
                });
              }
            },
          ).showScreenAD(EventConfig.fixrn_pop_rv, awaitLoading: true);
        },
      ),
    )
        : SizedBox.shrink();
  }
}
