import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:fish_earn/utils/net/EventManager.dart';
import 'package:fish_earn/utils/net/HttpManager.dart';

import 'LogUtils.dart';

class FirebaseManager{

  Future<void> getInstallReferrerWithRetry({
    int maxRetry = 3,
    Duration delay = const Duration(seconds: 3),
  }) async {
    int attempt = 0;

    while (attempt < maxRetry) {
      try {
        attempt++;
        LogUtils.logD("retry $attempt  Install Referrer...");
        final referrerDetails = await AndroidPlayInstallReferrer.installReferrer;
        LogUtils.logD("Install Referrer success: $referrerDetails");
        EventManager.instance.install(referrerDetails);
        return; // 成功直接返回
      } catch (e) {
        LogUtils.logD("Install Referrer fail: $e");
        if (attempt >= maxRetry) {
          LogUtils.logD("Install Referrer fail: max number giving up.");
          rethrow;
        }
        await Future.delayed(delay);
      }
    }
  }
}