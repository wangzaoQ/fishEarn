class GlobalConfig {
  final int sharkAttack;
  final int protectType;
  final int unlimitedTime;
  final int level_1_2;
  final int level_2_3;

  GlobalConfig({
    required this.sharkAttack,
    required this.protectType,
    required this.unlimitedTime,
    required this.level_1_2,
    required this.level_2_3,
  });

  factory GlobalConfig.fromJson(Map<String, dynamic> json) {
    return GlobalConfig(
      sharkAttack: json['shark_attack'] ?? 0,
      protectType: json['protect_type'] ?? 0,
      unlimitedTime: json['unlimited_time'] ?? 0,
      level_1_2: json['level_1_2'] ?? 0,
      level_2_3: json['level_2_3'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'shark_attack': sharkAttack,
    'protect_type': protectType,
    'unlimited_time': unlimitedTime,
    'level_1_2': level_1_2,
    'level_2_3': level_2_3,
  };
}
