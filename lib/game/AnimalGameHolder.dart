import 'package:fish_earn/utils/LogUtils.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        padding: EdgeInsets.only(top: 150.h, bottom: 80.h),
        child: Container(
          color: Colors.transparent,
          child: GameWidget(
            game: _game,
            overlayBuilderMap: {
              // Overlay 名称（保持激活），会绘制所有 fish 的 pause widget
              'fish_overlays': (BuildContext ctx, FlameGame gm) {
                final g = gm as SimpleAnimGame;
                return Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true, // 不拦截触摸（若要拦截删掉）
                    child: Stack(
                      children: [
                        // 为每个 notifier 构造一个 ValueListenableBuilder
                        ...g.pauseOverlayPositions.entries.map((entry) {
                          final notifier = entry.value;
                          const overlayW = 56.0;
                          const overlayH = 28.0;
                          return ValueListenableBuilder<Offset?>(
                            valueListenable: notifier,
                            builder: (context, offset, child) {
                              LogUtils.logD("${TAG} listen game move");
                              if (offset == null) return const SizedBox.shrink();
                              return Positioned(
                                left: offset.dx - overlayW / 2,
                                top: offset.dy - overlayH / 2,
                                width: overlayW,
                                height: overlayH,
                                child: child!,
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child:SizedBox(width: 230.w,height: 230.h,child: Image.asset("assets/images/bg_fish_oval1.webp"),),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
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
