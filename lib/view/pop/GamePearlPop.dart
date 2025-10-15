import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/view/pop/GameAward.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../task/TaskManager.dart';
import '../GameText.dart';
import 'BasePopView.dart';

/// GamePearlPop
/// - 首次中间静止，点击开始
/// - 前 (N-1) 圈为全范围摆动（local）
/// - 最后一圈平滑靠近 target（连续，不突跳）
/// - 到达 target 后启动短时的缓慢阻尼晃动（settle），再固定到目标
class GamePearlPop extends StatefulWidget {
  final int pearlCount;
  final Duration totalDuration;
  final int targetIndex; // 0..5; 若传入无效则随机
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

  late final VoidCallback onFinish; // ✅ 新增：动画结束回调

  // ======= 可调参数（按需微调） =======
  final Curve baselineCurve = Curves.easeInOut; // 最后一圈基线曲线
  final double amplitudeRatio = 0.95; // 前几圈振幅相对于半跨距
  // settle（最后微摆）参数
  final Duration settleDuration = const Duration(milliseconds: 800);
  final double settleAmpRatio = 0.06; // 相对于 moduleAngle 的小幅度（微摆幅度）
  final double settleDecay = 5.0; // 指数衰减系数（越大衰减越快）
  final int settleCycles = 2; // 微摆的完整往返圈数

  // pre-transition 参数（用于平滑从当前角度过渡到带 bias 的起点）
  final Duration preDuration = const Duration(milliseconds: 150);
  final Curve preCurve = Curves.easeOut;

  // =====================================

  static const double leftLimit = -90 * pi / 180;
  static const double rightLimit = 90 * pi / 180;
  static const int moduleCount = 5;
  static final double moduleAngle = (rightLimit - leftLimit) / moduleCount;

  late final AnimationController _mainController; // 主动画（前几圈 + 最后一圈靠近）
  late final AnimationController _settleController; // 到达后的小幅阻尼晃动
  late final AnimationController _preController; // 平滑偏移过渡（短）
  late final CombinedListenable _combined; // 同时监听 controllers 的变更

  // 初始显示角度（首次中点）
  double _currentAngle = (leftLimit + rightLimit) / 2;

  // 缓存主动画开始时的固定起点与目标（避免 builder 中反复修改）
  double? _animStartAngle;
  double? _animTargetAngle;

  // 记录 pre 的 listener，便于移除
  VoidCallback? _preListener;

  @override
  void initState() {
    super.initState();
    foodIndex = random.nextInt(4);
    _mainController = AnimationController(vsync: this);
    _settleController = AnimationController(vsync: this);
    _preController = AnimationController(vsync: this);
    _combined = CombinedListenable([
      _mainController,
      _settleController,
      _preController,
    ]);
  }

  @override
  void dispose() {
    // 清理 pre listener
    if (_preListener != null) {
      try {
        _preController.removeListener(_preListener!);
      } catch (_) {}
      _preListener = null;
    }
    _combined.dispose();
    _mainController.dispose();
    _settleController.dispose();
    _preController.dispose();
    super.dispose();
  }

  double _clampToLimits(double v) => v.clamp(leftLimit, rightLimit).toDouble();

  /// 主动画的连续角度计算（与之前相同）
  double _computeAngleAt(
    double t,
    double animStart,
    double animTarget,
    int cycles,
  ) {
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
      final double nt = (lastStartT == 1.0)
          ? 1.0
          : ((t - lastStartT) / (1.0 - lastStartT)).clamp(0.0, 1.0);
      final double curved = baselineCurve.transform(nt);
      baseline = animStart + (animTarget - animStart) * curved;
      amp = fullAmp * (1.0 - nt * nt); // 平滑衰减到 0
    }

    // sin 的频率为 cycles，总共 cycles 个完整往返
    final double oscillation = fullAmp == 0
        ? 0.0
        : (fullAmp * sin(2 * pi * cycles * t) * (amp / fullAmp));
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

  /// 启动主动画（接受可选 incomingTargetIndex）
  /// 折中方案：如果传入 incomingTargetIndex，则起点使用 (midPoint + _currentAngle)/2，
  /// 既不会强制瞬移到中点，也不会完全从当前角度衔接（避免范围被限定）。
  void _setupMainAnim([int? incomingTargetIndex]) {
    final int cycles = max(1, widget.wobbleCount);

    // 1) 确定目标索引：优先使用传入参数；若为 null 则使用 widget.targetIndex（若不合法再随机）
    int newTargetIndex;
    if (incomingTargetIndex != null &&
        incomingTargetIndex >= 0 &&
        incomingTargetIndex < moduleCount) {
      newTargetIndex = incomingTargetIndex;
    } else if (widget.targetIndex >= 0 && widget.targetIndex < moduleCount) {
      newTargetIndex = widget.targetIndex;
    } else {
      newTargetIndex = Random().nextInt(moduleCount);
    }
    final double targetAngle = leftLimit + moduleAngle * (newTargetIndex + 0.5);

    // 判断是否为“中断重启”（之前正在跑）
    final bool wasAnimating =
        _mainController.isAnimating ||
        _settleController.isAnimating ||
        _preController.isAnimating;

    // 计算起点：若传入 incomingTargetIndex 则使用折中起点；否则按当前 controllers 计算 visual startAngle（以做到平滑中断/续接）
    final double midPoint = (leftLimit + rightLimit) / 2;
    double startAngle;

    if (incomingTargetIndex != null) {
      // 之前：startAngle = (midPoint + _currentAngle) / 2.0;
      // 改为：每次强制从中点开始（保证每次 full-range 摆动）
      startAngle = midPoint;

      // 清理并重置 controllers（避免残留 listener）
      _mainController.stop();
      _settleController.stop();
      if (_preListener != null) {
        try {
          _preController.removeListener(_preListener!);
        } catch (_) {}
        _preListener = null;
      }
      _preController.stop();
      _mainController.reset();
      _settleController.reset();
      _preController.reset();

      // 直接缓存起点与目标并启动主动画（不走 pre-bias）
      _animStartAngle = startAngle;
      _animTargetAngle = targetAngle;

      // 立即更新当前角度以保证 UI 不会瞬跳（动画由 mainController 驱动）
      setState(() {
        _currentAngle = startAngle;
      });

      _mainController.duration = widget.totalDuration;
      _mainController.reset();
      _mainController.forward(from: 0).whenComplete(_startSettle);

      return;
    }

    // ------------------------
    // 否则（incomingTargetIndex == null）走智能衔接逻辑：
    if (_preController.isAnimating && _animStartAngle != null) {
      startAngle = _animStartAngle!;
    } else if (_mainController.isAnimating &&
        _animStartAngle != null &&
        _animTargetAngle != null) {
      final double curT = _mainController.value.clamp(0.0, 1.0);
      startAngle = _computeAngleAt(
        curT,
        _animStartAngle!,
        _animTargetAngle!,
        cycles,
      );
    } else if (_settleController.isAnimating && _animTargetAngle != null) {
      final double s = _settleController.value.clamp(0.0, 1.0);
      startAngle = _computeSettleAngle(s, _animTargetAngle!);
    } else {
      startAngle = _currentAngle;
    }

    // 清理并重置 controller（同原逻辑）
    _mainController.stop();
    _settleController.stop();
    if (_preListener != null) {
      try {
        _preController.removeListener(_preListener!);
      } catch (_) {}
      _preListener = null;
    }
    _preController.stop();
    _mainController.reset();
    _settleController.reset();
    _preController.reset();

    // 只有在“中断重开”时，且起点与目标太接近，才人工拉开距离（bias）
    final double diff = (targetAngle - startAngle).abs();
    final double span = (rightLimit - leftLimit) / 2;
    final bool needBias = wasAnimating && diff < span * 0.2;

    if (!needBias) {
      _animStartAngle = startAngle;
      _animTargetAngle = targetAngle;
      _mainController.duration = widget.totalDuration;
      _mainController.reset();
      _mainController.forward(from: 0).whenComplete(_startSettle);
    } else {
      // 原有 pre-bias 平滑流程（保留）
      final double biasDir = Random().nextBool() ? 1.0 : -1.0;
      final double bias = biasDir * span * 0.5;
      final double biasedStart = _clampToLimits(startAngle + bias);

      _animTargetAngle = targetAngle;

      _preController.duration = preDuration;
      _preController.reset();

      // 准备并记录 listener，以便之后能 remove
      _preListener = () {
        final double v = _preController.value.clamp(0.0, 1.0);
        final double interpolated =
            startAngle + (biasedStart - startAngle) * preCurve.transform(v);
        _animStartAngle = interpolated;
      };

      _preController.addListener(_preListener!);

      _preController.forward(from: 0).whenComplete(() {
        // 移除 listener 并清空记录
        if (_preListener != null) {
          try {
            _preController.removeListener(_preListener!);
          } catch (_) {}
          _preListener = null;
        }
        // 确保起点为最终 biasedStart
        _animStartAngle = biasedStart;
        // 启动主动画
        _mainController.duration = widget.totalDuration;
        _mainController.reset();
        _mainController.forward(from: 0).whenComplete(_startSettle);
      });
    }

    setState(() {});
  }

  /// 启动 settle（到达目标后的小幅阻尼晃动），完成后固定在目标并清缓存
  void _startSettle() {
    if (_animTargetAngle == null) return;

    _settleController.duration = settleDuration;
    _settleController.reset();
    _settleController.forward(from: 0).whenComplete(() {
      setState(() {
        _currentAngle = _animTargetAngle!;
        _animStartAngle = null;
        _animTargetAngle = null;
        _settleController.reset();
        isRunning = false; // ✅ 解锁可再次点击
      });
      Navigator.pop(context,foodIndex == targetIndex? -1:20);
    });
  }

  var isRunning = false;
  var targetIndex = 2;
  var foodIndex = 0;
  var random = Random();
  /// 点击触发：接受可选 targetIndex 并传给 _setupMainAnim
  void _onSpinPressed() {
    if(isRunning)return;
    isRunning = true;
    TaskManager.instance.addTask("spins");
    if(widget.pearlCount <=0){
      isRunning = false;
      Navigator.pop(context,-2);
      return;
    }
    targetIndex = random.nextInt(5);
    _setupMainAnim(targetIndex);
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
                //target0
                Positioned(
                  left: 15.w,
                  top: 123.h,
                  child: SizedBox(
                    width: 68.w,
                    height: 68.h,
                    child: Stack(
                      children: [
                        Image.asset(
                          foodIndex == 0?"assets/images/ic_food3.webp":"assets/images/ic_coin3.webp",
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.fill,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: GameText(
                            showText: foodIndex == 0?"+30":"+\$20",
                            fontSize: 20.sp,
                            fillColor: Color(0xFFFDFF59),
                            strokeColor: Colors.black,
                            strokeWidth: 1.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //target1
                Positioned(
                  left: 52.w,
                  top: 62.h,
                  child: SizedBox(
                    width: 68.w,
                    height: 68.h,
                    child: Stack(
                      children: [
                        Image.asset(
                          foodIndex == 1?"assets/images/ic_food3.webp":"assets/images/ic_coin3.webp",
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.fill,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: GameText(
                            showText: foodIndex == 1?"+30":"+\$20",
                            fontSize: 20.sp,
                            fillColor: Color(0xFFFDFF59),
                            strokeColor: Colors.black,
                            strokeWidth: 1.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //target2
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsetsGeometry.only(top: 35.h),
                    child: SizedBox(
                      width: 68.w,
                      height: 68.h,
                      child: Stack(
                        children: [
                          Image.asset(
                            foodIndex == 2?"assets/images/ic_food3.webp":"assets/images/ic_coin3.webp",
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.fill,
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: GameText(
                              showText: foodIndex == 2?"+30":"+\$20",
                              fontSize: 20.sp,
                              fillColor: Color(0xFFFDFF59),
                              strokeColor: Colors.black,
                              strokeWidth: 1.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //target3
                Positioned(
                  right: 52.w,
                  top: 62.h,
                  child: SizedBox(
                    width: 68.w,
                    height: 68.h,
                    child: Stack(
                      children: [
                        Image.asset(
                          foodIndex == 3?"assets/images/ic_food3.webp":"assets/images/ic_coin3.webp",
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.fill,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: GameText(
                            showText: foodIndex == 3?"+30":"+\$20",
                            fontSize: 20.sp,
                            fillColor: Color(0xFFFDFF59),
                            strokeColor: Colors.black,
                            strokeWidth: 1.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //target4
                Positioned(
                  right: 15.w,
                  top: 123.h,
                  child: SizedBox(
                    width: 68.w,
                    height: 68.h,
                    child: Stack(
                      children: [
                        Image.asset(
                          foodIndex == 4?"assets/images/ic_food3.webp":"assets/images/ic_coin3.webp",
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.fill,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: GameText(
                            showText: "+\$20",
                            fontSize: 20.sp,
                            fillColor: Color(0xFFFDFF59),
                            strokeColor: Colors.black,
                            strokeWidth: 1.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 92.h),
                    child: AnimatedBuilder(
                      // 监听 main + settle + pre 三个 controller（CombinedListenable 会在它们任一 tick 时触发）
                      animation: _combined,
                      builder: (context, child) {
                        // 如果 settle 在跑 -> 使用 settle 计算（在微摆阶段）
                        if (_settleController.isAnimating &&
                            _animTargetAngle != null) {
                          final double s = _settleController.value.clamp(
                            0.0,
                            1.0,
                          );
                          final double angle = _computeSettleAngle(
                            s,
                            _animTargetAngle!,
                          );
                          return Transform.rotate(
                            angle: angle,
                            alignment: const Alignment(0,  0.2),
                            child: child,
                          );
                        }

                        // 否则如果 main 在跑 -> 使用主动画计算
                        if (_mainController.isAnimating &&
                            _animStartAngle != null &&
                            _animTargetAngle != null) {
                          final double t = _mainController.value.clamp(
                            0.0,
                            1.0,
                          );
                          final double angle = _computeAngleAt(
                            t,
                            _animStartAngle!,
                            _animTargetAngle!,
                            cycles,
                          );
                          return Transform.rotate(
                            angle: angle,
                            alignment: const Alignment(0, 0.2),
                            child: child,
                          );
                        }

                        // 如果 pre 在跑（平滑过渡到 biased 起点），我们直接用 _animStartAngle（pre listener 已更新）
                        if (_preController.isAnimating &&
                            _animStartAngle != null) {
                          return Transform.rotate(
                            angle: _animStartAngle!,
                            alignment: const Alignment(0,  0.2),
                            child: child,
                          );
                        }

                        // 否则显示当前角度（静止）
                        return Transform.rotate(
                          angle: _currentAngle,
                          alignment: const Alignment(0,  0.2),
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
              onPressed: () => _onSpinPressed(),
              child: SizedBox(
                width: 172.w,
                height: 50.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset("assets/images/bg_confirm.webp"),
                    Center(
                      child: Text(
                        "app_spin".tr(),
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
