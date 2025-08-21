import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../view/GameLifeProgress.dart';
import '../view/GameText.dart';
import '../view/TopDownCover.dart';

class GameLifePage extends StatefulWidget {
  const GameLifePage({super.key});

  @override
  State<GameLifePage> createState() => _GameLifePageState();
}

class _GameLifePageState extends State<GameLifePage>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..forward(); // 从0开始遮到1
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: 100.w,
      height: 130.h, // 给 Stack 一个固定高度
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(padding: EdgeInsetsGeometry.only(left: 12.w),child: GameText(
              showText: "app_satiety".tr(),
              fontSize: 14.sp,
              fillColor: Color(0xFFFFDD48),
              strokeColor: Color(0xFF000000),
            )),)
          ,
          Positioned(
            top: 36.h,
            left: 0.w,
            bottom: 0, // 让 Positioned 填满 Stack 高度
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GameText(showText: "100%", fontSize: 8.sp, fillColor: Colors.white, strokeColor: Colors.black, strokeWidth: 1.w),
                GameText(showText: "75%", fontSize: 8.sp, fillColor: Colors.white, strokeColor: Colors.black, strokeWidth: 1.w),
                GameText(showText: "55%", fontSize: 8.sp, fillColor: Colors.white, strokeColor: Colors.black, strokeWidth: 1.w),
                GameText(showText: "45%", fontSize: 8.sp, fillColor: Colors.white, strokeColor: Colors.black, strokeWidth: 1.w),
                GameText(showText: "35%", fontSize: 8.sp, fillColor: Colors.white, strokeColor: Colors.black, strokeWidth: 1.w),
                GameText(showText: "15%", fontSize: 8.sp, fillColor: Colors.white, strokeColor: Colors.black, strokeWidth: 1.w),
              ],
            ),
          ),
          // Positioned(
          //   top: 26,
          //   left: 59.w,
          //   child: CustomProgress3(progress: 0.5,),
          // ),
        ],
      ),
    );
  }
}
