
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'FishComponent.dart';

class SimpleAnimGame extends FlameGame {

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 添加一条鱼
    add(FishComponent(
      picName: 'ic_animal', // 对应 assets/images/fish/fish_1.png 这样的资源
      size: Vector2(160.w, 160.w),
    ));
  }
}