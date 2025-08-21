// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Model _$ModelFromJson(Map<String, dynamic> json) => Model(
      title: json['title'] as String,
      content: json['content'] as String,
      id: (json['id'] as num).toInt(),
      views: (json['views'] as num).toInt(),
      nickname: json['nickname'] as String,
      created_at: json['created_at'] as String,
    );

Map<String, dynamic> _$ModelToJson(Model instance) => <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'created_at': instance.created_at,
      'nickname': instance.nickname,
      'id': instance.id,
      'views': instance.views,
    };
