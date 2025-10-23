class IntAdConfig {
  final List<IntAd> intAd;

  IntAdConfig({required this.intAd});

  factory IntAdConfig.fromJson(Map<String, dynamic> json) {
    return IntAdConfig(
      intAd: (json['int_ad'] as List)
          .map((e) => IntAd.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'int_ad': intAd.map((e) => e.toJson()).toList(),
  };
}

class IntAd {
  final int firstNumber;
  final int point;
  final int endNumber;

  IntAd({
    required this.firstNumber,
    required this.point,
    required this.endNumber,
  });

  factory IntAd.fromJson(Map<String, dynamic> json) {
    return IntAd(
      firstNumber: json['first_number'] ?? 0,
      point: json['point'] ?? 0,
      endNumber: json['end_number'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'first_number': firstNumber,
    'point': point,
    'end_number': endNumber,
  };
}
