import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/cash/CashPage.dart';
import 'package:fish_earn/config/EventConfig.dart';
import 'package:fish_earn/config/GameConfig.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/config/global.dart';
import 'package:fish_earn/data/GameData.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:fish_earn/view/pop/TaskPop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/ClickManager.dart';
import '../utils/net/EventManager.dart';
import '../view/PropsProgress.dart';
import '../view/pop/BasePopView.dart';
import '../view/pop/CashErrorPop.dart';
import '../view/pop/CashProcessPop.dart';
import '../view/pop/CashSuccessPop.dart';
import '../view/pop/PopManger.dart';
import 'TaskProcess.dart';

class CashItemView extends StatefulWidget {
  GameData gameData;

  int payType;

  int money;
  int payStatus;

  CashItemView({
    super.key,
    required this.gameData,
    //0 paypal 1 cash
    required this.payType,
    required this.money,
    //1 500 2 800 3 1000
    required this.payStatus,
  });

  @override
  State<CashItemView> createState() => _CashWidgetState();
}

class _CashWidgetState extends State<CashItemView> {
  // 0 默认 1 提现任务中 2 提现正在排队 3 提现排队完成
  var cashType = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cacheKeyCash = LocalCacheUtils.getInt(
      LocalCacheConfig.cacheKeyCash,
      defaultValue: -1,
    );
    var cashRankType = LocalCacheUtils.getInt(
      LocalCacheConfig.cashRankType,
      defaultValue: -1,
    );
    List<String> cashRankCompleteList = LocalCacheUtils.getStringList(
      LocalCacheConfig.cashRankCompleteList,
    );
    if (cacheKeyCash == widget.payStatus) {
      //提现任务中
      cashType = 1;
    }
    if (cashRankType == widget.payStatus) {
      //正在提现
      cashType = 2;
    }
    if(cashRankCompleteList.contains("${widget.payStatus}")){
      cashType = 3;
    }
    if(cashType == 0){
      return Stack(
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
                onPressed: () async {
                  if (!ClickManager.canClick(context: context)) return;
                  var gameData = LocalCacheUtils.getGameData();
                  if (gameData.coin < widget.money) {
                    BasePopView().showScaleDialog(
                      context: context,
                      child: CashErrorPop(money: widget.money),
                    );
                    return;
                  }
                  var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CashPage(
                        payType: widget.payType,
                        payStatus: widget.payStatus,
                        isGuide: false,
                      ),
                    ),
                  );
                  if (result == 0) {
                    setState(() {
                      var gameData = LocalCacheUtils.getGameData();
                      gameData.coin -= widget.money;
                      LocalCacheUtils.putGameData(gameData);
                      eventBus.fire(EventConfig.refreshCoin);
                    });
                  }
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 79.h),
              child: PropsProgress(
                progress: (widget.gameData.coin) / (widget.money),
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
      );
    }
    else if(cashType == 1){
      return
        //提现
        SizedBox(child: CupertinoButton(
          padding: EdgeInsets.zero,
          pressedOpacity: 0.7,
          child: Stack(
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
            ],
          ),
          onPressed: () {
            PopManager().show(context: context, child: TaskPop());
          },
        ));
    }
    else if(cashType == 2){
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset("assets/images/bg_cash_item.webp",width: 352.w,height: 110.h,fit: BoxFit.fill,),
          Align(alignment: Alignment.topLeft,child: Padding(
            padding: EdgeInsets.only(left: 18.w, top: 30.h),
            child: GameText(
              showText:
              "\$${GameManager.instance.getCoinShow(widget.money.toDouble())}",
              strokeColor: Colors.black,
              strokeWidth: 1.5.h,
              fontSize: 23.sp,
            ),
          )),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 30.w, top: 10.h),
              child: SizedBox(
                width: 80.w,
                height: 80.h,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  pressedOpacity: 0.7,
                  child: Image.asset(
                    "assets/images/ic_toRank.webp",
                    width: 100.w,
                    height: 100.h,
                    fit: BoxFit.fill,
                  ),
                  onPressed: () async {
                    if (!ClickManager.canClick(context: context)) return;
                    EventManager.instance.postEvent(EventConfig.cash_queue);
                    //1 500 2 800 3 1000
                    var money = 500;
                    if (widget.payStatus == 1) {
                      money = 500;
                    } else if (widget.payStatus == 2) {
                      money = 800;
                    } else if (widget.payStatus == 3) {
                      money = 1000;
                    }
                    var result = await PopManager().show(
                      context: context,
                      child: CashProcessPop(money: money),
                    );
                    if (result == 0) {
                      LocalCacheUtils.putInt(
                        LocalCacheConfig.cashRankType, -1,
                      );
                      final list = List<String>.from(
                        LocalCacheUtils.getStringList(LocalCacheConfig.cashRankCompleteList),
                      );

                      list.add("${widget.payStatus}");
                      LocalCacheUtils.putStringList(LocalCacheConfig.cashRankCompleteList, list);
                      PopManager().show(
                        context: context,
                        child: CashSuccessPop(),
                      );
                      LocalCacheUtils.putString(
                        LocalCacheConfig.taskCurrentKey,
                        "",
                      );
                      setState(() {});
                    }
                  },
                ),
              ),
            ),
          ),
          Positioned(
            left: 15.w,
            bottom: 20.h,
            child: Text(
              "app_cash_rank_content".tr(),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
          ),
        ],
      );
    }else if(cashType == 3){
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset("assets/images/bg_cash_item.webp",width: 352.w,height: 110.h,fit: BoxFit.fill,),
          Align(alignment: Alignment.topLeft,child: Padding(
            padding: EdgeInsets.only(left: 18.w, top: 30.h),
            child: GameText(
              showText:
              "\$${GameManager.instance.getCoinShow(widget.money.toDouble())}",
              strokeColor: Colors.black,
              strokeWidth: 1.5.h,
              fontSize: 23.sp,
            ),
          )),
          Positioned(
            left: 15.w,
            bottom: 15.h,
            child: Text(
              "app_cash_rank_complete".tr(),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                height: 1, // 👈 调整行间距 (1.0~1.5 比较常用)
              ),
            ),
          ),
        ],
      );
    }
    return SizedBox.shrink();
  }
}
