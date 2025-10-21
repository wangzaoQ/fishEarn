/**
 * - 控制参数
    hiqcywhk：广告展示频次控制参数，用户单日内观看广告频次超过该上限后，不再展示广告
    kbzdcypz：广告点击频次控制参数，单日内观看广告频次超过该上限后，不再展示广告
    fixrn_switch：激励场景竞价展示开关，枚举值：true/false；true-仅激励场景进行插屏广告和激励广告竞价，价高者展示；false-激励场景展示激励广告（激励类广告内部竞价），插屏场景展示插屏广告（插屏类广告内部竞价）
    - 广告单元内参数
    igteaams：广告单元ID
    wdlwgunk：广告单元对应的广告平台【admob、max、topon、tradplus】
    uwkcopbx：广告类型【interstitial为插屏类型，native为原生类型，reward为激励视频类型】
    qiyjwfor：广告库存过期时间，单位秒【建议开屏类型设置为13800，其他类型设为3000】

 */
class ADData {
  final int hiqcywhk;
  final int kbzdcypz;
  final bool fixrn_switch;
  final List<ADRequestData> fixrn_int;
  final List<ADRequestData> fixrn_rv;

  ADData({
    required this.hiqcywhk,
    required this.kbzdcypz,
    required this.fixrn_switch,
    required this.fixrn_int,
    required this.fixrn_rv,
  });

  factory ADData.fromJson(Map<String, dynamic> json) {
    return ADData(
      hiqcywhk: json['hiqcywhk'] ?? 0,
      kbzdcypz: json['kbzdcypz'] ?? 0,
      fixrn_switch: json['fixrn_switch'] ?? false,
      fixrn_int: (json['fixrn_int'] as List<dynamic>?)
          ?.map((e) => ADRequestData.fromJson(e))
          .toList() ??
          [],
      fixrn_rv: (json['fixrn_rv'] as List<dynamic>?)
          ?.map((e) => ADRequestData.fromJson(e))
          .toList() ??
          [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'hiqcywhk': hiqcywhk,
      'kbzdcypz': kbzdcypz,
      'fixrn_switch': fixrn_switch,
      'fixrn_int': fixrn_int.map((e) => e.toJson()).toList(),
      'fixrn_rv': fixrn_rv.map((e) => e.toJson()).toList(),
    };
  }
}

class ADRequestData {
  final String igteaams;
  final String wdlwgunk;
  final String uwkcopbx;
  final int qiyjwfor;

  ADRequestData({
    required this.igteaams,
    required this.wdlwgunk,
    required this.uwkcopbx,
    required this.qiyjwfor,
  });

  @override
  String toString() {
    return 'ADRequestData(id: $igteaams, plantform: $wdlwgunk, adType: $uwkcopbx)';
  }

  factory ADRequestData.fromJson(Map<String, dynamic> json) {
    return ADRequestData(
      igteaams: json['igteaams'] ?? '',
      wdlwgunk: json['wdlwgunk'] ?? '',
      uwkcopbx: json['uwkcopbx'] ?? '',
      qiyjwfor: json['qiyjwfor'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'igteaams': igteaams,
      'wdlwgunk': wdlwgunk,
      'uwkcopbx': uwkcopbx,
      'qiyjwfor': qiyjwfor,
    };
  }
}
