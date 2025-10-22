import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/EventConfig.dart';
import 'package:fish_earn/config/GameConfig.dart';
import 'package:fish_earn/utils/AudioUtils.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/ClickManager.dart';
import '../../utils/ad/ADEnum.dart';
import '../../utils/ad/ADShowManager.dart';
import '../../utils/net/EventManager.dart';

class WithdrawPop extends StatefulWidget {


  const WithdrawPop({
    super.key,
  });
  @override
  State<WithdrawPop> createState() => _WithdrawPopState();
}

class _WithdrawPopState extends State<WithdrawPop> {

  @override
  void initState() {
    super.initState();
    EventManager.instance.postEvent(EventConfig.meet_withdraw);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 286.w,
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
                      Navigator.pop(context, -1);
                    },
                  ),
                ),
              ),

              /// 顶部标题
              Padding(
                padding: EdgeInsets.only(left: 21.w, right: 21.w, top: 0.h),
                child: Text(
                  "app_limit_withdraw".tr(),
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
              Image.asset("assets/images/ic_cash_now.webp",width: 196.w,height:190.h,fit: BoxFit.fill,),
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
                      "app_right_now".tr(),
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
                  Navigator.pop(context,1);
                },
              ),

              SizedBox(height: 18.h),
            ],
          ),
        ],
      ),
    );
  }
}
