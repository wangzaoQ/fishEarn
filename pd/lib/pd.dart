
import 'pd_platform_interface.dart';

class Pd {
  Future<String?> getPlatformVersion() {
    return PdPlatform.instance.getPlatformVersion();
  }
}
