import 'package:json_annotation/json_annotation.dart';

part 'BoardPaser.g.dart';

@JsonSerializable()
class BoardPaser {
  /// The generated code assumes these values exist in JSON.
  final String title, description;
  final int id;

  BoardPaser({required this.title, required this.description, required this.id});

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory BoardPaser.fromJson(Map<String, dynamic> json) => _$BoardPaserFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$BoardPaserToJson(this);
}

//flutter pub run build_runner build --delete-conflicting-outputs