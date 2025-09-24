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

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary 防止外部重绘影响 GameWidget
    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(top: 150.h, bottom: 80.h),
        child: Container(
          color: Colors.transparent,
          child: GameWidget(game: _game),
        ),
      ),
    );
  }
}
