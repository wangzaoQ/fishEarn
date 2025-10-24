import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

import '../../utils/AudioUtils.dart';

class CoinAnimalPop extends StatefulWidget {
  const CoinAnimalPop({super.key});

  @override
  State<CoinAnimalPop> createState() => _CoinAnimalPopState();
}

class _CoinAnimalPopState extends State<CoinAnimalPop> with TickerProviderStateMixin{
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    AudioUtils().playTempAudio("audio/money.mp3");
    _lottieController = AnimationController(vsync: this);

    // 监听播放状态
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context,null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Lottie.asset(
            'assets/animations1/coin.json',
            controller: _lottieController,
            onLoaded: (composition) {
              // 动画加载完后自动播放一次
              _lottieController
                ..duration = composition.duration
                ..forward();
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }
}
