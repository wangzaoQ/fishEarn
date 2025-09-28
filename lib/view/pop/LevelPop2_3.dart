import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/utils/GlobalConfigManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/AudioUtils.dart';
import '../GameText.dart';

class LevelPop2_3 extends StatefulWidget {
  const LevelPop2_3({super.key});

  @override
  State<LevelPop2_3> createState() => _LevelPop2_3State();
}

class _LevelPop2_3State extends State<LevelPop2_3> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 90.w,
          right: 90.w,
          top: 119.h,
          child: Image.asset(
            "assets/images/ic_level2_3.webp",
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
          child: Image.asset("assets/images/ic_pop_level3.webp"),
        ),
        // Positioned(child: SizedBox(
        //   width: double.infinity,
        //   height: 46.h,
        // ))
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 258.h),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // 水平居中
                children: [
              Image.asset("assets/images/ic_coin.png",width: 46.w,height: 46.h),
              GameText(showText:GlobalConfigManager.instance.getCommonCoin(),
                fontSize: 25.sp,
                fillColor: Color(0xFFFFEF50),)
            ]),
          ),
        ),
        Positioned(
          top: 523.h,
          left: 39.w,
          right: 39.h,
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
