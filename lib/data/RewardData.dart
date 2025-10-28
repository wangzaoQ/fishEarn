import 'dart:convert';

/// 顶层配置模型
/**
 * //idle_reward3 3级挂机美秒金额
    //old_users_award 老用户离线奖励弹窗奖励
    //cash_bubble_t 现金泡泡时间
    //cash_bubble 现金泡泡
    //give_up 升级奖励
    //pearl_wheel 贝壳转盘奖金配置
    //drift_bottle 漂流瓶现金奖励
 */
class RewardData {
  final RewardSingle? idleReward2;
  final RewardSingle? idleReward3;
  final RewardRangeList? oldUsersAward;
  final RewardSingle? cashBubbleT;
  final RewardRangeList? cashBubble;
  final RewardRangeList? pearlWheel;
  final RewardRangeList? driftBottle;

  RewardData({
    this.idleReward2,
    this.idleReward3,
    this.oldUsersAward,
    this.cashBubbleT,
    this.cashBubble,
    this.pearlWheel,
    this.driftBottle,
  });




  factory RewardData.fromJson(Map<String, dynamic> json) {
    var reward = RewardData(
      idleReward2: json['idle_reward2'] != null
          ? RewardSingle.fromJson(json['idle_reward2'])
          : null,
      idleReward3: json['idle_reward3'] != null
          ? RewardSingle.fromJson(json['idle_reward3'])
          : null,
      oldUsersAward: json['old_users_award'] != null
          ? RewardRangeList.fromJson(json['old_users_award'])
          : null,
      cashBubbleT: json['cash_bubble_t'] != null
          ? RewardSingle.fromJson(json['cash_bubble_t'])
          : null,
      cashBubble: json['cash_bubble'] != null
          ? RewardRangeList.fromJson(json['cash_bubble'])
          : null,
      pearlWheel: json['pearl_wheel'] != null
          ? RewardRangeList.fromJson(json['pearl_wheel'])
          : null,
      driftBottle: json['drift_bottle'] != null
          ? RewardRangeList.fromJson(json['drift_bottle'])
          : null,
    );
    return reward;
  }

  Map<String, dynamic> toJson() => {
        'idle_reward2': idleReward2?.toJson(),
        'idle_reward3': idleReward3?.toJson(),
        'old_users_award': oldUsersAward?.toJson(),
        'cash_bubble_t': cashBubbleT?.toJson(),
        'cash_bubble': cashBubble?.toJson(),
        'pearl_wheel': pearlWheel?.toJson(),
        'drift_bottle': driftBottle?.toJson(),
      };

  static RewardData fromRawJson(String str) =>
      RewardData.fromJson(json.decode(str));
  String toRawJson() => json.encode(toJson());
}

/// 奖励列表（如 old_users_award, cash_bubble 等）
class RewardRangeList {
  final List<RewardRange> prize;

  RewardRangeList({required this.prize});

  factory RewardRangeList.fromJson(Map<String, dynamic> json) {
    var list = (json['prize'] as List<dynamic>?)
            ?.map((e) => RewardRange.fromJson(e))
            .toList() ??
        [];
    return RewardRangeList(prize: list);
  }

  Map<String, dynamic> toJson() => {
        'prize': prize.map((e) => e.toJson()).toList(),
      };
}

/// 每个范围的奖项配置
class RewardRange {
  final int firstNumber;
  final List<num> prize;
  final int endNumber;

  RewardRange({
    required this.firstNumber,
    required this.prize,
    required this.endNumber,
  });

  factory RewardRange.fromJson(Map<String, dynamic> json) => RewardRange(
        firstNumber: json['first_number'] ?? 0,
        prize: (json['prize'] as List<dynamic>?)
                ?.map((e) => e as num)
                .toList() ??
            [],
        endNumber: json['end_number'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'first_number': firstNumber,
        'prize': prize,
        'end_number': endNumber,
      };
}

/// 简单奖励结构（如 idle_reward2、idle_reward3、cash_bubble_t）
class RewardSingle {
  final List<num> prize;

  RewardSingle({required this.prize});

  factory RewardSingle.fromJson(Map<String, dynamic> json) {
    // 可能是 {"prize": [0.02]} 或 {"30"}
    if (json['prize'] != null) {
      return RewardSingle(
        prize: (json['prize'] as List<dynamic>).map((e) => e as num).toList(),
      );
    } else {
      // 兼容 {"cash_bubble_t": {30}} 这种情况
      var list = json.values.map((e) => e as num).toList();
      return RewardSingle(prize: list);
    }
  }

  Map<String, dynamic> toJson() => {'prize': prize};
}
