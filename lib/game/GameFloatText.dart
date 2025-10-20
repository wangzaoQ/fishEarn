import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class GameFloatingText extends TextComponent {
  static const double defaultLife = 0.7;
  static const double defaultOffsetY = -40.0;

  final TextPaint _basePaint; // 初始 paint（只读）
  final TextStyle _baseStyle;
  double _totalLife = defaultLife;
  double _lifeRemaining = 0.0;
  bool isInUse = false;

  GameFloatingText._empty(this._basePaint)
      : _baseStyle = _basePaint.style,
        super(text: '', textRenderer: _basePaint) {
    anchor = Anchor.center;
    priority = 100;
  }

  GameFloatingText(String text, Vector2 pos, {required TextPaint textPaint})
      : _basePaint = textPaint,
        _baseStyle = textPaint.style,
        super(text: text, textRenderer: textPaint) {
    anchor = Anchor.center;
    position = pos.clone();
    priority = 100;
    _start(defaultLife, defaultOffsetY);
  }

  static GameFloatingText createEmpty(TextPaint paint) => GameFloatingText._empty(paint);

  /// 重置并开始播放（用于池化）
  void reset(
      String newText,
      Vector2 startPos, {
        double life = defaultLife,
        double offsetY = defaultOffsetY,
      }) {
    text = newText;
    position = startPos.clone();
    isInUse = true;
    _totalLife = life;
    _lifeRemaining = life;

    // 1) 取消已有 effects（旧版本没有 effects.clear）
    removeAll(children.whereType<Effect>().toList());

    // 2) 启动位移动画（MoveByEffect 应该可用）
    add(MoveByEffect(
      Vector2(0, offsetY),
      EffectController(duration: life, curve: Curves.easeOut),
    ));

    // 3) 立刻把 textRenderer 设为完全不透明（不能直接改 _basePaint 的 color）
    final Color baseColor = _baseStyle.color ?? Colors.white;
    textRenderer = TextPaint(style: _baseStyle.copyWith(color: baseColor.withOpacity(1.0)));
  }

  /// 直接 new 时的启动
  void _start(double life, double offsetY) {
    _totalLife = life;
    _lifeRemaining = life;
    removeAll(children.whereType<Effect>().toList());
    add(MoveByEffect(
      Vector2(0, offsetY),
      EffectController(duration: life, curve: Curves.easeOut),
    ));
    final Color baseColor = _baseStyle.color ?? Colors.white;
    textRenderer = TextPaint(style: _baseStyle.copyWith(color: baseColor.withOpacity(1.0)));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_lifeRemaining <= 0) return;
    _lifeRemaining -= dt;
    final progress = ((_totalLife - _lifeRemaining) / _totalLife).clamp(0.0, 1.0);
    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    // 重建 TextPaint（每帧），把 alpha 应用到颜色上
    final Color baseColor = _baseStyle.color ?? Colors.white;
    textRenderer = TextPaint(style: _baseStyle.copyWith(color: baseColor.withOpacity(alpha)));

    if (_lifeRemaining <= 0) {
      // 使用 isMounted（老版）检查挂载
      if (isMounted ?? true) {
        removeFromParent();
      } else {
        // 若没有 isMounted，直接尝试 remove
        removeFromParent();
      }
      isInUse = false;
    }
  }
}
