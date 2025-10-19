
import '../../data/ADRequestData.dart';

class ADEnum {
  final String adName;

  int adLoadStatus;
  final List<ADRequestData> adRequestList;

  static const int LOAD_STATUS_START = 0;
  static const int LOAD_STATUS_LOADING = 1;
  static const int AD_LOAD_SUCCESS = 2;
  static const int AD_LOAD_FAIL = 3;

  static const String AD_SHOW_TYPE_FAILED = "AD_SHOW_TYPE_FAILED";
  static const String AD_SHOW_TYPE_SUCCESS = "AD_SHOW_TYPE_SUCCESS";

  ADEnum._internal(this.adName)
      : adLoadStatus = LOAD_STATUS_START,
        adRequestList = [];

  void reset() {
    adLoadStatus = LOAD_STATUS_START;
    adRequestList.clear();
  }


  @override
  String toString() =>
      'ADEnum($adName, status=$adLoadStatus, requests=${adRequestList.length})';

  // 模拟枚举值
  static final ADEnum intAD = ADEnum._internal("oxrsl_int");
  static final ADEnum rewardedAD = ADEnum._internal("oxrsl_rv");

  // 所有值（可遍历）
  static List<ADEnum> get values => [intAD, rewardedAD];
}

