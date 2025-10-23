import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/EventConfig.dart';
import '../../utils/ClickManager.dart';
import '../../utils/net/EventManager.dart';

class NetErrorPop extends StatefulWidget {
  const NetErrorPop({super.key});

  @override
  State<NetErrorPop> createState() => _NetErrorPopState();
}

class _NetErrorPopState extends State<NetErrorPop> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 311.w,
      height: 296.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE1EFF7),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Stack(
        children: [
          /// 顶部标题
          Padding(
            padding: EdgeInsets.only(left: 21.w, right: 21.w, top: 17.h),
            child: Text(
              "app_nf_net_error_title".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1,
                fontSize: 17.sp,
                fontFamily: "AHV",
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F0F0F),
              ),
            ),
          ),
          Positioned(
            left: 42.w,
            right: 42.w,
            top: 9.h,
            child: Image.asset(
              "assets/images/ic_net_error.webp",
              width: 227.w,
              height: 227.h,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 7.w,
            top: 7.h,
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
                ClickManager.clickAudio();
                Navigator.pop(context, 0);
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsetsGeometry.only(bottom: 18.h),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Container(
                  width: 179.w,
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F6CFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      "app_ad_try_again".tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: "AHV",
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  ClickManager.clickAudio();
                  Navigator.pop(context, 1);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
