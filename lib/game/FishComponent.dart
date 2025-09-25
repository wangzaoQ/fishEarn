import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'FishAnimGame.dart'; // 你的 SimpleAnimGame

class FishComponent extends SpriteAnimationComponent with HasGameRef<SimpleAnimGame> {
  final Random _random = Random();

  final String picName; // 资源路径（例如 "images/fish/fish_1"）
  double speed;
  double frameStep;
  double turnSpeed; // radians/sec

  // 动态状态
  Vector2 velocity = Vector2.zero();
  double currentAngle = 0.0;
  double targetAngle = 0.0;

  // 暂停状态
  bool _movementPaused = false;
  Vector2? _savedVelocity;
  ValueNotifier<Offset?>? _overlayNotifier;
  final int _overlayId;

  FishComponent({
    required this.picName,
    this.speed = 60,
    this.frameStep = 0.12,
    this.turnSpeed = 2.0,
    Vector2? position,
    Vector2? size,
  })  : _overlayId = DateTime.now().microsecondsSinceEpoch ^ picName.hashCode,
        super(position: position, size: size) {
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
      final px = halfW + _random.nextDouble() * max(0, w - 2 * halfW);
      final py = halfH + _random.nextDouble() * max(0, h - 2 * halfH);
      position = Vector2(px, py);
    }

    // 初始化角度和速度
    currentAngle = _random.nextDouble() * 2 * pi;
    targetAngle = currentAngle;
    velocity = Vector2(cos(currentAngle), sin(currentAngle)) * speed;
    _updateFlipByVelocity();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_movementPaused) {
      // 随机微调角度
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
      var bounced = false;

      if (position.x < halfW) {
        position.x = halfW;
        velocity.x = velocity.x.abs();
        bounced = true;
      } else if (position.x > maxX) {
        position.x = maxX;
        velocity.x = -velocity.x.abs();
        bounced = true;
      }

      if (position.y < halfH) {
        position.y = halfH;
        velocity.y = velocity.y.abs();
        bounced = true;
      } else if (position.y > maxY) {
        position.y = maxY;
        velocity.y = -velocity.y.abs();
        bounced = true;
      }

      if (bounced) {
        currentAngle = atan2(velocity.y, velocity.x);
        targetAngle = currentAngle;
      }
    } else {
      velocity = Vector2.zero();
    }

    _updateFlipByVelocity();

    // 更新 overlay 位置（屏幕坐标）
    if (_overlayNotifier != null) {
      final screenOffset = Offset(position.x.toDouble(), position.y.toDouble());
      _overlayNotifier!.value = screenOffset;
    }
  }

  void _updateFlipByVelocity() {
    scale.x = (velocity.x < 0) ? -1.0 : 1.0;
  }

  double _normalizeAngle(double angle) {
    while (angle > pi) angle -= 2 * pi;
    while (angle < -pi) angle += 2 * pi;
    return angle;
  }

  /// 暂停游动（动画仍然播放），可显示 overlay
  void pauseMovement(bool showOverlayWhenPaused) {
    if (_movementPaused) {
      if (showOverlayWhenPaused && _overlayNotifier == null) {
        _overlayNotifier = gameRef.ensurePauseNotifier(_overlayId);
        _overlayNotifier!.value = Offset(position.x.toDouble(), position.y.toDouble());
      }
      return;
    }
    _movementPaused = true;
    _savedVelocity = velocity.clone();
    velocity = Vector2.zero();

    if (showOverlayWhenPaused) {
      _overlayNotifier = gameRef.ensurePauseNotifier(_overlayId);
      _overlayNotifier!.value = Offset(position.x.toDouble(), position.y.toDouble());
    }
  }

  /// 恢复游动并移除 overlay
  void resumeMovement({bool hideOverlayWhenResumed = true}) {
    if (!_movementPaused) return;
    _movementPaused = false;
    if (_savedVelocity != null) {
      velocity = _savedVelocity!.clone();
    } else {
      velocity = Vector2(cos(currentAngle), sin(currentAngle)) * speed;
    }
    _savedVelocity = null;

    if (hideOverlayWhenResumed && _overlayNotifier != null) {
      gameRef.removePauseNotifier(_overlayId);
      _overlayNotifier = null;
    }
  }

  @override
  void onRemove() {
    if (_overlayNotifier != null) {
      gameRef.removePauseNotifier(_overlayId);
      _overlayNotifier = null;
    }
    super.onRemove();
  }

}
