import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/global.dart';
import '../utils/GameManager.dart';
import '../utils/GlobalTimerManager.dart';
import 'CashCountdownComponent.dart';
import 'FishComponent.dart';

class FishAnimGame extends FlameGame {
  FishComponent? fishComment;
  late SpriteComponent coinBg;
  late SpriteComponent coinIcon;
  late SpriteComponent settingIcon;
  TextComponent? coinText;
  SpriteComponent? bgProtect;
  late TextComponent timeText;
  SpriteComponent? fishOverlay;


  @override
  Color backgroundColor() => Colors.transparent;
  final int level;
  FishAnimGame(this.level);
  late CashCountdownComponent cashCountdown;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    var picName = "";
    var width = 0.0;
    var height = 0.0;
    if(level == 1){
      picName = "ic_game1";
      width = 96.w;
      height = 52.h;
    }else if(level == 2){
      picName = "ic_animal";
      width = 160.w;
      height = 160.w;
    }else if(level == 3){
      picName = "ic_game3_a";
      width = 160.w;
      height = 160.w;
    }
    // --- 现有：添加一条鱼 ---
    fishComment = FishComponent(
      level: level,
      picName: picName, // 对应 assets/images/fish/... 的资源
      size: Vector2(width, height),
    );
    add(fishComment!);

    // --- 新增：创建并添加 coinText (只负责文本显示) ---
    // 使用画布宽度做简单缩放映射（设计宽度按 375）

    // 金币背景条
    coinBg = SpriteComponent()
      ..sprite = await Sprite.load("bg_to_bar_coin.webp")
      ..size = Vector2(90.w, 25.h) // 对应 Flutter 中 width:90.w, height:25.h
      ..position = Vector2(18.w, 43.h + 11.h); // top + 内部 top
    add(coinBg);

    // 金币图标
    coinIcon = SpriteComponent()
      ..sprite = await Sprite.load("ic_coin4.webp")
      ..size = Vector2(45.w, 45.h)
      ..position = Vector2(8.w, 43.h); // top + left
    add(coinIcon);

    // 金币数文字
    final textPaint = TextPaint(
      style: TextStyle(
        color: Color(0xFFF4FF72),
        fontSize: 15.sp, // Flutter 中 15.sp 可以换成实际像素
        fontFamily: "AHV",
      ),
    );

    coinText = TextComponent(
      text: GameManager.instance.getCoinShow(LocalCacheUtils.getGameData().coin),
      textRenderer: textPaint,
      anchor: Anchor.center,
    )
      ..position = coinBg.position + Vector2(coinBg.size.x / 2+10.w, coinBg.size.y / 2);
    add(coinText!);

    // 保护计时器功能 背景图
    // fish overlay 特效圈
    fishOverlay = SpriteComponent()
      ..sprite = await Sprite.load("bg_fish_oval1.webp")
      ..size = Vector2(230.w, 230.h)
      ..anchor = Anchor.topLeft
      ..position = Vector2(-9999, -9999);
    add(fishOverlay!);
    fishOverlay!.paint.color= fishOverlay!.paint.color.withOpacity(0.0); // 初始隐藏
    bgProtect = SpriteComponent()
      ..sprite = await Sprite.load('bg_protect.webp') // 注意路径
      ..size = Vector2(124, 47) // 对应 Flutter 的 width:124.w, height:47.h
      ..position = Vector2((size.x - 124) / 2, 529); // 顶部对齐 + top padding
    add(bgProtect!);
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
      ..position = bgProtect!.position + Vector2(bgProtect!.size.x - 12, 13); // right:12, top:13
    add(timeText);
    if(!globalShowProtect){
      updateProtectTime(0);
    }


    // --- ✅ 倒计时组件（初始为隐藏） ---
    cashCountdown = CashCountdownComponent(initialSeconds: 0)
      ..position = Vector2(size.x - 112.w , 400.h);
    add(cashCountdown);
  }

  /// 外部调用以更新 coin 文本（只修改 TextComponent，不触发 Flutter rebuild）
  void updateCoin(double coin) {
    if(coinText == null)return;
    final formatted = coin.toStringAsFixed(2);
    if (coinText!.text != formatted) {
      coinText!.text = formatted;
    }
  }

  void updateProtectTime(int time){
    // 每帧刷新文字，如果保护时间在减少
    if(bgProtect == null || fishOverlay == null)return;
    if(time == 0){
      bgProtect!.paint.color = bgProtect!.paint.color.withOpacity(0.0);
      timeText.text = "";
      globalShowProtect = false;
    }else{
      bgProtect!.paint.color = bgProtect!.paint.color.withOpacity(1.0);
      timeText.text = GlobalTimerManager().formatTime(time);
      showProtect();
    }
  }

  void updateUnLimitTime(int time){
    // 只负责把外部时间传给倒计时组件，组件会根据是否为0显示/隐藏
    cashCountdown.setTime(time);
  }

  void showProtect(){
    globalShowProtect = true;
  }
  bool _overlayVisible = false;

  void showOverlay(Offset offset) {
    if(fishOverlay == null)return;
    if (!_overlayVisible) {
      // ✅ 显示 overlay（如果之前是隐藏的）
      fishOverlay!.paint.color = Colors.white.withOpacity(1.0);
      _overlayVisible = true;
    }
    // ✅ 直接使用传入的中心点 offset
    // 把 Offset（中心点）转换成左上角位置
    final overlaySize = fishOverlay!.size;
    fishOverlay!.position = Vector2(
      offset.dx - overlaySize.x / 2,
      offset.dy - overlaySize.y / 2,
    );
  }

  void hideOverlay(){
    if(fishOverlay == null)return;
    if (_overlayVisible) {
      fishOverlay!.paint.color = Colors.white.withOpacity(0.0);
      _overlayVisible = false;
    }
  }

  void showDanger(){
    globalShowDanger1 = true;
    fishComment?.showDanger();
  }

  void hideDanger(){
    globalShowDanger1 = false;
    fishComment?.hideDanger();
  }

  void pauseMovement(){
    fishComment?.pauseMovement();
  }

  void resumeMovement(){
    fishComment?.resumeMovement();
  }

  void swimToCenter(){
    fishComment?.swimToCenter();
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
