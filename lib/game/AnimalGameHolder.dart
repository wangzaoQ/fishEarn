import 'package:fish_earn/data/GameData.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/LogUtils.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/global.dart';
import '../utils/LocalCacheUtils.dart';
import '../view/_ScalingOverlay.dart';
import 'FishAnimGame.dart';
class AnimalGameHolder extends StatefulWidget {
  final int level;
  const AnimalGameHolder({super.key, required this.level});

  @override
  State<AnimalGameHolder> createState() => _AnimalGameHolderState();
}

class _AnimalGameHolderState extends State<AnimalGameHolder> {
  SimpleAnimGame? _game; // 允许替换

  @override
  void initState() {
    super.initState();
    _createGame(widget.level);
  }

  @override
  void didUpdateWidget(covariant AnimalGameHolder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level) {
      // 销毁旧的
      _game?.onRemove();
      // 重建
      _createGame(widget.level);
      // 通知刷新 GameWidget
      setState(() {});
    }
  }

  void _createGame(int level) {
    _game = SimpleAnimGame(level); // 传入关卡参数
    GameManager.instance.game = _game!;
  }

  @override
  void dispose() {
    _game?.onRemove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_game == null) return const SizedBox.shrink();

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(top: 0.h, bottom: 80.h),
        child: Container(
          color: Colors.transparent,
          child: GameWidget(
            game: _game!,
            overlayBuilderMap: {
              'fish_overlays': (BuildContext ctx, FlameGame gm) {
                return ValueListenableBuilder<Offset?>(
                  valueListenable: overlayNotifier,
                  builder: (context, offset, _) {
                    if (offset == null) return const SizedBox.shrink();
                    var overlayW = 230.w;
                    var overlayH = 230.h;
                    return Positioned(
                      left: offset.dx - overlayW / 2,
                      top: offset.dy - overlayH / 2,
                      width: overlayW,
                      height: overlayH,
                      child: Container(
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/images/bg_fish_oval1.webp",
                          fit: BoxFit.fill,
                        ),
                      ),
                    );
                  },
                );
              },
              'fish_danger_overlays': (BuildContext ctx, FlameGame gm) {
                return ValueListenableBuilder<Offset?>(
                  valueListenable: overlayNotifier2,
                  builder: (context, offset, _) {
                    if (offset == null) return const SizedBox.shrink();

                    var overlayW = 230.w;
                    var overlayH = 230.h;

                    return Positioned(
                      left: offset.dx - overlayW / 2,
                      top: offset.dy - overlayH / 2,
                      width: overlayW,
                      height: overlayH,
                      child: ScalingOverlay(child: Image.asset(
                        "assets/images/bg_danger.webp",
                        fit: BoxFit.fill,
                      )),
                    );
                  },
                );
              },
            },
            initialActiveOverlays: const ['fish_overlays','fish_danger_overlays'],
          ),
        ),
      ),
    );
  }
}
