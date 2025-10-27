class GlobalConfig {
  final int sharkAttack;
  final int protectType;
  final int unlimitedTime;

  GlobalConfig({
    required this.sharkAttack,
    required this.protectType,
    required this.unlimitedTime,
  });

  factory GlobalConfig.fromJson(Map<String, dynamic> json) {
    return GlobalConfig(
      sharkAttack: json['shark_attack'] ?? 0,
      protectType: json['protect_type'] ?? 0,
      unlimitedTime: json['unlimited_time'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'shark_attack': sharkAttack,
    'protect_type': protectType,
    'unlimited_time': unlimitedTime,
  };

}
