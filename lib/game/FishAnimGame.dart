import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'FishComponent.dart';

class SimpleAnimGame extends FlameGame {
  late final TextComponent coinText;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // --- 现有：添加一条鱼 ---
    var fishComment = FishComponent(
      picName: 'ic_animal', // 对应 assets/images/fish/... 的资源
      size: Vector2(160.w, 160.w),
    );
    add(fishComment);

    // --- 新增：创建并添加 coinText (只负责文本显示) ---
    // 使用画布宽度做简单缩放映射（设计宽度按 375）
    final double designWidth = 375.0.w;
    final double scale = size.x / designWidth;

    // 参考你 Flutter 里原来位置: left:18.h, top:43.h, 背景条宽90 高25, 文本放在背景中央
    final double bgX = 18.0 * scale;
    final double bgW = 90.0 * scale;
    final double bgY = (43.0 + 11.0) * scale; // top 43 + inner top 11
    final double bgH = 25.0 * scale;

    coinText = TextComponent(
      text: '0.000',
      textRenderer: TextPaint(
        style: TextStyle(
          color: const Color(0xFFFFFFFF),
          fontSize: 15 * scale, // px, 根据 scale 调整
          // fontFamily: 'AHV', // 如需自定义字体，在 Flame 中正确加载后再启用
        ),
      ),
    )
      ..anchor = Anchor.center
      ..position = Vector2(bgX + bgW / 2, bgY + bgH / 2)
      ..priority = 100;
    add(coinText);
  }

  /// 外部调用以更新 coin 文本（只修改 TextComponent，不触发 Flutter rebuild）
  void updateCoin(double coin) {
    final formatted = coin.toStringAsFixed(3);
    if (coinText.text != formatted) {
      coinText.text = formatted;
    }
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
