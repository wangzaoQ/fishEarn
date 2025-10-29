
import 'gspace_platform_interface.dart';

class Gspace {
  Future<String?> getPlatformVersion() {
    return GspacePlatform.instance.getPlatformVersion();
  }

  /// 打开浏览器 / intent:// 链接
  Future<void> openBrowser(String url) {
    return GspacePlatform.instance.openBrowser(url);
  }
}


