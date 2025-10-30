import 'package:fish_earn/task/RewardManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BubbleWidget extends StatefulWidget {
  // 0 金币 1 食物 2 珍珠 3 金币（无广告标识）
  var type;
  double? coin;
  BubbleWidget({super.key,required this.type,this.coin});

  @override
  State<BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<BubbleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true); // 往返抖动循环

    // 上下偏移范围：-8 ~ 8 像素
    _offsetAnim = Tween<double>(begin: -8.h, end: 8.h)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offsetAnim.value),
          child: child,
        );
      },
      child: SizedBox(
        width: 82.w,
        height: 82.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              getImg(widget.type),
              width: 82.w,
              height: 82.h,
            ),
            widget.type == 0 || widget.type == 3?
            Align(
              alignment: Alignment.bottomCenter,
              child: GameText(
                showText:  "\$${widget.coin}",
                fillColor: const Color(0xFFF4FF72),
                strokeColor: Colors.black,
                strokeWidth: 1.w,
                fontSize: 15.sp,
              ),
            ):SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  String getImg(type) {
    var userData = LocalCacheUtils.getUserData();
    if(type == 0 || type == 3){
      return (userData.new2 || type == 3)?"assets/images/ic_coin_bubbles2.webp":"assets/images/ic_coin_bubbles.webp";
    }else if(type == 1){
      return "assets/images/ic_food_bubbles.webp";
    }else {
      return "assets/images/ic_pearl_bubbles.webp";
    }
  }
}
