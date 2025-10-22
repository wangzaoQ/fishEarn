import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/EventConfig.dart';
import 'package:fish_earn/config/GameConfig.dart';
import 'package:fish_earn/utils/AudioUtils.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/ClickManager.dart';
import '../../utils/ad/ADEnum.dart';
import '../../utils/ad/ADShowManager.dart';
import '../../utils/net/EventManager.dart';

class GameAwardPop extends StatefulWidget {

  // 0 金钱 1 食物
  final int type;
  final double money;

  const GameAwardPop({
    super.key,
    required this.type,
    this.money = 0.0,
  });
  @override
  State<GameAwardPop> createState() => _GameAwardPopState();
}

class _GameAwardPopState extends State<GameAwardPop>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // 一圈时间
    )..repeat(); // 无限旋转
    AudioUtils().playTempAudio("audio/award.mp3");
    if(widget.type == 0){
      EventManager.instance.postEvent(EventConfig.pearl_wheel_pop);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  var allowClickAd = true;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 禁止默认返回
      onPopInvokedWithResult: (didPop, result) {
        toBack();
      },
      child: Stack(
        children: [
          Positioned(
            left: 23.w,
            right: 23.w,
            top: 180.h,
            child: Image.asset(
              "assets/images/bg_award.webp",
              width: double.infinity,
              height: 417.h,
            ),
          ),
          Positioned(
            top: 333.h,
            left: 95.w,
            right: 95.w,
            child: SizedBox(
              width: 183.w,
              height: 183.h,
              child: RotationTransition(
                turns: _controller,
                child: Image.asset(
                  "assets/images/bg_game_progress.webp",
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsetsGeometry.only(top: 369.h),
              child: SizedBox(
                width: 110.w,
                height: 110.h,
                child: Image.asset(
                  widget.type == 0?"assets/images/ic_coin_reward.webp":
                  "assets/images/ic_food_award.webp",
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsetsGeometry.only(bottom: 285.h),
              child:  GameText(
                showText: widget.type == 0?"+\$${widget.money}":"+30",
                fontSize: 28.sp,
                fillColor: Color(0xFFFDFF59),
                strokeColor: Color(0xFF9B4801),
                strokeWidth: 1.w,
              ),
            ),
          ),
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
                        widget.type == 0?"${"app_claim".tr()} \$${widget.money*2}":"app_free".tr(),
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
                if(widget.type == 1){
                  toBack();
                }else{
                  if(!allowClickAd)return;
                  allowClickAd = false;
                  EventManager.instance.postEvent(EventConfig.pearl_wheel_2x);
                  ADShowManager(
                    adEnum: ADEnum.rewardedAD,
                    tag: "reward",
                    result: (type, hasValue) {
                      if (hasValue) {
                        Navigator.pop(context, 2);
                      }
                      allowClickAd = true;
                    },
                  ).showScreenAD(EventConfig.fixrn_wheel_rv, awaitLoading: true);

                }
              },
            ),
          ),
          widget.type == 0?Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsetsGeometry.only(bottom: 100.h),
              child: CupertinoButton(
                onPressed: () {
                  if (!ClickManager.canClick(context: context)) return;
                  toBack();
                },
                child: Text(
                  "${"app_only".tr()} +\$${widget.money}",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Color(0xFFBFC3C7),
                    decoration: TextDecoration.underline,
                    // ✅ 下划线
                    decorationColor: Color(0xBFFFFFFF),
                    // 可选：自定义下划线颜色
                    decorationThickness: 1.h,
                  ),
                ),
              ),
            ),
          ):SizedBox.shrink(),
          widget.type == 0?Positioned(
            right: 100.w,
            top: 597.h,
            child: Image.asset(
              "assets/images/ic_ad_tips.webp",
              width: 36.w,
              height: 36.h,
            ),
          ):SizedBox.shrink(),
          Align(alignment: Alignment.topCenter,child: Padding(padding: EdgeInsetsGeometry.only(top: 314.h),child: GameText(
            showText: "app_wave_treasure".tr(),
            fontSize: 19.sp,
            fillColor: Color(0xFFFFD828),
            strokeColor: Color(0xFFFC5B88),
            strokeWidth: 1.w,
          ),),),
          Positioned(
            right: 20.w,
            top: 168.h,
            child: CupertinoButton(
              child: Image.asset(
                "assets/images/ic_pop_close.webp",
                width: 32.w,
                height: 32.h,
              ),
              onPressed: () {
                if (!ClickManager.canClick(context: context)) return;
                toBack();
              },
            ),
          ),
        ],
      ),
    );
  }


  var back = true;
  void toBack() {
    if(!back)return;
    back = false;
    ADShowManager(
      adEnum: ADEnum.intAD,
      tag: "int",
      result: (type, hasValue) {
        if(!mounted)return;
        EventManager.instance.postEvent(EventConfig.pearl_wheel_1x);
        Navigator.pop(context, 1);
      },
    ).showScreenAD(EventConfig.fixrn_wheel_int);
  }
}
