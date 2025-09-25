import 'package:fish_earn/data/GameData.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:fish_earn/utils/LogUtils.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/global.dart';
import '../utils/LocalCacheUtils.dart';
import 'FishAnimGame.dart';

class AnimalGameHolder extends StatefulWidget {
  final int level;
  const AnimalGameHolder({super.key, required this.level});

  @override
  State<AnimalGameHolder> createState() => _AnimalGameHolderState();
}

class _AnimalGameHolderState extends State<AnimalGameHolder> {
  late final SimpleAnimGame _game;

  @override
  void initState() {
    super.initState();
    _game = SimpleAnimGame(); // 只创建一次
    GameManager.instance.game = _game;
  }

  @override
  void dispose() {
    _game.onRemove(); // 或者调用你需要的清理方法（根据 SimpleAnimGame 实现）
    super.dispose();
  }

  var TAG = "GAME_ANIMAL";

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary 防止外部重绘影响 GameWidget
    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(top: 0.h, bottom: 80.h),
        child: Container(
          color: Colors.transparent,
          child: GameWidget(
            game: _game,
            overlayBuilderMap: {
              'fish_overlays': (BuildContext ctx, FlameGame gm) {
                final g = gm as SimpleAnimGame;

                // 单条鱼 overlayNotifier
                return ValueListenableBuilder<Offset?>(
                  valueListenable: overlayNotifier, // 对应 FishComponent.overlayNotifier
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
                        // decoration: BoxDecoration(
                        //   color: Colors.black.withOpacity(0.55),
                        //   borderRadius: BorderRadius.circular(6),
                        // ),
                        child: Image.asset("assets/images/bg_fish_oval1.webp",fit: BoxFit.fill,),
                      ),
                    );
                  },
                );
              },

            },
            initialActiveOverlays: const ['fish_overlays'],
          ),
        ),
      ),
    );
  }
}
