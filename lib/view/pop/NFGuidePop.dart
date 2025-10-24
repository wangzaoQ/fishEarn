import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../config/EventConfig.dart';
import '../../utils/ClickManager.dart';
import '../../utils/LogUtils.dart';
import '../../utils/net/EventManager.dart';

class NFGuidePop extends StatefulWidget {
  const NFGuidePop({super.key});

  @override
  State<NFGuidePop> createState() => _GameAwardPopState();
}

class _GameAwardPopState extends State<NFGuidePop> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false, // 禁止默认返回
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            toBack();
          }
        },
        child:Container(
      width: 311.w,
      decoration: BoxDecoration(
        color: const Color(0xFFE1EFF7),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center, // ✅ 关键，让第一个元素贴顶
            children: [
              /// 关闭按钮（贴顶部右侧）
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 0.h, right: 7.w),
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
                      if (!ClickManager.canClick(context: context)) return;
                      toBack();
                    },
                  ),
                ),
              ),

              /// 顶部标题
              Padding(
                padding: EdgeInsets.only(left: 21.w, right: 21.w, top: 0.h),
                child: Text(
                  "app_nf_guide_title".tr(),
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
              SizedBox(height: 18.h),
              Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  "assets/images/ic_nf_guide.webp",
                  width: 101.w,
                  height: 139.h,
                ),
              ),
              SizedBox(height: 18.h),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 10.w),
                child: Text(
                  textAlign: TextAlign.center, // ✅ 每行水平居中
                  "app_nf_guide_content".tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: "AHV",
                    color: Color(0xFF666666),
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              /// 确认按钮
              CupertinoButton(
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
                      "app_nf_guide_ok".tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: "AHV",
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onPressed: () async {
                  if (!ClickManager.canClick(context: context)) return;
                  EventManager.instance.postEvent(EventConfig.noti_confirm_pop_c);
                  var status = await Permission.notification.status;
                  if (status.isDenied || status.isPermanentlyDenied) {
                    // 如果权限被拒绝或永久拒绝，则打开系统设置页面
                    bool opened = await openAppSettings();
                    LogUtils.logD("open nf setting: $opened");
                  } else if (status.isGranted) {
                    LogUtils.logD("nf allow");
                  }
                  Navigator.pop(context, 1);
                },
              ),

              SizedBox(height: 10.h),

              /// 取消
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Center(
                  child: SizedBox(
                    width: 100.w,
                    height: 20.h,
                    child: Text(
                      "app_nf_guide_cancel".tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: "AHV",
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  if (!ClickManager.canClick(context: context)) return;
                  toBack();
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ],
      ),
    ));
  }

  void toBack() {
    EventManager.instance.postEvent(EventConfig.noti_confirm_pop_close);
    Navigator.pop(context, 0);
  }
}
