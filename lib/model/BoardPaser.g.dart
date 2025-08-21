// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BoardPaser.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoardPaser _$BoardPaserFromJson(Map<String, dynamic> json) => BoardPaser(
      title: json['title'] as String,
      description: json['description'] as String,
      id: (json['id'] as num).toInt(),
    );

Map<String, dynamic> _$BoardPaserToJson(BoardPaser instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'id': instance.id,
    };
