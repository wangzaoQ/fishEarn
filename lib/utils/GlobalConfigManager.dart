import 'dart:async';
import 'dart:ui';

class GlobalConfigManager{
  // 私有构造函数
  GlobalConfigManager._();

  // 全局唯一实例
  static final GlobalConfigManager instance = GlobalConfigManager._();

  bool _isBrazil = false;

  // 初始化监听系统 Locale 变化
  void init() {
    PlatformDispatcher.instance.onLocaleChanged = () {
      _updateBrazilStatus();
    };
    _updateBrazilStatus(); // 首次计算
  }

  // 外部调用
  bool isBrazilUser() => _isBrazil;

  // 内部更新逻辑
  void _updateBrazilStatus() {
    final localeTag = PlatformDispatcher.instance.locale.toLanguageTag();
    _isBrazil = localeTag.startsWith('pt-BR');
  }

  String getCommonCoin(){
    return "+\$0.001/1s";
  }
}