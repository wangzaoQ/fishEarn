
import 'package:json_annotation/json_annotation.dart';

part 'GameData.g.dart';
//flutter pub run build_runner build --delete-conflicting-outputs
@JsonSerializable()
class GameData{
  var level;
  var levelTime;
}