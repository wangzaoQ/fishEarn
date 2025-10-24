import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/task/CashManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/EventConfig.dart';
import '../../data/QueueUser.dart';
import '../../utils/ClickManager.dart';
import '../../utils/ad/ADEnum.dart';
import '../../utils/ad/ADShowManager.dart';
import '../../utils/net/EventManager.dart';

class CashProcessPop extends StatefulWidget {
  int money;

  CashProcessPop({super.key, required this.money});

  @override
  State<CashProcessPop> createState() => _CashProcessPopState();
}

class _CashProcessPopState extends State<CashProcessPop> {
  @override
  void initState() {
    super.initState();
    EventManager.instance.postEvent(EventConfig.cash_queue_pop);
    _initAsync();
  }

  List<QueueUser>? userList;
  QueueUser? currentUser;

  Future<void> _initAsync() async {
    updateUser(false);
    // 更新状态
    if (mounted) {
      setState(() {
        // 更新UI
      });
    }
  }

  void updateUser(bool needRefresh) {
    userList = CashManager.instance.generateQueue(needRefresh);
    if (userList != null) {
      for (int i = 0; i < userList!.length; i++) {
        if (userList![i].isCurrentUser) {
          currentUser = userList![i];
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 原始多语言文本模板
    var currentIndex = 0;
    var allIndex = 0;
    String currentCount = "";
    String allCount = "";
    String display = "";
    if (currentUser != null) {
      String raw = "app_cash_queue_tips".tr();
      // 替换后的数字
      currentCount = currentUser!.rank;
      allCount = "500";
      // 拼接最终显示文本（只用于分割）
      display = raw
          .replaceAll("{currentCount}", currentCount)
          .replaceAll("{allCount}", allCount);
      // 计算位置，分割出三段
      currentIndex = display.indexOf(currentCount);
      allIndex = display.indexOf(allCount);
    }
    return Center(
      child: Container(
        width: 308.w,
        height: 521.h,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsetsGeometry.only(top: 22.h),
                child: Text(
                  "app_withdraw_approval".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontFamily: "AHV",
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: 10.h, right: 11.w),
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
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsetsGeometry.only(top: 60.h),
                child: Container(
                  width: 156.w,
                  height: 86.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF22810E), // 边框颜色
                      width: 3.h, // 边框宽度
                    ),
                    borderRadius: BorderRadius.circular(12), // 可选：圆角
                    color: const Color(0xFFFCF8DD),
                  ),
                  child: SizedBox(
                    width: 156.w,
                    height: 86.h,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsetsGeometry.only(top: 10.h),
                            child: Image.asset(
                              "assets/images/ic_paypal3.webp",
                              width: 80.w,
                              height: 30.h,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsetsGeometry.only(bottom: 8.h),
                            child: Text(
                              "${widget.money}",
                              style: TextStyle(
                                fontSize: 23.sp,
                                fontFamily: "AHV",
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 66.w,
              top: 53.h,
              child: Image.asset(
                "assets/images/ic_award_selected.webp",
                width: 28.w,
                height: 28.h,
                fit: BoxFit.fill,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsetsGeometry.fromLTRB(19.w, 161.h, 19.w, 0),
                child: Text(
                  "app_cash_queue".tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: "AHV",
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsetsGeometry.fromLTRB(19.w, 209.h, 19.w, 0),
                child: currentUser == null
                    ? SizedBox.shrink()
                    : RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            // currentCount 红色
                            TextSpan(
                              text: allCount,
                              style: const TextStyle(color: Color(0xFFFF1E00)),
                            ),

                            // 中间段（从 currentCount 后到 allCount 前）
                            TextSpan(
                              text: display.substring(
                                allIndex + allCount.length,
                                currentIndex,
                              ),
                            ),

                            // allCount 红色
                            TextSpan(
                              text: currentCount,
                              style: const TextStyle(color: Color(0xFFFF1E00)),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            //列表
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsetsGeometry.only(bottom: 76.h),
                child: Container(
                  width: 267.w,
                  height: 209.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1EFF7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // ✅ 不让 Column 撑满
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 0.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildCell('User ID', 89.w, isHeader: true),
                            _buildCell('Account', 89.w, isHeader: true),
                            _buildCell('Amount', 89.w, isHeader: true),
                          ],
                        ),
                      ),
                      // List rows
                      userList == null
                          ? SizedBox.shrink()
                          : Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero, // ✅ 去掉默认 padding
                                itemCount: userList!.length,
                                itemBuilder: (context, index) {
                                  final row = userList![index];
                                  return Container(
                                    color: index.isEven
                                        ? const Color(0xFFC0D7E5)
                                        : const Color(0xFFE1EFF7),
                                    child: Row(
                                      children: [
                                        _buildCell(
                                          row.rank,
                                          89.w,
                                          isCurrent: row.isCurrentUser,
                                        ),
                                        _buildCell(
                                          row.account,
                                          89.w,
                                          isCurrent: row.isCurrentUser,
                                        ),
                                        _buildCell(
                                          "\$${row.amount}",
                                          89.w,
                                          isCurrent: row.isCurrentUser,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsetsGeometry.only(bottom: 15.h),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  pressedOpacity: 0.7,
                  child: Container(
                    width: 179.w,
                    height: 45.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4283EC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        "app_skip_wait".tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: "AHV",
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (!ClickManager.canClick(context: context)) return;
                    ADShowManager(
                      adEnum: ADEnum.rewardedAD,
                      tag: "reward",
                      result: (type, hasValue) {
                        if (hasValue) {
                          EventManager.instance.postEvent(EventConfig.queue_skipwait);
                          setState(() {
                            updateUser(true);
                          });
                        }
                      },
                    ).showScreenAD(EventConfig.fixrn_skipwait_rv, awaitLoading: true);
                  },
                ),
              ),
            ),
            Positioned(
              right: 52.w,
              bottom: 40.h,
              child: Image.asset(
                "assets/images/ic_ad_tips.webp",
                width: 36.w,
                height: 36.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(
    String text,
    double width, {
    bool isHeader = false,
    bool isCurrent = false,
  }) {
    return Container(
      width: width,
      height: isHeader ? 34.h : 24.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 0.h),
      child: AutoSizeText(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isHeader ? 12.sp : 13.sp,
          color: isCurrent ? const Color(0xFFFF1E00) : const Color(0xFF000000),
        ),
        minFontSize: 8, // ✅ 整数
        stepGranularity: 1, // ✅ 与 minFontSize 整除
        maxLines: 1,
      ),
    );
  }
}
