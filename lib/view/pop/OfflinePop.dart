import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OfflinePop extends StatefulWidget {
  const OfflinePop({super.key});

  @override
  State<OfflinePop> createState() => _OfflinePopState();
}

class _OfflinePopState extends State<OfflinePop> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 240.h),
            child: Image.asset(
              "assets/images/ic_offline_title.webp",
              width: 254.w,
              height: 22.h,
              fit: BoxFit.fill,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 284.h),
            child: Text(
              "app_offline_title".tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontFamily: "AHV",
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 240.h),
            child: Image.asset(
              "assets/images/ic_offline_title.webp",
              width: 254.w,
              height: 22.h,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ],
    );
  }
}
