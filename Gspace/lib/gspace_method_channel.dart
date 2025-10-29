import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'gspace_platform_interface.dart';

/// An implementation of [GspacePlatform] that uses method channels.
class MethodChannelGspace extends GspacePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('gspace');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> openBrowser(String url) async {
    try {
      await methodChannel.invokeMethod('openBrowser', {'url': url});
    } catch (e) {
      print('Gspace openBrowser error: $e');
    }
  }
}
