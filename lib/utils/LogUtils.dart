import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LogUtils {
  static final _logger = Logger(
    printer: PrettyPrinter(),
    level: kReleaseMode ? Level.nothing : Level.debug, // release 模式不输出
  );

  static void logI(String msg) {
    _logger.i(msg);
  }

  static void logW(String msg) {
    _logger.w(msg);
  }

  static void logD(String msg) {
    _logger.d(msg);
  }

  static void logE(String msg) {
    _logger.e(msg);
  }
}
