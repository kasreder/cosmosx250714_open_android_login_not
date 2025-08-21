import 'dart:convert';
import 'dart:core';
import 'package:universal_html/html.dart' as html;


import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../model/CommentP.dart';
import '../../../../../provider/user_provider.dart';
import '../../../../../util/date_util.dart';
import '../../../../../util/responsive_width.dart';
import 'comm_record_details_screen.dart';

// ignore: camel_case_types
class RecordbuildCommentList extends StatefulWidget {
  final Function(bool) updateVisibility;
  final List<CommentP> commentData;
  final String? itemIndex;

  const RecordbuildCommentList({
    required this.commentData,
    required this.itemIndex,
    required this.updateVisibility,
  });

  @override
  State<RecordbuildCommentList> createState() => RecordbuildCommentListState();
}

class RecordbuildCommentListState extends State<RecordbuildCommentList> {
  final FocusNode RecordcommentFocusNode = FocusNode();
  final Map<int, FocusNode> RecordreplyFocusNodes = {};
  final TextEditingController RecordnewCommentController =
  TextEditingController(); // 새 댓글을 위한 컨트롤러
  final Map<int, TextEditingController> RecordreplyControllers = {};
  final Map<int, bool> RecordshowReplyField = {};
  // final quill.QuillController RecordnewCommentController = quill.QuillController.basic();

  @override
  void initState() {
    super.initState();
    RecordcommentFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    RecordcommentFocusNode.removeListener(_handleFocusChange);
    RecordcommentFocusNode.dispose();
    RecordreplyFocusNodes.forEach((key, focusNode) {
      focusNode.removeListener(_handleFocusChange);
      focusNode.dispose();
    });
    super.dispose();
  }

  void _handleFocusChange() {
    if (RecordcommentFocusNode.hasFocus ||
        RecordreplyFocusNodes.values.any((focusNode) => focusNode.hasFocus)) {
      widget.updateVisibility(false);
    } else {
      widget.updateVisibility(true);
    }
  }

  String constructUrl() {
    final itemIndex = widget.itemIndex ?? Uri.base.queryParameters['itemIndex'];
    if (itemIndex == null) {
      throw Exception('No item index provided');
    }
    return "https://api.cosmosx.co.kr/Record/$itemIndex";
  }

  Future<void> _sendComment(String content,
      {int? parent_comment_id, int? parent_comment_order}) async {
    final String url = constructUrl();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.accessToken;
    int id = userProvider.id;

    int calculateParentCommentOrder(int? parentCommentOrder) {
      if (parentCommentOrder == null) {
        return 0;
      } else if (parentCommentOrder == 0) {
        return 1;
      } else if (parentCommentOrder == 1) {
        return 2;
      } else {
        return parentCommentOrder > 2 ? 2 : parentCommentOrder;
      }
    }

    try {
      final response = await Dio().post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
          },
        ),
        data: jsonEncode(<String, dynamic>{
          'user_id': id,
          'post_id': widget.itemIndex ?? Uri.base.queryParameters['itemIndex'],
          'comment_content': content,
          'parent_comment_id': parent_comment_id,
          'parent_comment_order': calculateParentCommentOrder(
              parent_comment_order),
        }),
      );

      if (response.statusCode == 200) {
        if (kIsWeb) {
          html.window.location.reload();
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) =>
                RecordDetailsScreen(
                  label: 'RecordSSSSSSSSS',
                  itemIndex: widget.itemIndex,
                ),
          ));
        }
      } else {
        print('Failed to send comment');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<CommentP> primaryComments = [];
    Map<int, List<CommentP>> replyComments = {};

    for (var comment in widget.commentData) {
      if (comment.parent_comment_id == null) {
        primaryComments.add(comment);
        print('2aaaaaaaaaaaaaaaaa==============$comment');
        replyComments[comment.comment_id] = [];
      } else {
        replyComments[comment.parent_comment_id]?.add(comment);
      }
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: ResponsiveWidth.getResponsiveWidth(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  SizedBox(
                    width: ResponsiveWidth.getResponsiveWidth(context),
                    child: TextFormField(
                      focusNode: RecordcommentFocusNode,
                      controller: RecordnewCommentController,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: '댓글을 작성하세요',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            dynamic text = RecordnewCommentController.text
                                .trim();
                            if (text.isNotEmpty) {
                              _sendComment(text);
                              RecordnewCommentController.clear();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('댓글을 입력해주세요.')));
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...primaryComments.map((comment) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildComment(comment),
                  ...?replyComments[comment.comment_id]?.map(buildComment),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget buildComment(CommentP comment) {
    double paddingValue = ((comment.parent_comment_order ?? 0) + 1) * 19;
    final deviceWidth = ResponsiveWidth.getResponsiveWidth(context);
    RecordreplyFocusNodes[comment.comment_id] ??= FocusNode()
      ..addListener(_handleFocusChange);

    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 0, 4, 5),
      child: SizedBox(
        width: ResponsiveWidth.getResponsiveWidth(context),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            paddingValue < 20 ? 8.0 : (paddingValue > 38 ? 24.0 : 16.0),
            paddingValue < 20 ? 16.0 : 0,
            paddingValue < 20 ? 0 : 0,
            paddingValue < 20 ? 0 : 0,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                    color: const Color(0x8bd7d7d7),
                    width: paddingValue < 20 ? 10.0 : 3.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  // padding: EdgeInsets.symmetric(horizontal: paddingValue * 0.3),
                  padding: EdgeInsets.only(left: paddingValue * 0.3),
                  child: Row(
                    children: [
                      buildIcon(paddingValue),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SelectableText(
                            comment.comment_author_nickname ?? 'No nickname',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SelectableText(
                            DateUtil.formatDate(comment.comment_created_at),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.subdirectory_arrow_left_outlined,
                            color: Colors.grey, size: 10),
                        visualDensity: const VisualDensity(horizontal: 0),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            print('222323333333==============${comment
                                .comment_id}');
                            bool currentFieldState =
                            !(RecordshowReplyField[comment.comment_id] ??
                                false);
                            RecordshowReplyField.clear();
                            RecordshowReplyField[comment.comment_id] =
                                currentFieldState;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 0, left: paddingValue * 0.3),
                  child: SelectableText(comment.comment_content,
                    style: const TextStyle(fontSize: 14),),
                ),
                if (RecordshowReplyField[comment.comment_id] ?? false)
                  Padding(
                    padding: EdgeInsets.only(
                        top: 8.0, left: paddingValue * 0.3),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: deviceWidth * 0.8,
                        child: TextFormField(
                          focusNode: RecordreplyFocusNodes[comment.comment_id],
                          controller: RecordreplyControllers[comment
                              .comment_id] ??=
                              TextEditingController(
                                // text: '@${comment.comment_author_nickname} '),
                                  text: ''),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 1.0, horizontal: 5.0),
                            isDense: true,
                            hintText: '대댓글을 작성하세요',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                String text =
                                    RecordreplyControllers[comment.comment_id]
                                        ?.text
                                        .trim() ??
                                        '';
                                String actualText = text
                                    .replaceAll(
                                    '@${comment.comment_author_nickname}',
                                    '')
                                    .trim();

                                if (actualText.isNotEmpty) {
                                  int? calculateParentCommentId;
                                  if (comment.parent_comment_order == 0) {
                                    calculateParentCommentId =
                                        comment.comment_id;
                                  } else {
                                    calculateParentCommentId =
                                        comment.parent_comment_id;
                                  }
                                  _sendComment(
                                    text,
                                    parent_comment_id: calculateParentCommentId,
                                    parent_comment_order:
                                    comment.parent_comment_order,
                                  );
                                  RecordreplyControllers[comment.comment_id]
                                      ?.clear();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('대 댓글을 입력해주세요.')));
                                }
                              },
                            ),
                          ),
                          style: const TextStyle(fontSize: 13), // 폰트 크기 설정
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildIcon(double paddingValue) {
    IconData iconData;
    if (paddingValue < 20) {
      iconData = Icons.account_circle;
    } else {
      iconData = Icons.arrow_upward;
    }
    return Icon(iconData, color: Colors.grey, size: 15);
  }
}
