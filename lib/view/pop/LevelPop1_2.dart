import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/utils/GlobalConfigManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/AudioUtils.dart';
import '../GameText.dart';

class LevelPop1_2 extends StatefulWidget {
  const LevelPop1_2({super.key});

  @override
  State<LevelPop1_2> createState() => _LevelPop1_2State();
}

class _LevelPop1_2State extends State<LevelPop1_2> {

  @override
  void initState() {
    super.initState();
    AudioUtils().playTempAudio("audio/levelUp.mp3");
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 90.w,
          right: 90.w,
          top: 156.h,
          child: Image.asset(
            "assets/images/ic_level1_2.webp",
            width: 195.w,
            height: 130.h,
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
          top: 210.h,
          left: 0,
          right: 0,
          child: Image.asset("assets/images/bg_level2_3.webp"),
        ),
        Positioned(
          top: 287.h,
          left: 90.w,
          right: 107.w,
          child: Image.asset("assets/images/ic_animal2.png"),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 258.h),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // 水平居中
                children: [
                  Image.asset("assets/images/ic_coin.png",width: 46.w,height: 46.h),
                  GameText(showText:GlobalConfigManager.instance.getCommonCoin(2),
                    fontSize: 25.sp,
                    fillColor: Color(0xFFFFEF50),)
                ]),
          ),
        ),
        Positioned(
          top: 518.h,
          left: 13.w,
          right: 65.h,
          child: Container(
            height: 40.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft, // 90° 从上到下
                end: Alignment.centerRight,
                colors: [
                  Color(0x00C485FF), // startColor
                  Color(0xFF9763FF), // middleColor
                  Color(0x00D7C2FF), // endColor
                ],
              ),
            ),
            child: Center(
              child: Text(
                'app_pop_1_2_tips1'.tr(),
                style: TextStyle(color: Color(0xFFF0E261), fontSize: 16.sp,fontFamily: "AHV",fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
        Positioned(
          top: 582.h,
          left: 77.w,
          right: 0.h,
          child: Container(
            height: 40.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft, // 90° 从上到下
                end: Alignment.centerRight,
                colors: [
                  Color(0x00C485FF), // startColor
                  Color(0xFF9763FF), // middleColor
                  Color(0x00D7C2FF), // endColor
                ],
              ),
            ),
            child: Center(
              child: Text(
                'app_pop_1_2_tips2'.tr(),
                style: TextStyle(color: Color(0xFFF0E261), fontSize: 16.sp,fontFamily: "AHV",fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
