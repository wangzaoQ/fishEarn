import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'FishAnimGame.dart';


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

  FishComponent({
    required this.picName,
    this.speed = 60,
    this.frameStep = 0.12,
    this.turnSpeed = 2.0,
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size) {
    // 关键：以中心为锚点，翻转不会导致视觉位置突变
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 加载单帧或多帧（这里按单帧示例；若你有多帧可加载列表）
    final frames = <Sprite>[];
    frames.add(await gameRef.loadSprite('$picName.webp'));
    animation = SpriteAnimation.spriteList(frames, stepTime: frameStep);

    // 如果调用时没有传 position，则随机放到屏幕内的一个位置（避免都在中间）
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

    // 确保初始朝向和 scale 一致
    _updateFlipByVelocity();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 随机微小改变目标角度（在当前角度附近），避免瞬间大角度跳变
    if (_random.nextDouble() < 0.01) {
      final maxDelta = pi / 6; // ±30度以内的小变动
      final delta = (_random.nextDouble() * 2 - 1) * maxDelta;
      targetAngle = currentAngle + delta;
    }

    // 平滑转向：把 currentAngle 慢慢朝 targetAngle 靠拢
    final diff = _normalizeAngle(targetAngle - currentAngle);
    final maxTurn = turnSpeed * dt;
    if (diff.abs() > 0.0001) {
      currentAngle += diff.sign * min(maxTurn, diff.abs());
    }

    // 根据 currentAngle 更新速度，并移动
    velocity = Vector2(cos(currentAngle), sin(currentAngle)) * speed;
    position += velocity * dt;

    // 边界处理（使用中心锚点，因此位置边界以半宽半高为基准）
    final halfW = width / 2;
    final halfH = height / 2;
    final maxX = gameRef.size.x - halfW;
    final maxY = gameRef.size.y - halfH;

    var bounced = false;

    if (position.x < halfW) {
      position.x = halfW;
      velocity.x = velocity.x.abs(); // 朝内反弹
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
      // 反弹后立即把角度与速度同步，且把 targetAngle 设为当前角度（避免马上再次急转）
      currentAngle = atan2(velocity.y, velocity.x);
      targetAngle = currentAngle;
    } else {
      // 若未反弹，保持 currentAngle 为主角度（已经被平滑更新）
      // velocity 已由 currentAngle 更新
    }

    // 根据 velocity 翻转精灵（保证朝向正确）
    _updateFlipByVelocity();
  }

  void _updateFlipByVelocity() {
    // 固定朝向用 ±1 防止 scale 值累积或变成其它数
    if (velocity.x < 0) {
      scale.x = -1.0;
    } else {
      scale.x = 1.0;
    }
  }

  double _normalizeAngle(double angle) {
    while (angle > pi) angle -= 2 * pi;
    while (angle < -pi) angle += 2 * pi;
    return angle;
  }
}
