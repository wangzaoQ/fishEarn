import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/EventConfig.dart';
import 'package:fish_earn/config/GameConfig.dart';
import 'package:fish_earn/utils/AudioUtils.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/GameData.dart';
import '../../utils/ClickManager.dart';
import '../../utils/ad/ADEnum.dart';
import '../../utils/ad/ADShowManager.dart';
import '../../utils/net/EventManager.dart';

class ProtectPop extends StatefulWidget {
  const ProtectPop({super.key});

  @override
  State<ProtectPop> createState() => _ProtectPopState();
}

class _ProtectPopState extends State<ProtectPop> {
  GameData? gameData;

  @override
  void initState() {
    super.initState();
    EventManager.instance.postEvent(EventConfig.defense_pop);
    gameData = LocalCacheUtils.getGameData();
  }

  var allowClickAd = true;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Image.asset(
        "assets/images/bg_protect_coin.webp",
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.fill,
      ),
      Padding(padding: EdgeInsetsGeometry.only(top: 220.h),child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center, // ✅ 关键，让第一个元素贴顶
        children: [
          /// 关闭按钮（贴顶部右侧）
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 0.h, right: 7.w),
              child: CupertinoButton(
                padding: EdgeInsets.zero, // 去掉默认内边距
                pressedOpacity: 0.7,
                child: SizedBox(
                  width: 23.w,
                  height: 23.h,
                  child: Center(
                    child: Image.asset(
                      "assets/images/ic_close.webp",
                      width: 23.w,
                      height: 23.h,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, -1);
                },
              ),
            ),
          ),

          /// 顶部标题
          Padding(
            padding: EdgeInsets.only(left: 27.w, right: 27.w, top: 0.h),
            child: Image.asset(
              "assets/images/ic_protect_title.webp",
              width: double.infinity,
              height: 24.h,
            ),
          ),
          SizedBox(
            width: 230.w,
            height: 230.h,
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    "assets/images/bg_protect_pop1.webp",
                    width: 230.w,
                    height: 230.h,
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  left: 46.w,
                  right: 40.w,
                  top: 16.h,
                  bottom: 39.h,
                  child: Image.asset(
                    "assets/images/bg_protect_pop2.webp",
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.fill,
                  ),
                ),
                getImg(),
                Positioned(
                  left: 60.w,
                  right: 10.w,
                  bottom: 10.h,
                  child: Image.asset(
                    "assets/images/ic_protect_coin2.webp",
                    width: double.infinity,
                    height: 82.h,
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  left: 33.w,
                  right: 49.w,
                  bottom: 20.h,
                  child: Image.asset(
                    "assets/images/ic_protect_coin1.webp",
                    width: double.infinity,
                    height: 82.h,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 28.w),child:RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14.sp, color: Colors.white,fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: "app_game_protect_pop_content".tr()),
                TextSpan(
                  text: "\$${GameConfig.cash1}",
                  style: TextStyle(color: Color(0xFF5CFF40)),
                ),
              ],
            ),
          )
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // ✅ 水平居中
                crossAxisAlignment: CrossAxisAlignment.center, // ✅ 垂直居中
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    pressedOpacity: 0.7,
                    child: SizedBox(
                      width: 117.w,
                      height: 34.h,
                      child: Stack(
                        alignment: Alignment.center, // 让子元素默认居中
                        children: [
                          Image.asset("assets/images/bg_cancel.webp"),
                          Center(
                            child: AutoSizeText(
                              "app_game_protect_pop_button1".tr(),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB84418),
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      if (!ClickManager.canClick(context: context)) return;
                      EventManager.instance.postEvent(
                        EventConfig.defense_pop_c,
                        params: {"click_type": "money"},
                      );
                      var gameData = LocalCacheUtils.getGameData();
                      if (gameData.coin <= GameConfig.reviveCostCoin) {
                        GameManager.instance.showTips(
                          "app_resurrection_tips".tr(),
                        );
                        return;
                      }
                      if (!allowClickAd) return;
                      allowClickAd = false;
                      ADShowManager(
                        adEnum: ADEnum.intAD,
                        tag: "int",
                        result: (type, hasValue) {
                          if(!mounted)return;
                          allowClickAd = true;
                          var gameData = LocalCacheUtils.getGameData();
                          gameData.coin-=GameConfig.reviveCostCoin;
                          LocalCacheUtils.putGameData(gameData);
                          Navigator.pop(context, 0);
                        },
                      ).showScreenAD(EventConfig.fixrn_shield_int);
                    },
                  ),
                  SizedBox(width: 30.h),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    pressedOpacity: 0.7,
                    child: SizedBox(
                      width: 143.w,
                      height: 46.h,
                      child: Stack(
                        alignment: Alignment.center, // 让子元素默认居中
                        children: [
                          Image.asset("assets/images/bg_confirm.webp"),
                          Center(
                            child: AutoSizeText(
                              "app_game_protect_pop_button2".tr(),
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF185F11),
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      if (!ClickManager.canClick(context: context)) return;
                      EventManager.instance.postEvent(
                        EventConfig.defense_pop_c,
                        params: {"click_type": "ad"},
                      );
                      if (!allowClickAd) return;
                      allowClickAd = false;
                      ADShowManager(
                        adEnum: ADEnum.rewardedAD,
                        tag: "reward",
                        result: (type, hasValue) {
                          if(!mounted)return;
                          allowClickAd = true;
                          if (hasValue) {
                            Navigator.pop(context, 1);
                          }
                        },
                      ).showScreenAD(EventConfig.fixrn_shield_rv, awaitLoading: true);
                    },
                  ),
                ],
              ),
              Positioned(
                right: 33.w,
                top: -15.h,
                child: Image.asset(
                  "assets/images/ic_ad_tips.webp",
                  width: 36.w,
                  height: 36.h,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h,),
          CupertinoButton(
            onPressed: () {
              if (!ClickManager.canClick(context: context)) return;
              EventManager.instance.postEvent(
                EventConfig.defense_pop_c,
                params: {"click_type": "not"},
              );
              Navigator.pop(context);
            },
            child: Text(
              "app_wealth_paused".tr(),
              style: TextStyle(
                fontSize: 15.sp,
                color: Color(0xBFFFFFFF),
                decoration: TextDecoration.underline,
                // ✅ 下划线
                decorationColor: Color(0xBFFFFFFF),
                // 可选：自定义下划线颜色
                decorationThickness: 1.h,
              ),
            ),
          )
        ],
      ))
    ],);
  }

  Widget getImg() {
    if (gameData!.level == 1) {
      return Positioned(
        left: 80.w,
        right: 80.w,
        top: 120.h,
        bottom: 70.h,
        child: Image.asset(
          "assets/images/ic_game1.png",
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.fill,
        ),
      );
    } else if (gameData!.level == 1) {
      return Positioned(
        left: 55.w,
        right: 55.w,
        top: 75.h,
        bottom: 40.h,
        child: Image.asset(
          "assets/images/ic_animal1.png",
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.fill,
        ),
      );
    } else {
      return Positioned(
        left: 55.w,
        right: 55.w,
        top: 75.h,
        bottom: 40.h,
        child: Image.asset(
          "assets/images/ic_game3_a1.png",
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.fill,
        ),
      );
    }
  }
}
