import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/utils/GlobalConfigManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/UserData.dart';
import '../../utils/AudioUtils.dart';
import '../GameText.dart';

class PropsAwardPop extends StatefulWidget {
  const PropsAwardPop({super.key});

  @override
  State<PropsAwardPop> createState() => _PropsAwardPopState();
}

class _PropsAwardPopState extends State<PropsAwardPop>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late UserData userData;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // 一圈时间
    )..repeat(); // 无限旋转
    userData = LocalCacheUtils.getUserData();
  }

  int selected = -1;

  int selectedCoin = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 50.w,
          right: 50.w,
          top: 177.h,
          child: Image.asset(
            "assets/images/ic_props_award_top.webp",
            width: double.infinity,
            height: 105.h,
            fit: BoxFit.fill,
          ),
        ),
        Positioned(
          right: 20.w,
          top: 155.h,
          child: CupertinoButton(
            child: Image.asset(
              "assets/images/ic_pop_close.webp",
              width: 32.w,
              height: 32.h,
            ),
            onPressed: () {
              AudioUtils().playClickAudio();
              Navigator.pop(context, null);
            },
          ),
        ),
        Positioned(
          top: 287.h,
          right: 28.w,
          left: 28.w,
          child: Text(
            "app_app_props_tips".tr(),
            textAlign: TextAlign.center, // ✅ 多行文字居中
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 390.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // 横向居中
            children: [
              SizedBox(
                width: 118.w,
                height: 164.h,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        pressedOpacity: 0.7,
                        child: SizedBox(
                          width: 118.w,
                          height: 118.h,
                          child: Stack(
                            children: [
                              selected == 0 || selected == 3
                                  ? RotationTransition(
                                      turns: _controller,
                                      child: Image.asset(
                                        "assets/images/bg_game_progress.webp",
                                        fit: BoxFit.fill,
                                      ),
                                    )
                                  : Image.asset(
                                      "assets/images/bg_game_progress.webp",
                                      fit: BoxFit.fill,
                                    ),
                              Positioned(
                                left: 24.w,
                                right: 20.w,
                                top: 15.h,
                                bottom: 25.h,
                                child: Image.asset(
                                  "assets/images/ic_award.webp",
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              selected == 0 || selected == 3
                                  ? Positioned(
                                      right: 16.w,
                                      bottom: 21.h,
                                      child: Image.asset(
                                        "assets/images/ic_award_selected.webp",
                                        width: 37.w,
                                        height: 37.h,
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            selected = 0;
                            selectedCoin = 8;
                            if(userData.new5){
                              Navigator.pop(context,selectedCoin);
                            }
                          });
                        },
                      ),
                    ),
                    Positioned(
                      child: Visibility(
                        visible: selected == 0 || selected == 3,
                        child: Stack(
                          children: [
                            Image.asset(
                              "assets/images/bg_award_tips.webp",
                              width: 62.w,
                              height: 73.h,
                              fit: BoxFit.fill,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsetsGeometry.fromLTRB(
                                  5.w,
                                  7.h,
                                  0,
                                  0,
                                ),
                                child: Image.asset(
                                  "assets/images/ic_coin2.webp",
                                  width: 54.w,
                                  height: 49.h,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 118.w,
                height: 164.h,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        pressedOpacity: 0.7,
                        child: SizedBox(
                          width: 118.w,
                          height: 118.h,
                          child: Stack(
                            children: [
                              selected == 1 || selected == 3
                                  ? RotationTransition(
                                      turns: _controller,
                                      child: Image.asset(
                                        "assets/images/bg_game_progress.webp",
                                        fit: BoxFit.fill,
                                      ),
                                    )
                                  : Image.asset(
                                      "assets/images/bg_game_progress.webp",
                                      fit: BoxFit.fill,
                                    ),
                              Positioned(
                                left: 24.w,
                                right: 20.w,
                                top: 15.h,
                                bottom: 25.h,
                                child: Image.asset(
                                  "assets/images/ic_award.webp",
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              selected == 1 || selected == 3
                                  ? Positioned(
                                      right: 16.w,
                                      bottom: 21.h,
                                      child: Image.asset(
                                        "assets/images/ic_award_selected.webp",
                                        width: 37.w,
                                        height: 37.h,
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            selected = 1;
                            selectedCoin = 9;
                            if(userData.new5){
                              Navigator.pop(context,selectedCoin);
                            }
                          });
                        },
                      ),
                    ),
                    Positioned(
                      child: Visibility(
                        visible: selected == 1 || selected == 3,
                        child: Stack(
                          children: [
                            Image.asset(
                              "assets/images/bg_award_tips.webp",
                              width: 62.w,
                              height: 73.h,
                              fit: BoxFit.fill,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsetsGeometry.fromLTRB(
                                  5.w,
                                  7.h,
                                  0,
                                  0,
                                ),
                                child: Image.asset(
                                  "assets/images/ic_coin2.webp",
                                  width: 54.w,
                                  height: 49.h,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 118.w,
                height: 164.h,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        pressedOpacity: 0.7,
                        child: SizedBox(
                          width: 118.w,
                          height: 118.h,
                          child: Stack(
                            children: [
                              selected == 2 || selected == 3
                                  ? RotationTransition(
                                      turns: _controller,
                                      child: Image.asset(
                                        "assets/images/bg_game_progress.webp",
                                        fit: BoxFit.fill,
                                      ),
                                    )
                                  : Image.asset(
                                      "assets/images/bg_game_progress.webp",
                                      fit: BoxFit.fill,
                                    ),
                              Positioned(
                                left: 24.w,
                                right: 20.w,
                                top: 15.h,
                                bottom: 25.h,
                                child: Image.asset(
                                  "assets/images/ic_award.webp",
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              selected == 2 || selected == 3
                                  ? Positioned(
                                      right: 16.w,
                                      bottom: 21.h,
                                      child: Image.asset(
                                        "assets/images/ic_award_selected.webp",
                                        width: 37.w,
                                        height: 37.h,
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            selected = 2;
                            selectedCoin = 10;
                            if(userData.new5){
                              Navigator.pop(context,selectedCoin);
                            }
                          });
                        },
                      ),
                    ),
                    Positioned(
                      child: Visibility(
                        visible: selected == 2 || selected == 3,
                        child: Stack(
                          children: [
                            Image.asset(
                              "assets/images/bg_award_tips.webp",
                              width: 62.w,
                              height: 73.h,
                              fit: BoxFit.fill,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsetsGeometry.fromLTRB(
                                  5.w,
                                  7.h,
                                  0,
                                  0,
                                ),
                                child: Image.asset(
                                  "assets/images/ic_coin2.webp",
                                  width: 54.w,
                                  height: 49.h,
                                ),
                              ),
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
        ),
        Positioned(
          left: 101.w,
          right: 101.w,
          top: 600.h,
          child: Visibility(
            visible: selected != -1 && !userData.new5,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              pressedOpacity: 0.7,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    "assets/images/bg_confirm.webp",
                    fit: BoxFit.fill,
                  ),
                  AutoSizeText(
                    "app_all".tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF185F11),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                AudioUtils().playClickAudio();
                Navigator.pop(context, selectedCoin * 2);
              },
            ),
          ),
        ),
        Positioned(
          right: 100.w,
          top: 585.h,
          child: Visibility(
            visible: selected != -1 && !userData.new5,
            child: Image.asset(
              "assets/images/ic_ad_tips.webp",
              width: 36.w,
              height: 36.h,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 660.h),
            child: Visibility(
              visible: selected != -1 && !userData.new5,
              child: CupertinoButton(
                onPressed: () {
                  Navigator.pop(context, selectedCoin);
                },
                child: Text(
                  "+\$${selectedCoin}",
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
              ),
            ),
          ),
        ),
        Positioned(
          left: 23.w,
          bottom: 160.h,
          child: Visibility(
            visible: userData.new5,
            child: Image.asset(
              "assets/images/ic_fish_tips.webp",
              width: 75.w,
              height: 75.h,
            ),
          ),
        ),
        Positioned(
          bottom: 171.h,
          left: 84.w,
          right: 25.w,
          child: Visibility(
            visible: userData.new5,
            child: SizedBox(
              width: double.infinity,
              height: 74.h,
              child: Stack(
                children: [
                  Image.asset(
                    "assets/images/bg_level_up.webp",
                    width: double.infinity,
                    height: 74.h,
                    fit: BoxFit.fill,
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsetsGeometry.fromLTRB(
                        32.w,
                        0.h,
                        20.w,
                        0.h,
                      ),
                      child: AutoSizeText(
                        "app_award_first_tips".tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF651922),
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
