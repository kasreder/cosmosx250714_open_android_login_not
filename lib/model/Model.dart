import 'package:json_annotation/json_annotation.dart';

part 'Model.g.dart';

class NoticeData {
  String title;
  String content;
  String created_at;
  String nickname;
  int id;
  int views;
  int itemIndex;

  NoticeData({
    required this.title,
    required this.content,
    required this.created_at,
    required this.nickname,
    required this.id,
    required this.views,
    required this.itemIndex,
  });
}
//
@JsonSerializable()
class Model {
  /// The generated code assumes these values exist in JSON.
  final String title, content, created_at, nickname;
  final int id, views;

  Model({
    required this.title,
    required this.content,
    required this.id,
    required this.views,
    required this.nickname,
    required this.created_at,
  });

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory Model.fromJson(Map<String, dynamic> json) => _$ModelFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$ModelToJson(this);
}