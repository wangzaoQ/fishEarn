import 'dart:collection';
import 'package:fish_earn/config/LocalConfig.dart';
import 'package:fish_earn/view/pop/BasePopView.dart';
import 'package:flutter/material.dart';


class PopManager {
  static final PopManager _instance = PopManager._internal();

  factory PopManager() => _instance;

  PopManager._internal();

  final Queue<_PopTask> _queue = Queue<_PopTask>();
  bool _isShowing = false;

  void show<T>({
    required BuildContext context,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutBack,
    bool barrierDismissible = true,
    Color barrierColor = Colors.black,
    double needAlpha = 0.5,
    Function(T? result)? backResult,
  }) {
    _queue.add(_PopTask<T>(
      context: context,
      child: child,
      duration: duration,
      curve: curve,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      needAlpha: needAlpha,
      backResult: backResult,
    ));

    _tryNext<T>();
  }

  void _tryNext<T>() {
    if (_isShowing || _queue.isEmpty) return;

    final task = _queue.removeFirst();
    _isShowing = true;

    BasePopView().showScaleDialog<T>(
      context: LocalConfig.globalContext!,
      child: task.child,
      duration: task.duration,
      curve: task.curve,
      barrierDismissible: task.barrierDismissible,
      barrierColor: task.barrierColor,
      needAlpha: task.needAlpha,
      backResult: (result) {
        _isShowing = false;
        task.backResult?.call(result);
        _tryNext(); // 下一弹
      },
    );
  }
}

class _PopTask<T> {
  final BuildContext context;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool barrierDismissible;
  final Color barrierColor;
  final double needAlpha;
  final Function(T? result)? backResult;

  _PopTask({
    required this.context,
    required this.child,
    required this.duration,
    required this.curve,
    required this.barrierDismissible,
    required this.barrierColor,
    required this.needAlpha,
    this.backResult,
  });
}
