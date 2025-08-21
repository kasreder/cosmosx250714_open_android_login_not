import 'package:json_annotation/json_annotation.dart';

part 'UserP.g.dart';

@JsonSerializable()
class UserP {
  /// The generated code assumes these values exist in JSON.
  final String username, nickname, email, grade, bname, provider;
  final int id,points;
  final int? sns_id;

  UserP(
      {required this.username,
        required this.nickname,
        required this.email,
        required this.grade,
        required this.bname,
        required this.id,
        required this.provider,
        required this.sns_id,
        required this.points,
      });

  // String toString() {
  //   return 'UserP(id:$id, title: $title, nickname: $nickname,created_at: $created_at,bname:$bname )';
  // }

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory UserP.fromJson(Map<String, dynamic> json) => _$UserPFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$UserPToJson(this);
}

//flutter pub run build_runner build --delete-conflicting-outputs
