import 'package:fish_earn/task/RewardManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BubbleWidget extends StatefulWidget {
  // 0 金币 1 食物 2 珍珠
  var type;
  BubbleWidget({super.key,required this.type});

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
            widget.type == 0?
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "${RewardManager.instance.findReward(RewardManager.instance.rewardData?.cashBubble?.prize, LocalCacheUtils.getGameData().coin)}",
                style: TextStyle(
                  fontSize: 15.sp,
                  color: const Color(0xFFF4FF72),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ):SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  String getImg(type) {
    if(type == 0){
      return "assets/images/ic_coin_bubbles.webp";
    }else if(type == 1){
      return "assets/images/ic_food_bubbles.webp";
    }else {
      return "assets/images/ic_pearl_bubbles.webp";
    }
  }
}
