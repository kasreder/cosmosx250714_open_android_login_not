import 'CommentP.dart';
import 'Model.dart';

class PostWithComments {
  final Model post;
  final List<CommentP> comments;

  PostWithComments({required this.post, required this.comments});
}