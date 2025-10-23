import 'package:flutter_test/flutter_test.dart';
import 'package:pd/pd.dart';
import 'package:pd/pd_platform_interface.dart';
import 'package:pd/pd_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPdPlatform
    with MockPlatformInterfaceMixin
    implements PdPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PdPlatform initialPlatform = PdPlatform.instance;

  test('$MethodChannelPd is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPd>());
  });

  test('getPlatformVersion', () async {
    Pd pdPlugin = Pd();
    MockPdPlatform fakePlatform = MockPdPlatform();
    PdPlatform.instance = fakePlatform;

    expect(await pdPlugin.getPlatformVersion(), '42');
  });
}
