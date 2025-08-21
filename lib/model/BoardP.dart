import 'package:json_annotation/json_annotation.dart';

part 'BoardP.g.dart';

@JsonSerializable()
class BoardP {
  /// The generated code assumes these values exist in JSON.
  final String title, content, created_at, nickname, bname;
  final int id, views;

  BoardP(
      {required this.title,
      required this.content,
      required this.id,
      required this.nickname,
      required this.created_at,
      required this.bname,
      required this.views});

  // String toString() {
  //   return 'BoardP(id:$id, title: $title, nickname: $nickname,created_at: $created_at,bname:$bname )';
  // }

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory BoardP.fromJson(Map<String, dynamic> json) => _$BoardPFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$BoardPToJson(this);
}

//flutter pub run build_runner build --delete-conflicting-outputs
