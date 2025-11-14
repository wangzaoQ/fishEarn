import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/utils/ClickManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/EventConfig.dart';
import '../../config/LocalCacheConfig.dart';
import '../../config/global.dart';
import '../../data/GameData.dart';
import '../../utils/AudioUtils.dart';
import '../../utils/GameManager.dart';
import '../../utils/GlobalDataManager.dart';
import '../../utils/LocalCacheUtils.dart';
import '../../utils/net/EventManager.dart';
import '../GameText.dart';
import '../ProgressClipper.dart';
//无限转盘弹窗
class CashTipsPop extends StatefulWidget {
  const CashTipsPop({super.key});

  @override
  State<CashTipsPop> createState() => _CashTipsPopState();
}

class _CashTipsPopState extends State<CashTipsPop> {

  var cacheType = 0;
  late GameData gameData;
  var cacheShowMoney = true;


  @override
  void initState() {
    super.initState();
    gameData = LocalCacheUtils.getGameData();
    cacheType = LocalCacheUtils.getInt(
      LocalCacheConfig.cacheType,
      defaultValue: 0,
    );
    cacheShowMoney = LocalCacheUtils.getBool(
      LocalCacheConfig.cacheShowMoney,
      defaultValue: true,
    );
    EventManager.instance.postEvent(EventConfig.withdrawal_reminder);
  }

  @override
  Widget build(BuildContext context) {
    var template = "app_need_seconds".tr();
    var time = GlobalDataManager.instance.getUnLimitedTime();
    String result = template.replaceAll("{count}", "${time}");

    return PopScope(
      canPop: false, // 禁止默认返回
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {}
      },
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsetsGeometry.only(top: 137.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // ✅ 水平居中（可选）
                children: [
                  SizedBox(width: 298.w,height: 40.h,child:Stack(children: [
                    Image.asset(
                      "assets/images/bg_cash_tips.webp",
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // ✅水平居中
                      children: [
                      Image.asset(
                        "assets/images/ic_cash_tips_top.webp",
                        width: 31.w,
                        height: 37.h,
                      ),
                      SizedBox(width: 5.w,),
                      Text(result,style: TextStyle(fontSize: 16.sp,color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "AHV"),)
                    ],)
                  ],) ,),
                  SizedBox(height: 40.h,),
                  Image.asset(
                    "assets/images/ic_cash_tips_title.webp",
                    width: 224.w,
                    height: 22.h,
                  ),
                  SizedBox(height: 9.h,),
                  Image.asset(
                    "assets/images/ic_cash_tips2.webp",
                    width: 326.w,
                    height: 234.h,
                  ),
                  SizedBox(height: 9.h,),

                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      GameText(
                        showText: "You’re about to cash out ",
                        fontSize: 14.sp,
                        strokeColor: Color(0xFF514F4F),
                        strokeWidth: 1.w,
                        fillColor: Colors.white,
                      ),
                      GameText(
                        showText: "\$500!",
                        fillColor: Color(0xFF5CFF40),
                        strokeColor: Color(0xFF514F4F),
                        strokeWidth: 1.w,
                      ),
                      GameText(
                        showText: " Enjoy ${time} seconds of unlimited dice!",
                        fontSize: 14.sp,
                        strokeColor: Color(0xFF514F4F),
                        strokeWidth: 1.w,
                        fillColor: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: 7.h,),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    pressedOpacity: 0.7,
                    child: SizedBox(
                      width: 172.w,
                      height: 50.h,
                      child:Stack(
                        alignment: Alignment.center, // 让子元素默认居中
                        children: [
                          Image.asset(
                            "assets/images/bg_confirm.webp",
                            fit: BoxFit.fill,
                          ),
                          AutoSizeText(
                            "app_confirm".tr(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF185F11),
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      if (!ClickManager.canClick(context: context)) return;
                      EventManager.instance.postEvent(EventConfig.withdrawal_reminder_c);
                      Navigator.pop(context, 1);
                    },
                  )
                ],
              ),
            ),
          ),
          Positioned(
              left: 5.w,
              right: 5.w,
              bottom: 34.h,
              child: SizedBox(
            width: double.infinity,
            height: 127.h,
            child: Stack(
              children: [
                Image.asset(
                  cacheType == 0
                      ? "assets/images/bg_home_cash_paypal.webp"
                      : "assets/images/bg_home_cash.webp",
                  width: double.infinity,
                  height: 127.h,
                  fit: BoxFit.fill,
                ),
                Positioned(
                  left: 22.w,
                  top: 10.h,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero, // 去掉默认内边距
                    pressedOpacity: 0.7,
                    child: SizedBox(
                      width: 115.w,
                      height: 27.h,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(
                            cacheType == 0 ? 0xFF2F5FC5 : 0xFF44B04C,
                          ),
                          // #012169 的十六进制写法
                          borderRadius: BorderRadius.circular(
                            14,
                          ), // 圆角 5dp
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            cacheType == 0
                                ? Image.asset(
                              width: 70.w,
                              height: 17.h,
                              "assets/images/ic_cash_paypal.webp",
                            )
                                : Image.asset(
                              width: 77.w,
                              height: 20.h,
                              "assets/images/ic_cash_cash.webp",
                            ),
                            Image.asset(
                              width: 15.w,
                              height: 10.h,
                              "assets/images/ic_home_cash_change.webp",
                            ),
                          ],
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (cacheType == 0) {
                          cacheType = 1;
                        } else {
                          cacheType = 0;
                        }
                        LocalCacheUtils.putInt(
                          LocalCacheConfig.cacheType,
                          cacheType,
                        );
                      });
                    },
                  ),
                ),
                // Positioned(
                //   top: 27.h,
                //   right: 128.w,
                //   child: SizedBox(
                //     width: 17.w,
                //     height: 11.h,
                //     child: CupertinoButton(
                //       padding: EdgeInsets.zero,
                //       pressedOpacity: 0.7,
                //       child: Image.asset("assets/images/ic_eye.webp"),
                //       onPressed: () {
                //         setState(() {
                //           cacheShowMoney = !cacheShowMoney;
                //           LocalCacheUtils.putBool(
                //             LocalCacheConfig.cacheShowMoney,
                //             !cacheShowMoney,
                //           );
                //         });
                //       },
                //     ),
                //   ),
                // ),
                Positioned(
                  top: 10.h,
                  left: 262.w,
                  child: ValueListenableBuilder<double>(
                    valueListenable: moneyListener,
                    builder: (_, value, __) {
                      gameData = LocalCacheUtils.getGameData();

                      return GameText(
                        showText: cacheShowMoney
                            ? "\$${GameManager.instance.getCoinShow2(gameData.coin)}"
                            : "****",
                        fontSize: 28.sp,
                        fillColor: Colors.white,
                        strokeColor: Colors.black,
                        strokeWidth: 1.w,
                      ); // 只重建这一小块
                    },
                  ),
                ),
                Positioned(
                  right: 21.w,
                  top: 50.h,
                  child: SizedBox(
                    width: 102.w,
                    height: 30.h,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      pressedOpacity: 0.7,
                      child: Stack(
                        children: [
                          Image.asset(
                            width: 102.w,
                            height: 30.h,
                            "assets/images/bg_confirm.webp",
                            fit: BoxFit.fill,
                          ),
                          Center(
                            child: Text(
                              "app_withdraw".tr(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Color(0xFF185F11),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        if (!ClickManager.canClick(context: context)) return;
                        EventManager.instance.postEvent(EventConfig.withdrawal_reminder_cash);
                        Navigator.pop(context,2);
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: 20.w,
                  top: 47.h,
                  right: 166.w,
                  child: Wrap(
                    alignment: WrapAlignment.center, // 居中对齐
                    runSpacing: -4, // 换行后两行之间的垂直间距
                    children: [
                      GameText(
                        showText: 'Your First ',
                        fontSize: 16.sp,
                        fillColor: Colors.white,
                        strokeWidth: 1.w,
                        strokeColor: Colors.black,
                      ),
                      GameText(
                        showText: '\$500',
                        fontSize: 16.sp,
                        fillColor: Color(0xFF5CFF40),
                        strokeWidth: 1.w,
                        strokeColor: Colors.black,
                      ),
                      GameText(
                        showText: ' Today! I\'ll Guide You!',
                        fontSize: 16.sp,
                        fillColor: Colors.white,
                        strokeWidth: 1.w,
                        strokeColor: Colors.black,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 90.h,
                  left: 22.w,
                  right: 22.w,
                  child: SizedBox(
                    height: 25.h,
                    child: ValueListenableBuilder<double>(
                      valueListenable: moneyListener,
                      builder: (_, value, __) {
                        gameData = LocalCacheUtils.getGameData();
                        var current = GameManager.instance.getCoinShow2(
                          gameData.coin,
                        );
                        var All = 500;
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final progress = (current / All).clamp(
                              0.0,
                              1.0,
                            ); // 限制范围 0~1
                            final clipWidth =
                                (constraints.maxWidth - 4) * progress;

                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                // 背景条
                                Image.asset(
                                  "assets/images/bg_home_cash_progress.webp",
                                  height: 25.h,
                                  fit: BoxFit.fill,
                                ),

                                // 前景进度条
                                Padding(
                                  padding: EdgeInsets.all(4.h),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: ClipRect(
                                      clipper: ProgressClipper(
                                        width: clipWidth,
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.none,
                                        // 不缩放图片
                                        alignment: Alignment.centerLeft,
                                        // 从左对齐
                                        child: Image.asset(
                                          "assets/images/bg_home_cash_progress2.webp",
                                          height: 25.h,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ); // 只重建这一小块
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsetsGeometry.only(top: 85.h),
                    child: SizedBox(
                      width: 100.w,
                      height: 25.h,
                      child: ValueListenableBuilder<double>(
                        valueListenable: moneyListener,
                        builder: (_, value, __) {
                          gameData = LocalCacheUtils.getGameData();

                          var current = GameManager.instance
                              .getCoinShow2(gameData.coin);
                          var All = 500;
                          return Row(
                            children: [
                              GameText(
                                showText: "\$${current}",
                                fillColor: Colors.white,
                                strokeColor: Colors.black,
                                strokeWidth: 1.w,
                              ),
                              GameText(
                                showText: "/${All}",
                                fillColor: Color(0xFF5CFF40),
                                strokeColor: Colors.black,
                                strokeWidth: 1.w,
                              ),
                            ],
                          ); // 只重建这一小块
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
