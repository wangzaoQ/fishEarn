// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GameData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameData _$GameDataFromJson(Map<String, dynamic> json) => GameData(
  level: (json['level'] as num?)?.toInt() ?? 1,
  levelTime: (json['levelTime'] as num?)?.toInt() ?? GameConfig.time_1_2,
  coin: (json['coin'] as num?)?.toDouble() ?? 0.0,
  life: (json['life'] as num?)?.toInt() ?? 100,
  protectTime: (json['protectTime'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$GameDataToJson(GameData instance) => <String, dynamic>{
  'level': instance.level,
  'levelTime': instance.levelTime,
  'coin': instance.coin,
  'life': instance.life,
  'protectTime': instance.protectTime,
};
