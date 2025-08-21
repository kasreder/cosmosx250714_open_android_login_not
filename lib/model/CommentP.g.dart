// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CommentP.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentP _$CommentPFromJson(Map<String, dynamic> json) => CommentP(
      comment_content: json['comment_content'] as String,
      comment_id: (json['comment_id'] as num).toInt(),
      comment_author_nickname: json['comment_author_nickname'] as String,
      comment_created_at: json['comment_created_at'] as String,
      parent_comment_id: (json['parent_comment_id'] as num?)?.toInt(),
      parent_comment_order: (json['parent_comment_order'] as num?)?.toInt(),
      post_id: json['post_id'] as String?,
    );

Map<String, dynamic> _$CommentPToJson(CommentP instance) => <String, dynamic>{
      'comment_content': instance.comment_content,
      'comment_created_at': instance.comment_created_at,
      'comment_author_nickname': instance.comment_author_nickname,
      'comment_id': instance.comment_id,
      'parent_comment_order': instance.parent_comment_order,
      'parent_comment_id': instance.parent_comment_id,
      'post_id': instance.post_id,
    };
