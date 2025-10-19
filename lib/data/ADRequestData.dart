class ADData {
  //oanywgxy：广告展示频次控制参数，用户单日内观看广告频次超过该上限后，不再展示广告
  // pohzwdhc：广告点击频次控制参数，单日内观看广告频次超过该上限后，不再展示广告
  // oxrsl_switch：激励场景竞价展示开关，枚举值：true/false；true-仅激励场景进行插屏广告和激励广告竞价，价高者展示；false-激励场景展示激励广告（激励类广告内部竞价），插屏场景展示插屏广告（插屏类广告内部竞价）
  // - 广告单元内参数
  // zgsbckua：广告单元ID
  // hxsgrrzm：广告单元对应的广告平台【admob、max、topon、tradplus】
  // rnucwtgt：广告类型【interstitial为插屏类型，native为原生类型，reward为激励视频类型】
  // bxxqcaod：广告库存过期时间，单位秒【建议开屏类型设置为13800，其他类型设为3000】
  final int oanywgxy;
  final int pohzwdhc;
  final bool oxrslSwitch;
  final List<ADRequestData> oxrslInt;
  final List<ADRequestData> oxrslRv;

  ADData({
    required this.oanywgxy,
    required this.pohzwdhc,
    required this.oxrslSwitch,
    required this.oxrslInt,
    required this.oxrslRv,
  });

  factory ADData.fromJson(Map<String, dynamic> json) {
    return ADData(
      oanywgxy: json['oanywgxy'] ?? 0,
      pohzwdhc: json['pohzwdhc'] ?? 0,
      oxrslSwitch: json['oxrsl_switch'] ?? false,
      oxrslInt: (json['oxrsl_int'] as List<dynamic>?)
          ?.map((e) => ADRequestData.fromJson(e))
          .toList() ??
          [],
      oxrslRv: (json['oxrsl_rv'] as List<dynamic>?)
          ?.map((e) => ADRequestData.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oanywgxy': oanywgxy,
      'pohzwdhc': pohzwdhc,
      'oxrsl_switch': oxrslSwitch,
      'oxrsl_int': oxrslInt.map((e) => e.toJson()).toList(),
      'oxrsl_rv': oxrslRv.map((e) => e.toJson()).toList(),
    };
  }
}

class ADRequestData {
  final String zgsbckua;
  final String hxsgrrzm;
  final String rnucwtgt;
  final int bxxqcaod;

  ADRequestData({
    required this.zgsbckua,
    required this.hxsgrrzm,
    required this.rnucwtgt,
    required this.bxxqcaod,
  });

  factory ADRequestData.fromJson(Map<String, dynamic> json) {
    return ADRequestData(
      zgsbckua: json['zgsbckua'] ?? '',
      hxsgrrzm: json['hxsgrrzm'] ?? '',
      rnucwtgt: json['rnucwtgt'] ?? '',
      bxxqcaod: json['bxxqcaod'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zgsbckua': zgsbckua,
      'hxsgrrzm': hxsgrrzm,
      'rnucwtgt': rnucwtgt,
      'bxxqcaod': bxxqcaod,
    };
  }
}
