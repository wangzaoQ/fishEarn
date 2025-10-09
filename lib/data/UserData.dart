import 'package:json_annotation/json_annotation.dart';

part 'UserData.g.dart';
//flutter pub run build_runner build --delete-conflicting-outputs
@JsonSerializable()
class UserData{
  //    1.高亮喂食button，手势引导（强制互动，完成后切换）
  bool new1 = true;
  //    2.展示奖励泡泡，手势引导用户点击钱
  bool new2 = true;
  //    3.高亮成长进度栏，手势引导升级按钮
  bool new3 = true;
  //    4.展示危险信号⚠️，做手势引导点击防御
  bool new4 = true;
  //    5.高亮漂流瓶选择页面
  bool new5 = true;

  UserData();

  // JSON 反序列化
  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  // JSON 序列化
  Map<String, dynamic> toJson() => _$UserDataToJson(this);

}