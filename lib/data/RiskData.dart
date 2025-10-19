class RiskData{
  final UI ui;
  final Behavior behavior;
  final List<String> device;

  RiskData({
    required this.ui,
    required this.behavior,
    required this.device,
  });

  factory RiskData.fromJson(Map<String, dynamic> json) {
    return RiskData(
      ui: UI.fromJson(json['ui'] as Map<String, dynamic>),
      behavior: Behavior.fromJson(json['behavior'] as Map<String, dynamic>),
      device: List<String>.from(json['device'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
    'ui': ui.toJson(),
    'behavior': behavior.toJson(),
    'device': device,
  };
}
class UI {
  final int number;
  final int behavior;
  final int device;

  UI({
    required this.number,
    required this.behavior,
    required this.device,
  });

  factory UI.fromJson(Map<String, dynamic> json) {
    return UI(
      number: json['number'] as int,
      behavior: json['behavior'] as int,
      device: json['device'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'behavior': behavior,
    'device': device,
  };
}

class Behavior {
  final AdShortShow adShortShow;
  final AdShortClose adShortClose;
  final int wrongDeemAdLess;
  final int wrongDeemAdMore;
  final int noInstall;
  final int adDailyShow;

  Behavior({
    required this.adShortShow,
    required this.adShortClose,
    required this.wrongDeemAdLess,
    required this.wrongDeemAdMore,
    required this.noInstall,
    required this.adDailyShow,
  });

  factory Behavior.fromJson(Map<String, dynamic> json) {
    return Behavior(
      adShortShow: AdShortShow.fromJson(json['ad_short_show'] as Map<String, dynamic>),
      adShortClose: AdShortClose.fromJson(json['ad_short_close'] as Map<String, dynamic>),
      wrongDeemAdLess: json['wrong_deem_ad_less'] as int,
      wrongDeemAdMore: json['wrong_deem_ad_more'] as int,
      noInstall: json['no_install'] as int,
      adDailyShow: json['ad_daily_show'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'ad_short_show': adShortShow.toJson(),
    'ad_short_close': adShortClose.toJson(),
    'wrong_deem_ad_less': wrongDeemAdLess,
    'wrong_deem_ad_more': wrongDeemAdMore,
    'no_install': noInstall,
    'ad_daily_show': adDailyShow,
  };
}

class AdShortShow {
  final int duration;
  final int value;

  AdShortShow({
    required this.duration,
    required this.value,
  });

  factory AdShortShow.fromJson(Map<String, dynamic> json) {
    return AdShortShow(
      duration: json['duration'] as int,
      value: json['value'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'duration': duration,
    'value': value,
  };
}

class AdShortClose {
  final int duration;
  final int value;

  AdShortClose({
    required this.duration,
    required this.value,
  });

  factory AdShortClose.fromJson(Map<String, dynamic> json) {
    return AdShortClose(
      duration: json['duration'] as int,
      value: json['value'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'duration': duration,
    'value': value,
  };
}
