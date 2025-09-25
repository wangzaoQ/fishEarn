import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../config/global.dart';
import 'FishAnimGame.dart'; // 你的 SimpleAnimGame
class FishComponent extends SpriteAnimationComponent with HasGameRef<SimpleAnimGame> {
  final Random _random = Random();

  final String picName;
  double speed;
  double frameStep;
  double turnSpeed;

  Vector2 velocity = Vector2.zero();
  double currentAngle = 0.0;
  double targetAngle = 0.0;

  FishComponent({
    required this.picName,
    this.speed = 60,
    this.frameStep = 0.12,
    this.turnSpeed = 2.0,
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final frames = <Sprite>[];
    for (int i = 1; i <= 6; i++) {
      frames.add(await gameRef.loadSprite('$picName$i.png'));
    }
    animation = SpriteAnimation.spriteList(frames, stepTime: frameStep);

    // 随机初始位置
    if (position == null) {
      final w = gameRef.size.x;
      final h = gameRef.size.y;
      final halfW = (size?.x ?? width) / 2;
      final halfH = (size?.y ?? height) / 2;
      position = Vector2(
        halfW + _random.nextDouble() * max(0, w - 2 * halfW),
        halfH + _random.nextDouble() * max(0, h - 2 * halfH),
      );
    }

    currentAngle = _random.nextDouble() * 2 * pi;
    targetAngle = currentAngle;
    velocity = Vector2(cos(currentAngle), sin(currentAngle)) * speed;
    _updateFlipByVelocity();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 游动逻辑保持不变
    if (_random.nextDouble() < 0.01) {
      final delta = (_random.nextDouble() * 2 - 1) * pi / 6;
      targetAngle = currentAngle + delta;
    }

    final diff = _normalizeAngle(targetAngle - currentAngle);
    final maxTurn = turnSpeed * dt;
    if (diff.abs() > 0.0001) {
      currentAngle += diff.sign * min(maxTurn, diff.abs());
    }

    velocity = Vector2(cos(currentAngle), sin(currentAngle)) * speed;
    position += velocity * dt;

    // 边界反弹
    final halfW = width / 2;
    final halfH = height / 2;
    final maxX = gameRef.size.x - halfW;
    final maxY = gameRef.size.y - halfH;

    if (position.x < halfW) {
      position.x = halfW;
      velocity.x = velocity.x.abs();
      currentAngle = atan2(velocity.y, velocity.x);
    } else if (position.x > maxX) {
      position.x = maxX;
      velocity.x = -velocity.x.abs();
      currentAngle = atan2(velocity.y, velocity.x);
    }

    if (position.y < halfH) {
      position.y = halfH;
      velocity.y = velocity.y.abs();
      currentAngle = atan2(velocity.y, velocity.x);
    } else if (position.y > maxY) {
      position.y = maxY;
      velocity.y = -velocity.y.abs();
      currentAngle = atan2(velocity.y, velocity.x);
    }

    _updateFlipByVelocity();

    // 更新 overlay 坐标（如果 overlay 显示）
    overlayNotifier?.value = overlayNotifier?.value != null
        ? Offset(position.x.toDouble(), position.y.toDouble())
        : null;
  }

  void _updateFlipByVelocity() {
    scale.x = (velocity.x < 0) ? -1.0 : 1.0;
  }

  double _normalizeAngle(double angle) {
    while (angle > pi) angle -= 2 * pi;
    while (angle < -pi) angle += 2 * pi;
    return angle;
  }

  /// 显示 overlay（不暂停游动）
  void showOverlay() {
    if (overlayNotifier != null) {
      overlayNotifier!.value = Offset(position.x.toDouble(), position.y.toDouble());
    }
  }

  /// 隐藏 overlay
  void hideOverlay() {
    if (overlayNotifier != null) {
      overlayNotifier!.value = null;
    }
  }
}
