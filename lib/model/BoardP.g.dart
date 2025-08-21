// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BoardP.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoardP _$BoardPFromJson(Map<String, dynamic> json) => BoardP(
      title: json['title'] as String,
      content: json['content'] as String,
      id: (json['id'] as num).toInt(),
      nickname: json['nickname'] as String,
      created_at: json['created_at'] as String,
      bname: json['bname'] as String,
      views: (json['views'] as num).toInt(),
    );

Map<String, dynamic> _$BoardPToJson(BoardP instance) => <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'created_at': instance.created_at,
      'nickname': instance.nickname,
      'bname': instance.bname,
      'id': instance.id,
      'views': instance.views,
    };
