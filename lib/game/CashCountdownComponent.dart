
import 'dart:ui';

import 'package:flame/components.dart' show PositionComponent, SpriteComponent, TextComponent, Sprite, Vector2, Anchor;
import 'package:flame/text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/GlobalTimerManager.dart';

/// ---------- 仅由外部时间驱动的倒计时组件 ----------
/// 规则：外部每次有时间（可能来自服务器或逻辑层）就调用 setTime(seconds)
/// - 如果 seconds > 0：显示图标与数字（文本存在时直接更新文本）
/// - 如果 seconds == 0：隐藏（通过 icon.opacity=0 + 移除文本组件）
class CashCountdownComponent extends PositionComponent {
  CashCountdownComponent({required this.initialSeconds});

  final int initialSeconds;
  int _currentSeconds = 0;
  late SpriteComponent bg;      // 背景图层
  late SpriteComponent icon;
  TextComponent? _textComponent;

  // 文本样式
  final Color _textColor = const Color(0xFFFFFFFF);
  final double _fontSize = 15.sp;
  final String? _fontFamily = "AHV";
  final double offsetX = 25.w;

  @override
  Future<void> onLoad() async {
    _currentSeconds = initialSeconds;
    // 背景层（固定 60x60）
    bg = SpriteComponent()
      ..sprite = await Sprite.load("bg_fish_oval1.webp")
      ..size = Vector2(60.w, 60.h)
      ..anchor = Anchor.topLeft
      ..position = Vector2(offsetX, 0);

    icon = SpriteComponent()
      ..sprite = await Sprite.load("ic_cash_tips_top.webp")
      ..size = Vector2(38.w, 44.h)
      ..anchor = Anchor.center
      ..position = Vector2(
        offsetX + bg.size.x / 2, // 背景中心 X
        bg.size.y / 2,           // 背景中心 Y
      );

    add(bg);
    add(icon);


    // 初始按 initialSeconds 显示/隐藏
    if (_currentSeconds > 0) {
      _createAndAddText(_currentSeconds);
      icon.opacity = 1.0;
      bg.opacity = 1.0;
    } else {
      icon.opacity = 0.0;
      bg.opacity = 0.0;
    }

    // 设置一个合理的 size（估算）
    size = Vector2(70.w, 70.h);
  }

  /// 外部调用：把当前时间传进来（每次外部数据更新时调用）
  ///  - time == 0 -> 隐藏
  ///  - time > 0  -> 显示并更新文本为 time
  void setTime(int time) {
    // 如果没有变更，不做不必要操作
    if (time == _currentSeconds) return;

    _currentSeconds = time;
    if (_currentSeconds > 0) {
      // 显示
      icon.opacity = 1.0;
      bg.opacity = 1.0;
      if (_textComponent == null) {
        _createAndAddText(_currentSeconds);
      } else {
        _textComponent!.text = GlobalTimerManager().formatTime(_currentSeconds);
      }
    } else {
      // 隐藏：移除 text 并把 icon 设透明
      if (_textComponent != null) {
        _textComponent!.removeFromParent();
        _textComponent = null;
      }
      icon.opacity = 0.0;
      bg.opacity = 0.0;
    }
  }

  // 创建并 add 文本（放在 icon 下方）
  void _createAndAddText(int seconds) {
    if (_textComponent != null) return;

    final paint = TextPaint(
      style: TextStyle(
        color: _textColor,
        fontSize: _fontSize,
        fontFamily: _fontFamily,
      ),
    );

    final txt = TextComponent(
      text: GlobalTimerManager().formatTime(seconds),
      textRenderer: paint,
      anchor: Anchor.topLeft,
    );

    // 放在 icon 下方，微调偏移可按需要改
    txt.position = Vector2(23.w, icon.size.y + 10.h);

    _textComponent = txt;
    add(_textComponent!);
  }
}