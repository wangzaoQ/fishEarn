import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class ArrowWidget extends StatefulWidget {
  @override
  _ArrowWidgetState createState() => _ArrowWidgetState();
}

class _ArrowWidgetState extends State<ArrowWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 250.h,
      right: 50.w,
      child: SizedBox(
        width: 100.w,
        height: 100.h,
        child: Lottie.asset(
          'assets/animations1/arrow.json',
          controller: _lottieController,
          onLoaded: (composition) {
            _lottieController.duration = composition.duration;
            _lottieController.repeat(); // 循环播放
          },
        ),
      ),
    );
  }
}
