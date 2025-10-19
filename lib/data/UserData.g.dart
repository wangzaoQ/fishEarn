// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData()
  ..new1 = json['new1'] as bool
  ..new2 = json['new2'] as bool
  ..new3 = json['new3'] as bool
  ..new4 = json['new4'] as bool
  ..new5 = json['new5'] as bool
  ..new6 = json['new6'] as bool
  ..new7 = json['new7'] as bool
  ..userRiskStatus = json['userRiskStatus'] as bool
  ..userRiskType = (json['userRiskType'] as num).toInt()
  ..userRiskFrom = json['userRiskFrom'] as String;

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
  'new1': instance.new1,
  'new2': instance.new2,
  'new3': instance.new3,
  'new4': instance.new4,
  'new5': instance.new5,
  'new6': instance.new6,
  'new7': instance.new7,
  'userRiskStatus': instance.userRiskStatus,
  'userRiskType': instance.userRiskType,
  'userRiskFrom': instance.userRiskFrom,
};
