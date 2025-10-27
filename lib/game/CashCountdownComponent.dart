
import 'dart:ui';

import 'package:flame/components.dart' show PositionComponent, SpriteComponent, TextComponent, Sprite, Vector2, Anchor, TextPaint;
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ---------- 仅由外部时间驱动的倒计时组件 ----------
/// 规则：外部每次有时间（可能来自服务器或逻辑层）就调用 setTime(seconds)
/// - 如果 seconds > 0：显示图标与数字（文本存在时直接更新文本）
/// - 如果 seconds == 0：隐藏（通过 icon.opacity=0 + 移除文本组件）
class CashCountdownComponent extends PositionComponent {
  CashCountdownComponent({required this.initialSeconds});

  final int initialSeconds;
  int _currentSeconds = 0;

  late SpriteComponent icon;
  TextComponent? _textComponent;

  // 文本样式
  final Color _textColor = const Color(0xFF651922);
  final double _fontSize = 15.sp;
  final String? _fontFamily = "AHV";

  @override
  Future<void> onLoad() async {
    _currentSeconds = initialSeconds;

    icon = SpriteComponent()
      ..sprite = await Sprite.load("ic_cash_tips_top.webp")
      ..size = Vector2(30.w, 30.h)
      ..anchor = Anchor.topLeft;

    add(icon);

    // 初始按 initialSeconds 显示/隐藏
    if (_currentSeconds > 0) {
      _createAndAddText(_currentSeconds);
      icon.opacity = 1.0;
    } else {
      icon.opacity = 0.0;
    }

    // 设置一个合理的 size（估算）
    size = Vector2(icon.size.x, icon.size.y + 20.h);
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
      if (_textComponent == null) {
        _createAndAddText(_currentSeconds);
      } else {
        _textComponent!.text = _currentSeconds.toString();
      }
    } else {
      // 隐藏：移除 text 并把 icon 设透明
      if (_textComponent != null) {
        _textComponent!.removeFromParent();
        _textComponent = null;
      }
      icon.opacity = 0.0;
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
      text: seconds.toString(),
      textRenderer: paint,
      anchor: Anchor.topLeft,
    );

    // 放在 icon 下方，微调偏移可按需要改
    txt.position = Vector2(0, icon.size.y + 4.h);

    _textComponent = txt;
    add(_textComponent!);
  }
}