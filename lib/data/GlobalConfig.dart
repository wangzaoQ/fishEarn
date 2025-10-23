class GlobalConfig {
  final int sharkAttack;
  final int protectType;

  GlobalConfig({
    required this.sharkAttack,
    required this.protectType,
  });

  factory GlobalConfig.fromJson(Map<String, dynamic> json) {
    return GlobalConfig(
      sharkAttack: json['shark_attack'] ?? 0,
      protectType: json['protect_type'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'shark_attack': sharkAttack,
    'protect_type': protectType,
  };

  /// 默认配置
  static GlobalConfig get defaultConfig => GlobalConfig(
    sharkAttack: 60,
    protectType: 1,
  );
}
