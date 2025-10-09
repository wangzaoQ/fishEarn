import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// GamePearlPop
/// - 首次中间静止，点击开始
/// - 前 (N-1) 圈为全范围摆动（local）
/// - 最后一圈平滑靠近 target（连续，不突跳）
/// - 到达 target 后启动短时的缓慢阻尼晃动（settle），再固定到目标
class GamePearlPop extends StatefulWidget {
  final int pearlCount;
  final Duration totalDuration;
  final int targetIndex; // 0..4
  final int wobbleCount; // 完整振荡圈数（例如 3 表示 3 圈）

  const GamePearlPop({
    super.key,
    required this.pearlCount,
    required this.targetIndex,
    this.wobbleCount = 3,
    this.totalDuration = const Duration(seconds: 3),
  });

  @override
  State<GamePearlPop> createState() => _GamePearlPopState();
}

class _GamePearlPopState extends State<GamePearlPop>
    with TickerProviderStateMixin {
  // ======= 可调参数（按需微调） =======
  final Curve baselineCurve = Curves.easeInOut; // 最后一圈基线曲线
  final double amplitudeRatio = 0.95; // 前几圈振幅相对于半跨距
  // settle（最后微摆）参数
  final Duration settleDuration = const Duration(milliseconds: 800);
  final double settleAmpRatio = 0.06; // 相对于 moduleAngle 的小幅度（微摆幅度）
  final double settleDecay = 5.0; // 指数衰减系数（越大衰减越快）
  final int settleCycles = 2; // 微摆的完整往返圈数
  // =====================================

  static const double leftLimit = -70 * pi / 180;
  static const double rightLimit = 70 * pi / 180;
  static const int moduleCount = 5;
  static final double moduleAngle = (rightLimit - leftLimit) / moduleCount;

  late final AnimationController _mainController; // 主动画（前几圈 + 最后一圈靠近）
  late final AnimationController _settleController; // 到达后的小幅阻尼晃动
  late final CombinedListenable _combined; // 同时监听两个 controller 的变更

  // 初始显示角度（首次中间）
  double _currentAngle = (leftLimit + rightLimit) / 2;

  // 缓存主动画开始时的固定起点与目标（避免 builder 中反复修改）
  double? _animStartAngle;
  double? _animTargetAngle;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(vsync: this);
    _settleController = AnimationController(vsync: this);
    _combined = CombinedListenable([_mainController, _settleController]);
  }

  @override
  void dispose() {
    _combined.dispose();
    _mainController.dispose();
    _settleController.dispose();
    super.dispose();
  }

  double _clampToLimits(double v) => v.clamp(leftLimit, rightLimit);

  /// 主动画的连续角度计算（与之前相同）
  double _computeAngleAt(double t, double animStart, double animTarget, int cycles) {
    t = t.clamp(0.0, 1.0);

    // 最后一圈开始的 t（cycles = 完整圈数）
    final double lastStartT = (cycles <= 1) ? 0.0 : (cycles - 1) / cycles;
    final double maxSpan = (rightLimit - leftLimit) / 2;
    final double fullAmp = maxSpan * amplitudeRatio;

    double baseline;
    double amp;

    if (t < lastStartT) {
      baseline = animStart;
      amp = fullAmp;
    } else {
      final double nt = (lastStartT == 1.0) ? 1.0 : ((t - lastStartT) / (1.0 - lastStartT)).clamp(0.0, 1.0);
      final double curved = baselineCurve.transform(nt);
      baseline = animStart + (animTarget - animStart) * curved;
      amp = fullAmp * (1.0 - nt * nt); // 平滑衰减到 0
    }

    // sin 的频率为 cycles，总共 cycles 个完整往返
    final double oscillation = amp * sin(2 * pi * cycles * t);

    return _clampToLimits(baseline + oscillation);
  }

  /// settle（到达目标后的微摆）计算：s ∈ [0,1]
  double _computeSettleAngle(double s, double target) {
    s = s.clamp(0.0, 1.0);
    // 小振幅 = moduleAngle * settleAmpRatio
    final double smallAmp = moduleAngle * settleAmpRatio;
    // 指数衰减，带 sin 振荡
    final double amp = smallAmp * exp(-settleDecay * s);
    final double oscillation = amp * sin(2 * pi * settleCycles * s);
    return _clampToLimits(target + oscillation);
  }

  /// 启动主动画（缓存起点与目标，支持中断衔接）
  void _setupMainAnim() {
    var targetIndex = 0;
    final int cycles = max(1, widget.wobbleCount);
    final double targetAngle = leftLimit + moduleAngle * (targetIndex + 0.5);

    // 若主动画或 settle 正在运行：先计算当前显示角度作为新起点
    if ((_mainController.isAnimating || _settleController.isAnimating) &&
        _animStartAngle != null &&
        _animTargetAngle != null) {
      // 使用当前 controller 值和已缓存的 animStart/animTarget 来算当前显示角度
      final double curT = _mainController.isAnimating ? _mainController.value.clamp(0.0, 1.0) : 1.0;
      final double curAngle = _computeAngleAt(curT, _animStartAngle!, _animTargetAngle!, cycles);
      _currentAngle = curAngle;
      // 停止当前所有控制器
      _mainController.stop();
      _settleController.stop();
      _mainController.reset();
      _settleController.reset();
    }

    // 缓存新的起点与目标（固定值）
    _animStartAngle = _currentAngle;
    _animTargetAngle = targetAngle;

    // 取消任何正在进行的 settle
    if (_settleController.isAnimating) {
      _settleController.stop();
      _settleController.reset();
    }

    // 配置并启动主 controller
    _mainController.duration = widget.totalDuration;
    _mainController.reset();
    _mainController.forward(from: 0).whenComplete(() {
      // 主动画到达“结束”时（理论上已在目标），不要直接固定到目标，改为启动 settle 微摆
      _startSettle();
    });

    setState(() {}); // 触发 AnimatedBuilder 去监听 controller
  }

  /// 启动 settle（到达目标后的小幅阻尼晃动），完成后固定在目标并清缓存
  void _startSettle() {
    // 如果没有目标就直接返回（理论不会发生）
    if (_animTargetAngle == null) {
      return;
    }

    // 配置 settle controller
    _settleController.duration = settleDuration;
    _settleController.reset();
    _settleController.forward(from: 0).whenComplete(() {
      // settle 结束，固定到目标并清缓存
      setState(() {
        _currentAngle = _animTargetAngle!;
        _animStartAngle = null;
        _animTargetAngle = null;
        _settleController.reset();
      });
    });
  }

  void _onSpinPressed() {
    // 新触发：中断并开始新动画
    if (_mainController.isAnimating || _settleController.isAnimating) {
      // will be handled in _setupMainAnim
    }
    _setupMainAnim();
  }

  @override
  Widget build(BuildContext context) {
    final int cycles = max(1, widget.wobbleCount);

    return Stack(
      children: [
        Positioned(
          left: 12.5.w,
          right: 12.5.w,
          top: 173.h,
          child: SizedBox(
            width: double.infinity,
            height: 350.h,
            child: Stack(
              children: [
                Image.asset(
                  "assets/images/bg_pearl.webp",
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fill,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 92.h),
                    child: AnimatedBuilder(
                      // 监听主+settle 两个 controller（CombinedListenable 会在它们任一 tick 时触发）
                      animation: _combined,
                      builder: (context, child) {
                        // 如果 settle 在跑 -> 使用 settle 计算（在微摆阶段）
                        if (_settleController.isAnimating && _animTargetAngle != null) {
                          final double s = _settleController.value.clamp(0.0, 1.0);
                          final double angle = _computeSettleAngle(s, _animTargetAngle!);
                          return Transform.rotate(
                            angle: angle,
                            alignment: const Alignment(0, 1),
                            child: child,
                          );
                        }

                        // 否则如果主动画在跑 -> 使用主动画计算
                        if (_mainController.isAnimating && _animStartAngle != null && _animTargetAngle != null) {
                          final double t = _mainController.value.clamp(0.0, 1.0);
                          final double angle = _computeAngleAt(t, _animStartAngle!, _animTargetAngle!, cycles);
                          return Transform.rotate(
                            angle: angle,
                            alignment: const Alignment(0, 1),
                            child: child,
                          );
                        }

                        // 否则显示当前角度（静止）
                        return Transform.rotate(
                          angle: _currentAngle,
                          alignment: const Alignment(0, 1),
                          child: child,
                        );
                      },
                      child: Image.asset(
                        "assets/images/ic_pearl_arrow.webp",
                        width: 133.w,
                        height: 163.h,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 珍珠数量
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 536.h),
            child: Stack(
              children: [
                Image.asset(
                  "assets/images/bg_pearl_num.webp",
                  width: 88.w,
                  height: 35.h,
                  fit: BoxFit.fill,
                ),
                Positioned(
                  left: 49.w,
                  top: 8.h,
                  child: Text(
                    "${widget.pearlCount}",
                    style: TextStyle(
                      color: const Color(0xFF561C3E),
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 按钮
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 589.h),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              pressedOpacity: 0.7,
              onPressed: _onSpinPressed,
              child: SizedBox(
                width: 172.w,
                height: 50.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset("assets/images/bg_confirm.webp"),
                    Center(
                      child: Text(
                        "app_spin",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF185F11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 简单的 CombinedListenable：把多个 Listenable 合并为一个
class CombinedListenable implements Listenable {
  final List<Listenable> _listenables;
  final List<VoidCallback> _listeners = [];
  CombinedListenable(this._listenables) {
    for (final l in _listenables) {
      l.addListener(_notify);
    }
  }
  void _notify() {
    for (final cb in List<VoidCallback>.from(_listeners)) {
      try {
        cb();
      } catch (_) {}
    }
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void dispose() {
    for (final l in _listenables) {
      try {
        l.removeListener(_notify);
      } catch (_) {}
    }
    _listeners.clear();
  }
}
