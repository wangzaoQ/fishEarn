import 'package:flutter_test/flutter_test.dart';
import 'package:gspace/gspace.dart';
import 'package:gspace/gspace_platform_interface.dart';
import 'package:gspace/gspace_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGspacePlatform
    with MockPlatformInterfaceMixin
    implements GspacePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final GspacePlatform initialPlatform = GspacePlatform.instance;

  test('$MethodChannelGspace is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelGspace>());
  });

  test('getPlatformVersion', () async {
    Gspace gspacePlugin = Gspace();
    MockGspacePlatform fakePlatform = MockGspacePlatform();
    GspacePlatform.instance = fakePlatform;

    expect(await gspacePlugin.getPlatformVersion(), '42');
  });
}
