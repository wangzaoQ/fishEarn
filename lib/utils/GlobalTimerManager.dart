import 'dart:async';

class GlobalTimerManager{
  static final GlobalTimerManager _instance = GlobalTimerManager._internal();
  factory GlobalTimerManager() => _instance;
  GlobalTimerManager._internal();

  Timer? _timer;

  /// 开启定时器
  void startTimer({
    required void Function() onTick,
  }) {
    cancelTimer(); // 先取消之前的
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      onTick();
    });
  }

  /// 取消定时器
  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// 是否运行中
  bool get isRunning => _timer?.isActive ?? false;
}