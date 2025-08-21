
import 'package:fish_earn/config/GameConfig.dart';
import 'package:json_annotation/json_annotation.dart';

part 'GameData.g.dart';
//flutter pub run build_runner build --delete-conflicting-outputs
@JsonSerializable()
class GameData{
  var level;
  //秒
  var levelTime;

  var coin;

  GameData({this.level = 1,this.levelTime = GameConfig.time_1_2 ,this.coin = 0});

  // JSON 反序列化
  factory GameData.fromJson(Map<String, dynamic> json) =>
      _$GameDataFromJson(json);

  // JSON 序列化
  Map<String, dynamic> toJson() => _$GameDataToJson(this);

  double getCurrentProgress() {
    var all = GameConfig.time_1_2+GameConfig.time_2_3;
    if(level == 1){
      var all = GameConfig.time_1_2;
      var progress = ((all-levelTime)/all);
      progress = progress>=1?1:progress;
      return 0.5 *progress;
    }else if(level == 2){
      if(levelTime<=0){
        levelTime = GameConfig.time_2_3;
      }
      var all = GameConfig.time_2_3;
      var progress = ((all-levelTime)/all);
      progress = progress>=1?1:progress;
      progress = (0.5 *progress)+0.5;
    }
    return 1;
  }
}