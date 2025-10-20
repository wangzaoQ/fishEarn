import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/global.dart';
import 'FishAnimGame.dart';
import 'GameFloatText.dart'; // 你的 SimpleAnimGame

class FishComponent extends SpriteAnimationComponent with HasGameRef<FishAnimGame> {
  final Random _random = Random();

  int level;

  final String picName;
  double speed;
  double frameStep;
  double turnSpeed;

  Vector2 velocity = Vector2.zero();
  double currentAngle = 0.0;
  double targetAngle = 0.0;

  // 主动游向中心相关（改进：使用弹簧物理）
  bool _moveToCenter = false;
  // 旧的 duration/elapsed 字段还保留以兼容外部调用，但移动改为弹簧物理
  double _moveToCenterDuration = 1.0;
  double _moveToCenterElapsed = 0.0;
  Vector2? _moveStartPosition;
  double arriveThreshold = 12.0;

  // 新增：弹簧物理参数 & 内部速度状态
  Vector2 _springVel = Vector2.zero();
  double _springMass = 1.0;
  double _springStiffness = 180.0; // 推荐 120~220 左右
  double _springDamping = 25.0;    // 推荐 18~28 左右
  double _springStopSpeed = 5.0;   // 速度小于此认为停止

  // ===== 新增：暂停控制 =====
  bool _pausedMovement = false; // 暂停仅移动（但仍播放帧动画）
  bool _pausedAll = false; // 完全暂停（连帧动画也暂停）

  FishComponent({
    required this.picName,
    required this.level,
    this.speed = 60,
    this.frameStep = 0.12,
    this.turnSpeed = 2.0,
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size) {
    anchor = Anchor.center;
  }

  /// 外部调用：主动游向屏幕中心
  /// NOTE: 虽然保留了 duration 参数，但实际移动现在使用弹簧物理以获得更自然的感觉。
  /// 如果你喜欢基于时间的到达可以再改回；目前默认用弹簧。
  void swimToCenter({double duration = 1.0, double threshold = 12.0}) {
    _moveToCenter = true;
    _moveToCenterDuration = max(0.01, duration);
    _moveToCenterElapsed = 0.0;
    _moveStartPosition = position.clone();
    arriveThreshold = threshold;

    // 弹簧运动初速度：把当前速度投影为初始弹簧速度，保持平滑过渡
    _springVel = velocity.clone();

    // 可按需要调整弹簧参数（也可暴露给外部）
    _springMass = 1.0;
    _springStiffness = 180.0;
    _springDamping = 25.0;
    _springStopSpeed = 5.0;

    // 保持当前角度为起始角度，转向将在 update 时平滑处理
    targetAngle = currentAngle;
  }

  // ===== 对外暂停/恢复 API =====

  /// 只暂停游动（位置/速度/转向停止），但 sprite animation 仍播放
  void pauseMovement() {
    _pausedMovement = true;
  }

  /// 恢复之前被 pauseMovement 暂停的游动
  void resumeMovement() {
    _pausedMovement = false;
  }

  /// 完全暂停：包括帧动画（super.update 不再被调用）
  void pauseAll() {
    _pausedAll = true;
  }

  /// 恢复 pauseAll
  void resumeAll() {
    _pausedAll = false;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final frames = <Sprite>[];
    if(level == 1){
      frames.add(await gameRef.loadSprite('$picName.png'));
    }else{
      for (int i = 1; i <= 6; i++) {
        frames.add(await gameRef.loadSprite('$picName$i.png'));
      }
    }
    animation = SpriteAnimation.spriteList(frames, stepTime: frameStep);

    // 确保 size 有合理值
    if (this.size.x <= 0 || this.size.y <= 0) {
      try {
        final src = frames.first.srcSize;
        if (src.x > 0 && src.y > 0) {
          this.size = Vector2(src.x, src.y);
        } else {
          this.size = Vector2(64, 64);
        }
      } catch (_) {
        this.size = Vector2(64, 64);
      }
    }

    // 随机初始位置（使用已确定的 size）
    if (position == null || position == Vector2.zero()) {
      final w = gameRef.size.x;
      final h = gameRef.size.y;
      final halfW = this.size.x / 2;
      final halfH = this.size.y / 2;
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
    // 如果完全暂停，则不调用 super.update，也不更新位置
    if (_pausedAll) {
      return;
    }

    // 仍然调用 super.update，以便 SpriteAnimation 能继续播放（除非是完全暂停）
    super.update(dt);

    // 如果只暂停移动，则跳过位置/速度/转向逻辑
    if (_pausedMovement) {
      return;
    }

    if (dt <= 0) return;

    // ===== 如果处于“弹簧移动到中心”模式 =====
    if (_moveToCenter) {
      // 初始化起点（万一在调用 swimToCenter 时 position 为 null）
      _moveStartPosition ??= position.clone();

      final center = gameRef.size / 2;

      // 半显式欧拉积分（spring physics）
      // displacement = x - x_target
      final Vector2 displacement = position - center; // Vector2
      // F_spring = -k * displacement
      final Vector2 springForce = displacement * -_springStiffness;
      // F_damp = -c * v
      final Vector2 dampingForce = _springVel * -_springDamping;
      // 合力
      final Vector2 force = springForce + dampingForce;
      // 加速度 a = F / m
      final Vector2 accel = force * (1.0 / _springMass);

      // 限制 step，避免帧率极低时不稳
      final double step = dt.clamp(0.0, 1.0 / 30.0);

      // v += a * dt; x += v * dt;
      _springVel.addScaled(accel, step);
      position.addScaled(_springVel, step);

      // 更新朝向：优先使用速度方向；若速度接近 0 则用中心方向
      Vector2 dirVec;
      if (_springVel.length > 0.001) {
        dirVec = _springVel;
      } else {
        dirVec = (center - position);
      }

      if (dirVec.length > 0.0001) {
        final desired = atan2(dirVec.y, dirVec.x);
        // 使用较高的转速以保证面向移动方向（但仍平滑）
        _applyTurningWithCustomSpeed(dt, desired, max(turnSpeed, 6.0));
      }

      // 更新 velocity（供翻转使用）——这里用 currentAngle 导出 velocity 方向
      final vx = cos(currentAngle);
      final vy = sin(currentAngle);
      velocity = Vector2(vx, vy) * speed;

      // 停止判定：位置足够接近中心且速度低
      if (position.distanceTo(center) <= arriveThreshold && _springVel.length <= _springStopSpeed) {
        position.setFrom(center);
        _springVel.setZero();
        _moveToCenter = false;
        targetAngle = currentAngle;
      }

      // 防止位置变成 NaN / inf（极端情况）
      if (!position.x.isFinite || !position.y.isFinite) {
        position = center.clone();
        _springVel.setZero();
        _moveToCenter = false;
      }
    } else {
      // ===== 常规随机游动逻辑（与之前相同，但稳健） =====

      final diff = _normalizeAngle(targetAngle - currentAngle);
      final isNearlyAligned = diff.abs() < 0.1;
      if (_random.nextDouble() < 0.006 && isNearlyAligned) {
        final delta = (_random.nextDouble() * 2 - 1) * pi / 8;
        targetAngle = currentAngle + delta;
      }

      _applyTurning(dt);

      velocity = Vector2(cos(currentAngle), sin(currentAngle)) * speed;
      if (!velocity.x.isFinite || !velocity.y.isFinite) {
        velocity = Vector2(1, 0) * speed;
      }

      position += velocity * dt;

      // 边界处理（避免瞬移）
      final halfW = this.size.x / 2;
      final halfH = this.size.y / 2;
      final maxX = gameRef.size.x - halfW;
      final maxY = gameRef.size.y - halfH;
      final double topMargin = 140.h; // 顶部保留 50 像素
      final minY = halfH + topMargin;
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
      } else if (position.y < minY) {
        position.y = minY;
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
    }

    _updateFlipByVelocity();

    // 更新 overlay（仅在 overlay 当前显示时更新）
    if (overlayNotifier != null && overlayNotifier!.value != null) {
      overlayNotifier!.value = Offset(position.x.toDouble(), position.y.toDouble());
    }
    if (overlayNotifier2 != null && overlayNotifier2!.value != null) {
      overlayNotifier2!.value = Offset(position.x.toDouble(), position.y.toDouble());
    }
    // === 每秒自动飘字 ===
    _floatingTimer += dt;
    if (_floatingTimer >= 1.0 && level>1) {
      _floatingTimer = 0.0;
      showFloatingText(level == 2? "+\$0.02": "+\$0.05", color: Color(0xFFFFEF50));
    }
  }

  // 原有转向逻辑，保持不变
  void _applyTurning(double dt) {
    final diff = _normalizeAngle(targetAngle - currentAngle);
    final maxTurn = turnSpeed * dt;
    if (diff.abs() > 0.0001) {
      currentAngle += diff.sign * min(maxTurn, diff.abs());
      if (!currentAngle.isFinite) currentAngle = 0.0;
    }
  }

  // 新增：允许传入自定义 turnSpeed（用于游向中心时快速对齐）
  void _applyTurningWithCustomSpeed(double dt, double desiredAngle, double customTurnSpeed) {
    final diff = _normalizeAngle(desiredAngle - currentAngle);
    final maxTurn = customTurnSpeed * dt;
    if (diff.abs() > 0.0001) {
      currentAngle += diff.sign * min(maxTurn, diff.abs());
      if (!currentAngle.isFinite) currentAngle = 0.0;
    }
  }

  void _updateFlipByVelocity() {
    if (!velocity.x.isFinite) return;
    scale.x = (velocity.x < 0) ? -1.0 : 1.0;
  }

  double _normalizeAngle(double angle) {
    while (angle > pi) angle -= 2 * pi;
    while (angle < -pi) angle += 2 * pi;
    return angle;
  }
  double _floatingTimer = 0.0; // 计时器

  /// 在鱼头顶显示飘字
  void showFloatingText(String text, {Color color = Colors.white}) {
    if (gameRef == null) return;

    final paint = TextPaint(
      style: TextStyle(
        fontSize: 28.sp,
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );

    final pos = position.clone()..y -= size.y / 2; // 鱼上方
    final ft = GameFloatingText(text, pos, textPaint: paint);
    gameRef.add(ft);
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

  /// 显示 Danger（不暂停游动）
  void showDanger() {
    if (overlayNotifier2 != null) {
      overlayNotifier2!.value = Offset(position.x.toDouble(), position.y.toDouble());
    }
  }

  /// 隐藏 Danger
  void hideDanger() {
    if (overlayNotifier2 != null) {
      overlayNotifier2!.value = null;
    }
  }
}
