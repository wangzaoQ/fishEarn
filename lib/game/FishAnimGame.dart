
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
   var fishComment =  FishComponent(
      picName: 'ic_animal', // 对应 assets/images/fish/fish_1.png 这样的资源
      size: Vector2(160.w, 160.w),
    );
    add(fishComment);
    // Future.delayed(Duration(seconds: 3), () {
    //   fishComment.pauseMovement(true);
    // });
  }
  /// id -> notifier(Offset?) ; Offset == null 表示隐藏
  final Map<int, ValueNotifier<Offset?>> pauseOverlayPositions = {};

  /// 确保存在 notifier 并返回（若不存在就创建）
  ValueNotifier<Offset?> ensurePauseNotifier(int id) {
    return pauseOverlayPositions.putIfAbsent(id, () => ValueNotifier<Offset?>(null));
  }

  /// 移除并 dispose notifier
  void removePauseNotifier(int id) {
    final n = pauseOverlayPositions.remove(id);
    n?.value = null;
    n?.dispose();
  }

  @override
  void onRemove() {
    // 清理
    for (final n in pauseOverlayPositions.values) {
      n.dispose();
    }
    pauseOverlayPositions.clear();
    super.onRemove();
  }

  /// 若不使用 camera/缩放：世界坐标即屏幕坐标
  Offset worldToScreen(Vector2 world) {
    return Offset(world.x.toDouble(), world.y.toDouble());
  }
}