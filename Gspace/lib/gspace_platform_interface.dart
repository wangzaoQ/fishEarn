import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'gspace_method_channel.dart';

abstract class GspacePlatform extends PlatformInterface {
  /// Constructs a GspacePlatform.
  GspacePlatform() : super(token: _token);

  static final Object _token = Object();

  static GspacePlatform _instance = MethodChannelGspace();

  /// The default instance of [GspacePlatform] to use.
  ///
  /// Defaults to [MethodChannelGspace].
  static GspacePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GspacePlatform] when
  /// they register themselves.
  static set instance(GspacePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }


  /// 打开浏览器 / intent:// 链接
  Future<void> openBrowser(String url) {
    throw UnimplementedError('openBrowser() has not been implemented.');
  }
}
