import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/global.dart';
import '../utils/GlobalTimerManager.dart';
import 'FishComponent.dart';

class SimpleAnimGame extends FlameGame {
  late final FishComponent fishComment;
  late SpriteComponent coinBg;
  late SpriteComponent coinIcon;
  late SpriteComponent settingIcon;
  TextComponent? coinText;
  late SpriteComponent bgProtect;
  late TextComponent timeText;
  @override
  Color backgroundColor() => Colors.transparent;
  final int level;
  SimpleAnimGame(this.level);
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    var picName = "";
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

    // 背景图片
    bgProtect = SpriteComponent()
      ..sprite = await Sprite.load('bg_protect.webp') // 注意路径
      ..size = Vector2(124, 47) // 对应 Flutter 的 width:124.w, height:47.h
      ..position = Vector2((size.x - 124) / 2, 529); // 顶部对齐 + top padding
    add(bgProtect);

    // 时间文字
    final textPaintTime = TextPaint(
      style: TextStyle(
        color: Color(0xFF561C3E),
        fontSize: 15, // 对应 15.sp
        fontWeight: FontWeight.bold,
      ),
    );

    timeText = TextComponent(
      text: GlobalTimerManager().formatTime(0),
      textRenderer: textPaintTime,
      anchor: Anchor.topRight,
    )
      ..position = bgProtect.position + Vector2(bgProtect.size.x - 12, 13); // right:12, top:13
    add(timeText);
    updateProtectTime(0);
  }

  /// 外部调用以更新 coin 文本（只修改 TextComponent，不触发 Flutter rebuild）
  void updateCoin(double coin) {
    if(coinText == null)return;
    final formatted = coin.toStringAsFixed(3);
    if (coinText!.text != formatted) {
      coinText!.text = formatted;
    }
  }

  void updateProtectTime(int time){
    // 每帧刷新文字，如果保护时间在减少
    if(time == 0){
      bgProtect.paint.color = bgProtect.paint.color.withOpacity(0.0);
      timeText.text = "";
      hideProtect();
      globalShowProtect = false;
    }else{
      bgProtect.paint.color = bgProtect.paint.color.withOpacity(1.0);
      timeText.text = GlobalTimerManager().formatTime(time);
    }
  }

  void showProtect(){
    fishComment.showOverlay();
    globalShowProtect = true;
  }

  void hideProtect(){
    fishComment.hideOverlay();
  }

  void showDanger(){
    fishComment.showDanger();
  }

  void hideDanger(){
    fishComment.hideDanger();
  }

  void pauseMovement(){
    fishComment.pauseMovement();
  }

  void resumeMovement(){
    fishComment.resumeMovement();
  }

  void swimToCenter(){
    fishComment.swimToCenter();
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
