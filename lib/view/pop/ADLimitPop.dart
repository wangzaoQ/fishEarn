import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/ClickManager.dart';
import '../GameText.dart';

class ADLimitPop extends StatefulWidget {
  const ADLimitPop({super.key});

  @override
  State<ADLimitPop> createState() => _ADLimitPopState();
}

class _ADLimitPopState extends State<ADLimitPop> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 23.w,
          right: 23.w,
          top: 180.h,
          child: Image.asset(
            "assets/images/bg_award.webp",
            width: double.infinity,
            height: 385.h,
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 245.h),
            child: SizedBox(
              width: 180.w,
              height: 22.h,
              child: Image.asset(
                "assets/images/ic_ad_limit_title.webp",
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 326.h),
            child: SizedBox(
              width: 110.w,
              height: 110.h,
              child: Image.asset(
                "assets/images/ic_ad_limit.webp",
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        Positioned(
            left: 59.w,
            right: 59.w,
            top: 454.h,
            child: GameText(
              showText: "app_ad_limit_content".tr(),
              fontSize: 15.sp,
              fillColor: Color(0xFFFFFFFF),
              strokeColor: Color(0xFF3B3A24),
              strokeWidth: 1.w,
            )),
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
                      "app_ok".tr()
                      ,
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
              if (!ClickManager.canClick(context: context)) return;
              Navigator.pop(context);
            },
          ),
        )]);
  }
}
