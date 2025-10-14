import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/data/GameData.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../view/PropsProgress.dart';
import 'TaskProcess.dart';

class CashWidget extends StatefulWidget {
  GameData gameData;

  int payType;

  int money;
  int payStatus;

  CashWidget({
    super.key,
    required this.gameData,
    //0 paypal 1 cash
    required this.payType,
    required this.money,
    //1 500 2 800 3 1000
    required this.payStatus,
  });

  @override
  State<CashWidget> createState() => _CashWidgetState();
}

class _CashWidgetState extends State<CashWidget> {
  var isCash = false;

  @override
  void initState() {
    var cacheKeyCash = LocalCacheUtils.getInt(
      LocalCacheConfig.cacheKeyCash,
      defaultValue: -1,
    );
    if (cacheKeyCash == widget.payType) {
      //正在提现
      isCash = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !isCash
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Container(
                  height: 110.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/bg_cash_item.webp"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 18.w, top: 42.h),
                    child: GameText(
                      showText:
                          "\$${GameManager.instance.getCoinShow(widget.money.toDouble())}",
                      strokeColor: Colors.black,
                      strokeWidth: 1.5.h,
                      fontSize: 23.sp,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 18.w),
                  child: Stack(
                    alignment: Alignment.center, // 让子元素默认居中
                    children: [
                      Image.asset(
                        "assets/images/ic_cash_tips.webp",
                        width: 101.w,
                        height: 38.h,
                        fit: BoxFit.fill,
                      ),
                      AutoSizeText(
                        "app_cash_out".tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 20.h, 15.w, 0),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    pressedOpacity: 0.7,
                    child: Stack(
                      alignment: Alignment.center, // 让子元素默认居中
                      children: [
                        Image.asset(
                          "assets/images/bg_confirm.webp",
                          width: 121.w,
                          height: 42.h,
                          fit: BoxFit.fill,
                        ),
                        AutoSizeText(
                          "app_withdraw".tr(),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF185F11),
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 79.h),
                  child: PropsProgress(
                    progress: 0.5,
                    // 进度 0~1
                    progressColor: Color(0xFF5ABB33),
                    backgroundColor: Color(0xFF126175),
                    width: 306.w,
                    height: 14.h,
                    padding: 0,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 69.h, 15.w, 0),
                  child: Image.asset(
                    "assets/images/ic_coin2.webp",
                    width: 35.w,
                    height: 35.h,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          )
        :
          //提现
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Container(
                  height: 136.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/bg_cash_item.webp"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 18.w, top: 42.h),
                    child: GameText(
                      showText:
                          "\$${GameManager.instance.getCoinShow(widget.money.toDouble())}",
                      strokeColor: Colors.black,
                      strokeWidth: 1.5.h,
                      fontSize: 23.sp,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 18.w),
                  child: Stack(
                    alignment: Alignment.center, // 让子元素默认居中
                    children: [
                      Image.asset(
                        "assets/images/ic_cash_tips.webp",
                        width: 101.w,
                        height: 38.h,
                        fit: BoxFit.fill,
                      ),
                      AutoSizeText(
                        "app_process".tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 79.h),
                  child: TaskProcess(),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 72.h, 17.w, 0),
                  child: Image.asset(
                    "assets/images/ic_award_selected.webp",
                    width: 24.w,
                    height: 24.h,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          );
  }
}
