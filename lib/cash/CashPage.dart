import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fish_earn/utils/GlobalDataManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/utils/RiskUserManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/LocalCacheConfig.dart';
import '../utils/GameManager.dart';

class CashPage extends StatefulWidget {
  var payType = 0;
  var payStatus = 0;
  var isGuide = false;

  CashPage({super.key, required this.payType, required this.payStatus,required this.isGuide});

  @override
  State<CashPage> createState() => _CashPage2State();
}

class _CashPage2State extends State<CashPage> {
  var defaultEmail = "e.g. 12345678@ABC.COM";
  var defaultPhoneUS = "e.g. 5551234567";


  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  var deviceId = "";

  Future<void> _initAsync() async {
    deviceId = await GlobalDataManager.instance.getDeviceId();
    setState(() {
      // 更新 UI
    });
    var userData = LocalCacheUtils.getUserData();
    if((!userData.userRiskStatus || (userData.userRiskStatus && userData.userRiskType == 1))){
      await RiskUserManager.instance.judgeWrongDeemAdLess(userData);
    }
  }

  var eventParamsList = <String>[];

  @override
  Widget build(BuildContext context) {
    String tips = tr("app_cash_tips", namedArgs: {"from": widget.payType == 0?"PayPal":"Cash APP"});

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(widget.payType == 0?0xFF2F5FC5:0xFF44B04C), // #012169 的十六进制写法
        ),
        child: Stack(
          children: [
            Positioned(
              left: 6.w,
              right: 6.w,
              // ✅ 代替 double.infinity
              top: 50.h,
              height: 42.h,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      pressedOpacity: 0.7,
                      child: Padding(
                        padding: EdgeInsets.all(9.w),
                        child: Icon(
                          Icons.arrow_back,
                          size: 20.sp,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, -1);
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(getCashLogo(), height: 30.h,),
                  ),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     padding: EdgeInsets.fromLTRB(3.w, 5.h, 3.w, 5.h),
                  //     child: Text(
                  //       "ID:$deviceId",
                  //       style: TextStyle(
                  //         fontSize: 12.sp,
                  //         fontFamily: "AHV",
                  //         color: Color(0xFF080E1B),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),

            Positioned(
              left: 27.w,
              top: 96.h,
              child: Image.asset(
                "assets/images/ic_safe.webp", width: 96.w, height: 119.h,),
            ),
            Positioned(
              right: 21.w,
              top: 138.h,
              child: Text(
                "app_safe".tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontFamily: "AHV",
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 212.h,
              bottom: 0,
              // ✅ 让容器撑到底部
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(29),
                    topRight: Radius.circular(29),
                  ),
                ),
                child: Stack(
                  children: [
                    buildCardInput(),
                    Align(alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsetsGeometry.only(bottom: 101.h),child:
                      Text(
                        textAlign: TextAlign.center,
                        tips,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontFamily: "AHV",
                          color: Color(0xFF9A999E),
                        ),
                      ),),),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsetsGeometry.only(bottom: 32.h),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero, // 去掉默认内边距
                          pressedOpacity: 0.7,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(getCashButtonColor()),
                              // #012169 的十六进制写法
                              borderRadius: BorderRadius.circular(14), // 圆角 5dp
                            ),
                            child: SizedBox(
                              width: 344.w,
                              height: 54.h,
                              child: Center(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  "app_confirm".tr(),
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontFamily: "AHV",
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            if ((widget.payType == 0) &&
                                _payPalController != null) {
                              var accountText = _payPalController!.text.trim();
                              if (accountText.isEmpty) {
                                GameManager.instance.showTips(
                                    "app_cash_info_error".tr());
                                return;
                              } else {
                                if (!EmailValidator.validate(accountText)) {
                                  _payPalController!.text = "";
                                  GameManager.instance.showTips(
                                      "app_cash_info_error".tr());
                                  return;
                                }
                              }
                              eventParamsList.add("account");
                              LocalCacheUtils.putString(LocalCacheConfig.cashName,accountText);
                            } else if (widget.payType == 1 &&
                                _cashController != null) {
                              var phoneText = _cashController!.text.trim();
                              if (phoneText.isEmpty) {
                                GameManager.instance.showTips(
                                    "app_cash_info_error".tr());
                                return;
                              } else {
                                if (phoneText.length != 10) {
                                  _cashController!.text = "";
                                  GameManager.instance.showTips(
                                      "app_cash_info_error".tr());
                                  return;
                                }
                              }
                              eventParamsList.add("phone");
                              LocalCacheUtils.putString(LocalCacheConfig.cashName,phoneText);
                            }
                            LocalCacheUtils.putInt(LocalCacheConfig.cacheKeyCash, widget.payStatus,);
                            LocalCacheUtils.putInt(LocalCacheConfig.cashMoneyType, widget.payStatus,);
                            LocalCacheUtils.putString(LocalCacheConfig.taskCurrentKey,"task1");
                            LocalCacheUtils.putBool(LocalCacheConfig.isCashed,true);
                            LocalCacheUtils.putBool(LocalCacheConfig.firstAddTask,true);
                            Navigator.pop(context, 0);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }

  TextEditingController? _payPalController;
  TextEditingController? _cashController;

  Widget buildCardInput() {
    var widgets = <Widget>[];
    //0 payPal  1 cash
    if (widget.payType == 0) {
      _payPalController = TextEditingController();
    } else if (widget.payType == 1) {
      _cashController = TextEditingController();
    }

    widgets.add(
      Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsetsGeometry.only(top: 0.h),
          child: SizedBox(
            width: 324.w,
            height: 84.h,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(17.w, 17.h, 0, 0),
                    child: Text(
                      widget.payType == 0 ? "app_account".tr() : "app_phone"
                          .tr(),
                      style: TextStyle(
                          fontSize: 17.sp,
                          fontFamily: "AHV",
                          color: Color(0xFF020202),
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 37.h,
                  child: SizedBox(
                    height: 54.h, // 给足够高度
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(left: 17.w, right: 17.w),
                        child: SizedBox(
                          height: 50.h,
                          width: 200.w, // 给TextField一个宽度限制，方便观察
                          child: TextField(
                            textAlignVertical: TextAlignVertical.center, // 垂直居中
                            controller: getControl(),
                            decoration: InputDecoration(
                              // contentPadding: EdgeInsets.symmetric(
                              //   vertical: 12,
                              //   horizontal: 12,
                              // ),
                              focusedBorder: InputBorder.none, // 取消聚焦时的下划线
                              enabledBorder: InputBorder.none, // 取消默认下划线
                              hintText: getHint(),
                              hintStyle: TextStyle(
                                fontSize: 16.sp,
                                color: Color(0xFF9A999E),
                                fontFamily: "AHV",
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Color(0xFF020202),
                              fontFamily: "AHV",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),),

                /// ✅ 底部分割线
                Positioned(
                  left: 17.w,
                  right: 17.w,
                  bottom: 0,
                  child: Container(
                    height: 1.h,
                    color: const Color(0xFFF1F1F1), // 分割线颜色
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Stack(children: widgets);
  }


  String getCashLogo() {
    if (widget.payType == 0) {
      return "assets/images/ic_cash_paypal.webp";
    } else if (widget.payType == 1) {
      return "assets/images/ic_cash_cash.webp";
    }
    return "";
  }

  int getCashButtonColor() {
    if (widget.payType == 0) {
      return 0xFF1E54B4;
    } else if (widget.payType == 1) {
      return 0xFF44B04C;
    }
    return 0xFF44B04C;
  }

  @override
  void dispose() {
    _payPalController?.dispose(); // ✅ 释放资源
    super.dispose();
  }

  TextEditingController? getControl() {
    if (widget.payType == 0) {
      return _payPalController;
    } else if (widget.payType == 1) {
      return _cashController;
    } else {
      return _payPalController;
    }
  }

  String getHint() {
    if (widget.payType == 0) {
      return defaultEmail;
    } else if (widget.payType == 1) {
      return defaultPhoneUS;
    } else {
      return "";
    }
  }
}
