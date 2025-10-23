import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pd_platform_interface.dart';

/// An implementation of [PdPlatform] that uses method channels.
class MethodChannelPd extends PdPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pd');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
