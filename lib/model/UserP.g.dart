// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserP.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserP _$UserPFromJson(Map<String, dynamic> json) => UserP(
      username: json['username'] as String,
      nickname: json['nickname'] as String,
      email: json['email'] as String,
      grade: json['grade'] as String,
      bname: json['bname'] as String,
      id: (json['id'] as num).toInt(),
      provider: json['provider'] as String,
      sns_id: (json['sns_id'] as num?)?.toInt(),
      points: (json['points'] as num).toInt(),
    );

Map<String, dynamic> _$UserPToJson(UserP instance) => <String, dynamic>{
      'username': instance.username,
      'nickname': instance.nickname,
      'email': instance.email,
      'grade': instance.grade,
      'bname': instance.bname,
      'provider': instance.provider,
      'id': instance.id,
      'points': instance.points,
      'sns_id': instance.sns_id,
    };
