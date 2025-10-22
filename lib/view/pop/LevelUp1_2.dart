import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/utils/GlobalDataManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/EventConfig.dart';
import '../../utils/AudioUtils.dart';
import '../../utils/net/EventManager.dart';
import '../GameText.dart';

class LevelUp1_2 extends StatefulWidget {
  const LevelUp1_2({super.key});

  @override
  State<LevelUp1_2> createState() => _LevelUp1_2State();
}

class _LevelUp1_2State extends State<LevelUp1_2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // 一圈时间
    )..repeat(); // 无限旋转
    AudioUtils().playTempAudio("audio/levelUp.mp3");
    EventManager.instance.postEvent(EventConfig.growing_ad_pop);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 50.w,
          right: 50.w,
          top: 169.h,
          child: Image.asset(
            "assets/images/ic_level_up1_2.png",
            width: double.infinity,
            height: 105.h,
            fit: BoxFit.fill,
          ),
        ),
        Positioned(
          right: 32.w,
          top: 146.h,
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
          top: 260.h,
          right: 0,
          child: SizedBox(
            width: 210.w,
            height: 210.h,
            child: Stack(
              children: [
                RotationTransition(
                  turns: _controller,
                  child: Image.asset("assets/images/bg_game_progress.webp",fit: BoxFit.fill,),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/images/ic_animal1.png",
                    width: 123.w,
                    height: 123.h,
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsetsGeometry.only(top: 268.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // ← 子元素水平居中
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/ic_coin2.webp",
                          width: 45.w,
                          height: 45.h,
                        ),
                        GameText(
                          showText: "+0.02/1s",
                          fontSize: 25.sp,
                          fillColor: Color(0xFFFFEF50),
                          strokeColor: Color(0xFF9B4801),
                          strokeWidth: 2.w,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 8.h,
                  child: Image.asset(
                    "assets/images/ic_level_arrow.webp",
                    width: 57.w,
                    height: 57.h,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 46.w,
          top: 414.h,
          child: SizedBox(
            width: 88.w,
            height: 87.h,
            child: Image.asset("assets/images/ic_game1.png"),
          ),
        ),
        Positioned(
          left: 101.w,
          right: 101.w,
          top: 549.h,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            pressedOpacity: 0.7,
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child:Stack(
                alignment: Alignment.center, // 让子元素默认居中
                children: [
                  Image.asset(
                    "assets/images/bg_confirm.webp",
                    fit: BoxFit.fill,
                  ),
                  AutoSizeText(
                    "app_level_up".tr(),
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
              AudioUtils().playClickAudio();
              Navigator.pop(context, 1);
            },
          ),
        ),
        Positioned(
          right: 100.w,
          top: 538.h,
          child: Image.asset(
            "assets/images/ic_ad_tips.webp",
            width: 36.w,
            height: 36.h,
          ),
        ),
      ],
    );
  }
}
