import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';

class FishComponent extends SpriteComponent with HasGameRef {
  FishComponent({
    required Image spriteImage,
    Vector2? initialPosition,
  }) : super(
    sprite: Sprite(spriteImage),
    position: initialPosition ?? Vector2.zero(),
    anchor: Anchor.center,
  );

  // 随机数
  final Random _random = Random();

  // 基础运动
  Vector2 _velocity = Vector2.zero();
  double _currentSpeed = 0;
  double _headingAngle = 0; // 物理朝向（不含尾摆）
  double minCruiseSpeed = 60;
  double maxCruiseSpeed = 120;
  double maxTurnRate = pi; // 弧度/秒
  double speedJitterAmp = 15;
  double speedJitterHz = 0.35;

  // 样条路径控制（Catmull-Rom）
  // 始终维护 4 个控制点窗口：p0, p1, p2, p3
  late Vector2 _p0, _p1, _p2, _p3;
  double _u = 0; // 当前段的参数 0..1（段是 p1->p2）
  double _segmentLength = 1; // 当前段的近似长度（用于把世界速度换算成 du）
  double minSegmentLen = 120; // 每段最短长度（像素）
  double maxSegmentLen = 240; // 每段最长长度（像素）
  double maxTurnPerPoint = 0.6; // 生成下一个控制点允许的最大转角（弧度）

  // 连续游动边界与中心引导
  double boundaryMargin = 60;
  double boundaryBiasStrength = 0.45; // 生成新点时朝向中心的权重

  // 尾摆与呼吸
  double _tailPhase = 0;
  double tailHz = 3.0;
  double tailAngleAmp = 0.06;
  double _breathPhase = 0;
  double breathHz = 0.2;
  double breathScaleAmp = 0.03;

  // 冲刺
  bool _isDashing = false;
  double _dashTimer = 0;
  double dashDuration = 0.35;
  double dashSpeed = 320;
  double dashCooldown = 2.5;
  double _dashCooldownTimer = 0;
  double spontaneousDashChancePerSec = 0.08;
  Vector2? _dashBiasDirection; // 冲刺时对“下一个控制点方向”的偏置
  int _biasPointsLeft = 0;     // 还需要偏置的控制点数量

  // 水迹粒子
  double _trailTimer = 0;
  double trailHz = 10;

  // 计时
  double _t = 0;

  // 贴图朝向偏移（如果贴图不是朝右，调这个值；例如朝上设为 -pi/2）
  double spriteHeadingOffset = 0;

  @override
  Future<void> onLoad() async {
    // 基于画面尺寸设定显示大小
    final imgSize = sprite!.srcSize;
    final shortestSide = min(gameRef.size.x, gameRef.size.y);
    final targetWidth = shortestSide / 6;
    final scaleFactor = targetWidth / imgSize.x;
    size = imgSize * scaleFactor;

    // 初始位置：屏幕内随机
    position = position == Vector2.zero()
        ? _randomPointInScreen(margin: boundaryMargin + size.x)
        : position;

    // 初始速度与朝向
    final startDir = _randomAngleUnit();
    _currentSpeed = _randRange(minCruiseSpeed, maxCruiseSpeed);
    _velocity = startDir * _currentSpeed;
    _headingAngle = atan2(_velocity.y, _velocity.x);

    // 初始化 4 个控制点，保证第一段从 p1->p2 连续
    _p1 = position.clone();
    _p0 = _p1 - startDir * _randRange(minSegmentLen * 0.6, minSegmentLen);
    _p2 = _p1 + startDir * _randRange(minSegmentLen, maxSegmentLen);
    _p3 = _p2 + startDir * _randRange(minSegmentLen, maxSegmentLen);
    _clampIntoScreen(_p0);
    _clampIntoScreen(_p1);
    _clampIntoScreen(_p2);
    _clampIntoScreen(_p3);

    _u = 0;
    _segmentLength = _estimateSegmentLength(_p0, _p1, _p2, _p3);

    // 初始位置对齐样条（u=0 等于 p1）
    position = _p1.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dt <= 0) return;

    _t += dt;
    _dashCooldownTimer = max(0, _dashCooldownTimer - dt);

    // 偶发冲刺
    if (!_isDashing && _dashCooldownTimer == 0) {
      if (_random.nextDouble() < spontaneousDashChancePerSec * dt) {
        _triggerDash(direction: _tangentAt(_p0, _p1, _p2, _p3, _u).normalized());
      }
    }

    // 速度轻微起伏（非冲刺）
    if (!_isDashing) {
      final jitter = sin(_t * 2 * pi * speedJitterHz) * speedJitterAmp;
      final targetCruise = _currentSpeed.clamp(minCruiseSpeed, maxCruiseSpeed) + jitter;
      _currentSpeed = _lerpDouble(_currentSpeed, targetCruise.toDouble(), 0.05);
    }

    // 当前希望的世界速度
    final targetSpeed = _isDashing ? dashSpeed : _currentSpeed;
    final worldStep = targetSpeed * dt;

    // 把世界位移换算成 du（样条参数增量），可能跨多段
    double remainingWorld = worldStep;
    int safety = 0;
    while (remainingWorld > 0 && safety++ < 6) { // 最多跨 6 段，防误差死循环
      final segLen = max(1e-3, _segmentLength);
      final du = remainingWorld / segLen;

      if (_u + du < 1.0) {
        _u += du;
        remainingWorld = 0;
      } else {
        final usedWorld = (1.0 - _u) * segLen;
        remainingWorld = max(0, remainingWorld - usedWorld);
        _advanceSegment(); // 进入下一段
      }
    }

    // 样条上的位置与切线
    final pos = _catmullRom(_p0, _p1, _p2, _p3, _u);
    final tan = _tangentAt(_p0, _p1, _p2, _p3, _u);
    position = pos;
    final tanLen = tan.length;
    _velocity = tanLen > 1e-4 ? tan / tanLen * targetSpeed : _velocity;

    // 平滑朝向
    final desiredAngle = atan2(_velocity.y, _velocity.x);
    _headingAngle = _rotateTowards(_headingAngle, desiredAngle, maxTurnRate * dt);

    // 冲刺计时
    if (_isDashing) {
      _dashTimer += dt;
      if (_dashTimer >= dashDuration) {
        _isDashing = false;
        _dashTimer = 0;
      }
    }

    // 屏幕内夹紧（位置来自样条，一般已在内）
    position.x = position.x
        .clamp(size.x / 2, gameRef.size.x - size.x / 2)
        .toDouble();
    position.y = position.y
        .clamp(size.y / 2, gameRef.size.y - size.y / 2)
        .toDouble();

    // 尾摆 + 渲染角
    _tailPhase += dt * 2 * pi * tailHz * (_isDashing ? 1.7 : 1.0);
    final tailSwing = sin(_tailPhase) * tailAngleAmp;
    angle = _headingAngle + tailSwing + spriteHeadingOffset;

    // 呼吸缩放
    _breathPhase += dt * 2 * pi * breathHz;
    scale = Vector2.all(1 + sin(_breathPhase) * breathScaleAmp);

    // 水迹粒子
    _trailTimer += dt;
    if (_trailTimer >= 1 / trailHz) {
      _trailTimer = 0;
      _spawnTrail();
    }
  }

  // 点击/外部触发：冲刺到目标点（连续：仅加速并让后续控制点朝该方向偏置）
  void dashTo(Vector2 worldTarget) {
    final dir = (worldTarget - position);
    if (dir.length2 > 1e-6) {
      _dashBiasDirection = dir.normalized();
      _biasPointsLeft = 2; // 后续 2 个控制点朝点击方向偏置
      _triggerDash(direction: dir);
    }
  }

  void _triggerDash({required Vector2 direction}) {
    _isDashing = true;
    _dashTimer = 0;
    _dashCooldownTimer = dashCooldown;
    // 速度由样条切线确定；这里不直接改 _velocity 的方向，保持路径连续
  }

  // 进入下一段：窗口前移，并新增一个连续控制点，保证起点=上一段终点
  void _advanceSegment() {
    // 保证段连续：上一段终点就是下一段起点（Catmull-Rom: u=1 -> p2）
    final lastEnd = _catmullRom(_p0, _p1, _p2, _p3, 1.0);
    _p0 = _p1;
    _p1 = _p2;
    _p2 = _p3;
    _p3 = _generateNextControlPoint(fromPoint: lastEnd, prevDir: (_p2 - _p1));

    _u = 0;
    _segmentLength = _estimateSegmentLength(_p0, _p1, _p2, _p3);
  }

  // 生成下一个控制点：基于上一个段末方向 + 轻微随机 + 边界回拉 + 冲刺偏置
  Vector2 _generateNextControlPoint({
    required Vector2 fromPoint,
    required Vector2 prevDir,
  }) {
    Vector2 baseDir = prevDir.length2 > 1e-6 ? prevDir.normalized() : _randomAngleUnit();

    // 冲刺偏置（若存在）
    if (_dashBiasDirection != null && _biasPointsLeft > 0) {
      baseDir = (baseDir * 0.2 + _dashBiasDirection! * 0.8).normalized();
      _biasPointsLeft -= 1;
      if (_biasPointsLeft <= 0) _dashBiasDirection = null;
    }

    // 随机小转角
    final angleDelta = _randRange(-maxTurnPerPoint, maxTurnPerPoint);
    baseDir = baseDir..rotate(angleDelta);

    // 边界中心偏置（生成点更趋向画面中部，避免贴边久停）
    final center = gameRef.size / 2;
    final toCenter = (center - fromPoint).normalized();
    baseDir = ((baseDir * (1 - boundaryBiasStrength)) + (toCenter * boundaryBiasStrength))
        .normalized();

    // 段长度
    final segLen = _randRange(minSegmentLen, maxSegmentLen);
    Vector2 pNext = fromPoint + baseDir * segLen;

    _clampIntoScreen(pNext);
    return pNext;
  }

  // 样条位置
  Vector2 _catmullRom(Vector2 p0, Vector2 p1, Vector2 p2, Vector2 p3, double t) {
    final t2 = t * t;
    final t3 = t2 * t;
    final a = p1 * 2.0;
    final b = (p2 - p0) * t;
    final c = (p0 * 2.0 - p1 * 5.0 + p2 * 4.0 - p3) * t2;
    final d = (-p0 + p1 * 3.0 - p2 * 3.0 + p3) * t3;
    return (a + b + c + d) * 0.5;
  }

  // 样条切线（导数）
  Vector2 _tangentAt(Vector2 p0, Vector2 p1, Vector2 p2, Vector2 p3, double t) {
    final t2 = t * t;
    final a = (p2 - p0);
    final b = (p0 * 4.0 - p1 * 10.0 + p2 * 8.0 - p3 * 2.0) * t;
    final c = (-p0 * 3.0 + p1 * 9.0 - p2 * 9.0 + p3 * 3.0) * t2;
    return (a + b + c) * 0.5;
  }

  // 估算当前段长度（采样）
  double _estimateSegmentLength(Vector2 p0, Vector2 p1, Vector2 p2, Vector2 p3) {
    const int samples = 10;
    Vector2 prev = _catmullRom(p0, p1, p2, p3, 0);
    double length = 0;
    for (int i = 1; i <= samples; i++) {
      final t = i / samples;
      final cur = _catmullRom(p0, p1, p2, p3, t);
      length += (cur - prev).length;
      prev = cur;
    }
    return max(length, 1e-3);
  }

  // 保证点在屏幕内（留出 margin）
  void _clampIntoScreen(Vector2 p) {
    p.x = p.x.clamp(boundaryMargin + size.x / 2, gameRef.size.x - boundaryMargin - size.x / 2).toDouble();
    p.y = p.y.clamp(boundaryMargin + size.y / 2, gameRef.size.y - boundaryMargin - size.y / 2).toDouble();
  }

  // 水迹粒子
  void _spawnTrail() {
    final backDir = _velocity.length2 > 0 ? -_velocity.normalized() : Vector2(-1, 0);
    final spawnPos = position + backDir * (size.x * 0.25);
    final color = const Color(0x22FFFFFF);
    final life = 0.5 + _random.nextDouble() * 0.4;
    final speed = 12 + _random.nextDouble() * 18;

    final particle = Particle.generate(
      count: 1,
      lifespan: life,
      generator: (i) {
        final dir = backDir.clone()
          ..rotate((_random.nextDouble() - 0.5) * 0.6);
        return AcceleratedParticle(
          position: spawnPos.clone(),
          speed: dir * speed,
          acceleration: -dir * (speed * 0.8),
          child: CircleParticle(
            radius: 1.6,
            paint: Paint()
              ..color = color
              ..filterQuality = FilterQuality.low,
          ),
        );
      },
    );

    parent?.add(ParticleSystemComponent(particle: particle));
  }

  // 工具
  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

  Vector2 _randomPointInScreen({double margin = 0}) {
    return Vector2(
      _randRange(margin + size.x / 2, gameRef.size.x - margin - size.x / 2),
      _randRange(margin + size.y / 2, gameRef.size.y - margin - size.y / 2),
    );
  }

  double _randRange(double min, double max) => min + _random.nextDouble() * (max - min);

  Vector2 _randomAngleUnit() {
    final a = _randRange(0, 2 * pi);
    return Vector2(cos(a), sin(a));
  }

  double _rotateTowards(double from, double to, double maxDelta) {
    double delta = (to - from + pi) % (2 * pi) - pi;
    if (delta > maxDelta) delta = maxDelta;
    if (delta < -maxDelta) delta = -maxDelta;
    return from + delta;
  }
}