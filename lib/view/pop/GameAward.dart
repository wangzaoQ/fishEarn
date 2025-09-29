import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/GameConfig.dart';
import 'package:fish_earn/utils/AudioUtils.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameAwardPop extends StatefulWidget {
  const GameAwardPop({super.key});

  @override
  State<GameAwardPop> createState() => _GameAwardPopState();
}

class _GameAwardPopState extends State<GameAwardPop>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // 一圈时间
    )..repeat(); // 无限旋转
    AudioUtils().playTempAudio("audio/award.mp3");
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 禁止默认返回
      onPopInvokedWithResult: (didPop, result) {},
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsetsGeometry.only(top: 252.h),
              child: GameText(showText: "app_fail_title".tr()),
            ),
          ),
          Positioned(
            left: 23.w,
            right: 23.w,
            top: 180.h,
            child: Image.asset(
              "assets/images/bg_award.webp",
              width: double.infinity,
              height: 417.h,
            ),
          ),
          Positioned(
            top: 333.h,
            left: 95.w,
            right: 95.w,
            child: SizedBox(
              width: 183.w,
              height: 183.h,
              child: RotationTransition(
                turns: _controller,
                child: Image.asset(
                  "assets/images/bg_game_progress.webp",
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsetsGeometry.only(top: 369.h),
              child: SizedBox(
                width: 110.w,
                height: 110.h,
                child: Image.asset(
                  "assets/images/ic_food_award.webp",
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 609.h,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              pressedOpacity: 0.7,
              child: SizedBox(
                width: 172.w,
                height: 50.h,
                child: Stack(
                  alignment: Alignment.center, // 让子元素默认居中
                  children: [
                    Image.asset("assets/images/bg_confirm.webp"),
                    Center(
                      child: AutoSizeText(
                        "app_claim".tr(),
                        style: TextStyle(
                          fontSize: 18,
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
                AudioUtils().playClickAudio();
                var gameData = LocalCacheUtils.getGameData();
                gameData.foodCount += 10;
                LocalCacheUtils.putGameData(gameData);
                Navigator.pop(context, 1);
              },
            ),
          ),
          Align(alignment: Alignment.topCenter,child: Padding(padding: EdgeInsetsGeometry.only(top: 314.h),child: GameText(
            showText: "app_wave_treasure".tr(),
            fontSize: 19.sp,
            fillColor: Color(0xFFFFD828),
            strokeColor: Color(0xFFFC5B88),
            strokeWidth: 1.w,
          ),),),
          Positioned(
            right: 20.w,
            top: 168.h,
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
        ],
      ),
    );
  }
}
