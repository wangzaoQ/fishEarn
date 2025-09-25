import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/global.dart';
import 'FishComponent.dart';

class SimpleAnimGame extends FlameGame {
  late final FishComponent fishComment;
  late SpriteComponent coinBg;
  late SpriteComponent coinIcon;
  late SpriteComponent settingIcon;
  TextComponent? coinText;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // --- 现有：添加一条鱼 ---
    fishComment = FishComponent(
      picName: 'ic_animal', // 对应 assets/images/fish/... 的资源
      size: Vector2(160.w, 160.w),
    );
    add(fishComment);

    // --- 新增：创建并添加 coinText (只负责文本显示) ---
    // 使用画布宽度做简单缩放映射（设计宽度按 375）

    // 金币背景条
    coinBg = SpriteComponent()
      ..sprite = await Sprite.load("bg_to_bar_coin.webp")
      ..size = Vector2(90, 25) // 对应 Flutter 中 width:90.w, height:25.h
      ..position = Vector2(18, 43 + 11); // top + 内部 top
    add(coinBg);

    // 金币图标
    coinIcon = SpriteComponent()
      ..sprite = await Sprite.load("ic_coin.webp")
      ..size = Vector2(45, 45)
      ..position = Vector2(8, 43); // top + left
    add(coinIcon);

    // 金币数文字
    final textPaint = TextPaint(
      style: TextStyle(
        color: Color(0xFFF4FF72),
        fontSize: 15, // Flutter 中 15.sp 可以换成实际像素
        fontFamily: "AHV",
      ),
    );

    coinText = TextComponent(
      text: LocalCacheUtils.getGameData().coin.toStringAsFixed(3),
      textRenderer: textPaint,
      anchor: Anchor.center,
    )
      ..position = coinBg.position + Vector2(coinBg.size.x / 2, coinBg.size.y / 2);
    add(coinText!);

  }

  /// 外部调用以更新 coin 文本（只修改 TextComponent，不触发 Flutter rebuild）
  void updateCoin(double coin) {
    if(coinText == null)return;
    final formatted = coin.toStringAsFixed(3);
    if (coinText!.text != formatted) {
      coinText!.text = formatted;
    }
  }

  void showProtect(){
    fishComment.showOverlay();
  }

  @override
  void onRemove() {
    super.onRemove();
  }

  /// 若不使用 camera/缩放：世界坐标即屏幕坐标
  Offset worldToScreen(Vector2 world) {
    return Offset(world.x.toDouble(), world.y.toDouble());
  }
}
