
import 'package:fish_earn/config/GameConfig.dart';
import 'package:json_annotation/json_annotation.dart';

part 'GameData.g.dart';
//flutter pub run build_runner build --delete-conflicting-outputs
@JsonSerializable()
class GameData{
  int level;
  //秒
  int levelTime;

  double coin;

  int life ;

  //保护时间
  int protectTime;

  int foodCount;

  int pearlCount;

  GameData({this.level = 1,this.levelTime = GameConfig.time_1_2 ,this.coin = 0.0,this.life = 100,this.protectTime = 0,this.foodCount = 100,this.pearlCount = 0});

  // JSON 反序列化
  factory GameData.fromJson(Map<String, dynamic> json) =>
      _$GameDataFromJson(json);

  // JSON 序列化
  Map<String, dynamic> toJson() => _$GameDataToJson(this);

}