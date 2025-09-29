import 'package:flutter/material.dart';

class ArrowOverlay {
  static OverlayEntry? _entry;

  static void show(BuildContext context,Widget widget) {
    if (_entry != null) return; // 避免重复添加
    _entry = OverlayEntry(
      builder: (_) => widget,
    );
    Overlay.of(context).insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
