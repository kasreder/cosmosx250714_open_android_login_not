import 'package:json_annotation/json_annotation.dart';

part 'CommentP.g.dart';

class NoticeCommentData {
  String comment_content;
  String comment_created_at;
  String comment_author_nickname;
  int comment_id;

  NoticeCommentData({
    required this.comment_content,
    required this.comment_created_at,
    required this.comment_author_nickname,
    required this.comment_id,
  });
}

@JsonSerializable()
class CommentP {
  /// The generated code assumes these values exist in JSON.
  final String comment_content, comment_created_at, comment_author_nickname;
  final int comment_id;
  final int? parent_comment_order;
  final int? parent_comment_id;
  final String? post_id;

  CommentP({
    required this.comment_content,
    required this.comment_id,
    required this.comment_author_nickname,
    required this.comment_created_at,
    required this.parent_comment_id,
    required this.parent_comment_order,
    required this.post_id,
  });

  @override
  String toString() {
    return 'CommentP(commentId: $comment_id, '
        'commentParentId: $parent_comment_id, '
        'ODER: $parent_comment_order, '
        'nickname:$comment_author_nickname,'
        'comment_created_at:$comment_created_at'
        'post_id:$post_id';
  }

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory CommentP.fromJson(Map<String, dynamic> json) => _$CommentPFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$CommentPToJson(this);
}
