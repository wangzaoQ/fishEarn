import 'package:flutter/material.dart';

class BasePopView {
  Future<T?> showScaleDialog<T>({
    required BuildContext context,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutBack,
    bool barrierDismissible = true,
    Color barrierColor = Colors.black,
    double needAlpha = 0.5,
    Function(T? result)? backResult,
  }) {
    final future = showGeneralDialog<T>(
      context: context,
      barrierLabel: "ScaleDialog",
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor.withAlpha((255 * needAlpha).toInt()),
      transitionDuration: duration,
      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: child,
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: curve),
            child: child,
          ),
        );
      },
    );

    future.then((value) {
      if (backResult != null) {
        backResult(value);
      }
    });

    return future;
  }

}
