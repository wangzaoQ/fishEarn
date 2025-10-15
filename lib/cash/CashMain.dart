import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/cash/CashItemView.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/GameData.dart';
import '../utils/LocalCacheUtils.dart';

class CashMain extends StatefulWidget {
  const CashMain({super.key});

  @override
  State<CashMain> createState() => _CashMainState();
}

class _CashMainState extends State<CashMain> {
  late GameData gameData;

  @override
  void initState() {
    super.initState();
    gameData = LocalCacheUtils.getGameData();
  }

  // 0 paypal 1 cash
  var payType = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //金币
          Image.asset(
            "assets/images/bg_cash.webp",
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 54.h,
            left: 24.w,
            child: Container(
              padding: EdgeInsets.fromLTRB(28.w, 2.h, 14, 2.h),
              height: 25.h,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg_to_bar_coin.webp"),
                  fit: BoxFit.fill,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                GameManager.instance.getCoinShow(gameData.coin),
                style: TextStyle(
                  color: const Color(0xFFF4FF72),
                  fontSize: 15.sp,
                  fontFamily: "AHV",
                ),
              ),
            ),
          ),
          Positioned(
            left: 8.w,
            top: 43.h,
            child: Image.asset(
              "assets/images/ic_coin4.webp",
              width: 45.w,
              height: 45.h,
              fit: BoxFit.cover,
            ),
          ),
          //珍珠
          Positioned(
            top: 54.h,
            left: 166.w,
            child: SizedBox(
              width: 65.w,
              height: 25.h,
              child: Stack(
                children: [
                  Image.asset(
                    "assets/images/bg_to_bar_coin.webp",
                    height: 25.h,
                    fit: BoxFit.fill,
                  ),
                  Center(
                    child: Text(
                      "${gameData.pearlCount}",
                      style: TextStyle(
                        color: const Color(0xFFF4FF72),
                        fontSize: 15.sp,
                        fontFamily: "AHV",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 150.w,
            top: 50.h,
            child: Image.asset(
              "assets/images/ic_pearl2.webp",
              width: 32.w,
              height: 32.h,
              fit: BoxFit.cover,
            ),
          ),
          //Home
          Positioned(
            top: 44.h,
            right: 14.w,
            child: SizedBox(
              width: 48.w,
              height: 48.h,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                pressedOpacity: 0.7,
                child: Image.asset(
                  "assets/images/ic_to_home.webp",
                  width: 48.w,
                  height: 48.h,
                  fit: BoxFit.cover,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Positioned(
            left: 15.w,
            right: 15.w,
            top: 113.h,
            child: SizedBox(
              width: double.infinity,
              height: 125.h,
              child: Stack(
                children: [
                  Image.asset(
                    "assets/images/bg_cash_top.webp",
                    width: 345.w,
                    height: 125.h,
                    fit: BoxFit.fill,
                  ),
                  Positioned(
                    left: 14.w,
                    top: 14.h,
                    child: GameText(
                      showText: "${"app_balance".tr()}:",
                      strokeColor: Colors.black,
                      strokeWidth: 0.7.h,
                      fontSize: 18.sp,
                    ),
                  ),
                  Center(
                    child: GameText(
                      showText:
                          "\$ ${GameManager.instance.getCoinShow(gameData.coin)}",
                      strokeWidth: 1.5.h,
                      strokeColor: Colors.black,
                      fontSize: 29.sp,
                      fillColor: Color(0xFF33FFDB),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 208.w,
            bottom: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                Image.asset(
                  "assets/images/bg_cash_bottom.webp",
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fill,
                ),
                Positioned(
                  left: 14.w,
                  top: 8.h,
                  child: Text(
                    "app_withdrawal".tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontFamily: "AHV",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  left: 15.w,
                  right: 15.w,
                  top: 37.h,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: Stack(
                      children: [
                        Image.asset(
                          payType == 0
                              ? "assets/images/bg_cash_channel1.webp"
                              : "assets/images/bg_cash_channel2.webp",
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Positioned(
                          left: 20.w,
                          top: 0,
                          child: CupertinoButton(
                            child: Image.asset(
                              "assets/images/ic_paypal.webp",
                              width: 78.w,
                              height: 22.h,
                            ),
                            onPressed: () {
                              setState(() {
                                payType = 0;
                              });
                            },
                          ),
                        ),
                        Positioned(
                          right: 20.w,
                          top: 2.h,
                          child: CupertinoButton(
                            child: Image.asset(
                              "assets/images/ic_cash.webp",
                              width: 96.w,
                              height: 21.h,
                            ),
                            onPressed: () {
                              setState(() {
                                payType = 1;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //提现列表
                Positioned(
                  top: 106.h,
                  left: 12.w,
                  right: 12.w,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
                          children: [
                            CashItemView(gameData:gameData,payType:payType,money:500,payStatus: 0,),
                            SizedBox(height: 4.h,),
                            CashItemView(gameData:gameData,payType:payType,money:500,payStatus: 1),
                            SizedBox(height: 4.h,),
                            CashItemView(gameData:gameData,payType:payType,money:500,payStatus: 2)
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
