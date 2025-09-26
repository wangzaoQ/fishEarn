import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/GameConfig.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameFailPop extends StatefulWidget {
  const GameFailPop({super.key});

  @override
  State<GameFailPop> createState() => _GameFailPopState();
}

class _GameFailPopState extends State<GameFailPop> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 禁止默认返回
      onPopInvokedWithResult: (didPop, result) {
      },
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
          left: 105.w,
          right: 105.w,
          top: 322.h,
          child: Image.asset(
            "assets/images/ic_play.webp",
            width: double.infinity,
            height: 92.h,
          ),
        ),
        Positioned(
          left: 40.w,
          top: 537.h,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            pressedOpacity: 0.7,
            child: SizedBox(
              width: 139.w,
              height: 45.h,
              child: Stack(
                children: [
                  Image.asset("assets/images/bg_confirm.webp"),
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown, // 超出时缩小
                      child: Text(
                        "app_resurrection".tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF185F11),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onPressed: () {
              var gameData = LocalCacheUtils.getGameData();
              if(gameData.coin<=GameConfig.gameLifeCoin){
                GameManager.showTips("app_resurrection_tips".tr());
                return;
              }
              Navigator.pop(context, 1);
            },
          ),
        ),
        Positioned(
          right: 40.w,
          top: 537.h,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            pressedOpacity: 0.7,
            child: SizedBox(
              width: 139.w,
              height: 45.h,
              child: Stack(
                children: [
                  Image.asset("assets/images/bg_cancel.webp"),
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown, // 超出时缩小
                      child: Text(
                        "app_starting_over".tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB84418),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onPressed: () {
              Navigator.pop(context, 0);
            },
          ),
        ),
      ],
    ),);
  }
}
