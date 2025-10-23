import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pd_method_channel.dart';

abstract class PdPlatform extends PlatformInterface {
  /// Constructs a PdPlatform.
  PdPlatform() : super(token: _token);

  static final Object _token = Object();

  static PdPlatform _instance = MethodChannelPd();

  /// The default instance of [PdPlatform] to use.
  ///
  /// Defaults to [MethodChannelPd].
  static PdPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PdPlatform] when
  /// they register themselves.
  static set instance(PdPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
