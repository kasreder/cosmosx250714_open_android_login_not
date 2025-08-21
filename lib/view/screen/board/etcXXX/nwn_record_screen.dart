import 'dart:convert';
import 'dart:math';
import 'dart:core';
import 'package:universal_html/html.dart' as html;


import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../model/BoardP.dart';
import '../../../../model/CommentP.dart';
import '../../../../model/Model.dart';
import '../../../../model/PostWithComments.dart';
import '../../../../provider/user_provider.dart';
import '../../../../util/date_util.dart';
import '../../../../util/responsive_width.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../../widget/appbar.dart';
import '../../../widget/drawer.dart';
import '../../../widget/floating_action_widget.dart';

/// 기록실험 게시판
class Record extends StatefulWidget {
  const Record({
    required this.label,
    required this.detailPath,
    super.key,
  });

  final String label;
  final String detailPath;

  @override
  State<StatefulWidget> createState() => RecordState();
}

class RecordState extends State<Record> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<BoardP>?>? _boardList;
  final now = DateTime.now();
  final int itemsPerPage = 20; // 페이지당 항목 수
  int totalItems = 0; // 전체 항목 수
  int currentPage = 0; // 현재 페이지 번호

  @override
  void initState() {
    super.initState();
    _boardList = _getBoardList();
    print('initState initState');
  }

  final String url = "https://terraforming.info/Record";

  Future<List<BoardP>> _getBoardList() async {
    try{
      final http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final List<BoardP> result = jsonDecode(res.body)
            .map<BoardP>((data) => BoardP.fromJson(data))
            .toList();
        totalItems = result.length;
        return result;
      } else {
        throw Exception('Failed to load boards');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<void> _refreshBoardList() async {
    setState(() {
      _boardList = _getBoardList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = ResponsiveWidth.getResponsiveWidth(context);
    // print('width★★★★ : ${ResponsiveWidth.getResponsiveWidth(context)}');
    int startPage = max(0, currentPage - 2);
    int endPage = min((totalItems / itemsPerPage).ceil(), currentPage + 2);
    return Scaffold(
      appBar: BaseAppBar(
        title: "기록, 실험 게시판",
        appBar: AppBar(),
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: _refreshBoardList,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text("새로운시도가 곧 창조다"),
                buildRecordExpanded(deviceWidth),
                buildRecordRow(startPage, endPage),
              ],
            ),
          ),
        ),
      ),
      drawer: const BaseDrawer(),
      floatingActionButton: const NaviFloatingAction(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  //하단 작성글 보는 리스트
  Expanded buildRecordExpanded(double deviceWidth) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
        child: FutureBuilder(
          future: _boardList,
          builder: (context, snapshot) {
            var RecordData = snapshot.data;
            if (snapshot.connectionState == ConnectionState.done) {
              print('initState gggggggggggggggg');
              if (snapshot.hasError) {
                return Center(
                  child: SelectableText(
                    '${snapshot.error} occurred nnnnnnnnnnRecord',
                    style: const TextStyle(fontSize: 18),
                  ),
                ); // if we got our data
              } else if (snapshot.hasData && snapshot.data != null) {
                print('FutureBuilder FutureBuilder');
                return SizedBox(
                  width: MediaQuery.of(context).size.width <= 450 ? deviceWidth : deviceWidth *0.9,
                  child: ListView.separated(
                    primary: false,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: min(
                      itemsPerPage,
                      RecordData!.length - currentPage * itemsPerPage,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      int itemIndex = (RecordData.length - 1) -
                          (currentPage * itemsPerPage +
                              index); // 내림차순으로 항목의 실제 인덱스 계산
                      int totalItemsCount =
                          RecordData.length; // 내림차순으로 Record로 검색된 인덱스 계산
                      int listOrderNumber =
                          totalItemsCount - (currentPage * itemsPerPage + index);

                      return Container(
                        padding: const EdgeInsets.all(1),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    SelectableText(
                                      // "${RecordData![itemIndex].id} ",
                                      '$listOrderNumber',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: deviceWidth * 0.6,
                                            child: InkWell(
                                              onTap: () {
                                                String newPath =
                                                    '${widget.detailPath}${RecordData[itemIndex].id}';
                                                // '${widget.detailPath}?itemIndex=${RecordData![itemIndex].id}';
                                                context.go(newPath);
                                              },
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "${RecordData[itemIndex].title} ",
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  softWrap: false,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: deviceWidth * 0.5,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                SelectableText(
                                                  // "${snapshot.data![index].created_at}",
                                                  DateUtil.formatDate(
                                                      RecordData[itemIndex]
                                                          .created_at),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall!
                                                      .copyWith(color: Colors.black54,
                                                      fontSize: 10),
                                                ),
                                                SelectableText(
                                                  snapshot
                                                      .data![itemIndex].nickname,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall!
                                                      .copyWith(color: Colors.black54,
                                                      fontSize: 10),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    SizedBox(
                                      width: deviceWidth * 0.2,
                                      child: Text(
                                        "사진",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .copyWith(color: Colors.black54),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                  ),
                );
              }
            }
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 10,
              ),
            );
          },
        ),
      ),
    );
  }

  //하단 페이지 숫자
  Row buildRecordRow(int startPage, int endPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: currentPage == 0
                    ? null
                    : () {
                  setState(() {
                    currentPage--;
                  });
                },
              ),
              for (int i = startPage; i < endPage; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        currentPage = i;
                      });
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered)) {
                            return Colors.blue;
                          }
                          return Colors.black;
                        },
                      ),
                    ),
                    child: Text(
                      '$i',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(color: Colors.black87,fontSize: 20),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: currentPage == (totalItems / itemsPerPage).ceil() - 1
                    ? null
                    : () {
                  setState(() {
                    currentPage++;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(flex: 1, child: Container())
      ],
    );
  }
}

class RecordDetailsScreen extends StatefulWidget {
  final String label;
  final String? itemIndex;

  const RecordDetailsScreen({
    super.key,
    required this.label,
    this.itemIndex, // 옵셔널로 변경
  });

  @override
  State<StatefulWidget> createState() => RecordDetailsScreenState();
}

/// The state for DetailsScreen
class RecordDetailsScreenState extends State<RecordDetailsScreen> {
  bool _isFloatingActionButtonVisible = true;

  void _updateFloatingActionButtonVisibility(bool isVisible) {
    setState(() {
      _isFloatingActionButtonVisible = isVisible;
    });
    print("After update, _isFloatingActionButtonVisible: $_isFloatingActionButtonVisible");
  }

  Future<PostWithComments>? _RecordPostComment;

  String constructUrl() {
    // `widget.itemIndex` 또는 쿼리 파라미터를 사용하여 URL 구성
    final itemIndex = widget.itemIndex ?? Uri.base.queryParameters['itemIndex'];
    print("애스커다ㅏ아아아앙");
    print(widget.itemIndex);
    print(itemIndex);
    print("애스커다ㅏ아아아앙");

    if (itemIndex == null) {
      throw Exception('No item index provided');
    }
    return "https://terraforming.info/record/$itemIndex";
  }

  Future<PostWithComments> _getRecordData() async {
    final url = constructUrl();
    final http.Response res = await http.get(Uri.parse(url));

    if (res.statusCode != 200) {
      throw Exception('Failed to load data from $url');
    }

    final jsonData = jsonDecode(res.body) as Map<String, dynamic>;
    final post = Model.fromJson(jsonData['post']);
    final comments = (jsonData['comments'] as List)
        .map<CommentP>((data) => CommentP.fromJson(data))
        .toList();

    return PostWithComments(post: post, comments: comments);
  }

  @override
  void initState() {
    super.initState();
    _RecordPostComment = _getRecordData();
  }

  @override
  Widget build(BuildContext context) {
    // 로그인 여부를 확인
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.username.isNotEmpty;
    final currentUser = userProvider.nickname; // 현재 로그인된 사용자 이름

    return Scaffold(
      appBar: BaseAppBar(title: "새소식", appBar: AppBar()),
      body: FutureBuilder<PostWithComments>(
          future: _RecordPostComment,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  children: [
                    SelectableText(
                      '${snapshot.error} occurred111',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No data available'));
            }
            var RecordData = snapshot.data?.post;
            var commentData = snapshot.data!.comments;
            final quillController = quill.QuillController(
              document: quill.Document.fromJson(jsonDecode(RecordData!.content)),
              selection: const TextSelection.collapsed(offset: 0),
            );

            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 50, 8, 8),
                        child: Column(
                          children: [
                            SelectableText(
                              RecordData.title,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    8, 10, 8, 10),
                                                child: Icon(
                                                  // Icons.add_chart,
                                                  Icons.import_contacts_sharp,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text('NO: ${RecordData.id}',
                                                  style: const TextStyle(
                                                      color: Colors.grey)),
                                            ],
                                          ),
                                          SelectableText(
                                              RecordData.nickname ??
                                                  'No nickname',
                                              style: const TextStyle(
                                                  color: Colors.grey)),
                                          Text(
                                              DateUtil.formatDate(
                                                  RecordData.created_at),
                                              style: const TextStyle(
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                      SizedBox(
                                          width: ResponsiveWidth
                                              .getResponsiveWidth(context),
                                          child: const Divider(
                                              color: Colors.black54,
                                              thickness: 0.3)),
                                      SizedBox(
                                        width:
                                        ResponsiveWidth.getResponsiveWidth(
                                            context),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:quill.QuillEditor.basic(
                                            controller: quillController,
                                            config: const quill.QuillEditorConfig(
                                              scrollable: true,
                                              autoFocus: false,
                                              showCursor: false,
                                              expands: false,
                                              padding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: ResponsiveWidth
                                              .getResponsiveWidth(context),
                                          child: const Divider(
                                              color: Colors.black54,
                                              thickness: 0.3)),
                                      SizedBox(
                                        width: ResponsiveWidth.getResponsiveWidth(context),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // "목록"과 오른쪽 버튼 그룹 사이 간격 확보
                                          children: <Widget>[
                                            // 왼쪽 "목록" 버튼
                                            TextButton(
                                              onPressed: () {
                                                // 목록 버튼 로직 (예: 뒤로 가기)
                                                context.pop();
                                              },
                                              child: const Text('목록'),
                                            ),
                                            // 오른쪽 버튼 그룹
                                            Row(
                                              children: [
                                                if (isLoggedIn)
                                                  RecordData.nickname == currentUser
                                                      ? Row(
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          final itemIndex = widget.itemIndex ??
                                                              Uri.base.queryParameters['itemIndex'];
                                                          final updateIdParam = itemIndex;

                                                          // 수정 페이지로 이동
                                                          context.go(
                                                            '/comm/record/$updateIdParam/update',
                                                            extra: UniqueKey(),
                                                          );
                                                        },
                                                        child: const Text('수정'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          // 삭제 로직
                                                        },
                                                        child: const Text('삭제'),
                                                      ),
                                                    ],
                                                  )
                                                      : Row(
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          // 추천 로직
                                                        },
                                                        child: const Text('추천'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          // 비추천 로직
                                                        },
                                                        child: const Text('비추천'),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _RecordbuildCommentList(
                          commentData: commentData,
                          itemIndex: widget.itemIndex,
                          updateVisibility:
                          _updateFloatingActionButtonVisibility,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 50),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
      drawer: const BaseDrawer(),
      floatingActionButton:
      _isFloatingActionButtonVisible ? const NaviFloatingAction() : null,
      floatingActionButtonLocation: _isFloatingActionButtonVisible
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.endFloat, // Adjust as needed//
    );
  }
}

// ignore: camel_case_types
class _RecordbuildCommentList extends StatefulWidget {
  final Function(bool) updateVisibility;
  final List<CommentP> commentData;
  final String? itemIndex;

  const _RecordbuildCommentList({
    required this.commentData,
    required this.itemIndex,
    required this.updateVisibility,
  });

  @override
  State<_RecordbuildCommentList> createState() => _RecordbuildCommentListState();
}

class _RecordbuildCommentListState extends State<_RecordbuildCommentList> {
  final FocusNode _RecordcommentFocusNode = FocusNode();
  final Map<int, FocusNode> _RecordreplyFocusNodes = {};
  final TextEditingController _RecordnewCommentController =
  TextEditingController(); // 새 댓글을 위한 컨트롤러
  final Map<int, TextEditingController> _RecordreplyControllers = {};
  final Map<int, bool> _RecordshowReplyField = {};
  // final quill.QuillController _RecordnewCommentController = quill.QuillController.basic();

  @override
  void initState() {
    super.initState();
    _RecordcommentFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _RecordcommentFocusNode.removeListener(_handleFocusChange);
    _RecordcommentFocusNode.dispose();
    _RecordreplyFocusNodes.forEach((key, focusNode) {
      focusNode.removeListener(_handleFocusChange);
      focusNode.dispose();
    });
    super.dispose();
  }

  void _handleFocusChange() {
    if (_RecordcommentFocusNode.hasFocus ||
        _RecordreplyFocusNodes.values.any((focusNode) => focusNode.hasFocus)) {
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
    return "https://terraforming.info/record/$itemIndex";
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
                      focusNode: _RecordcommentFocusNode,
                      controller: _RecordnewCommentController,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: '댓글을 작성하세요',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            dynamic text = _RecordnewCommentController.text
                                .trim();
                            if (text.isNotEmpty) {
                              _sendComment(text);
                              _RecordnewCommentController.clear();
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
    _RecordreplyFocusNodes[comment.comment_id] ??= FocusNode()
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
                            !(_RecordshowReplyField[comment.comment_id] ??
                                false);
                            _RecordshowReplyField.clear();
                            _RecordshowReplyField[comment.comment_id] =
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
                if (_RecordshowReplyField[comment.comment_id] ?? false)
                  Padding(
                    padding: EdgeInsets.only(
                        top: 8.0, left: paddingValue * 0.3),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: deviceWidth * 0.8,
                        child: TextFormField(
                          focusNode: _RecordreplyFocusNodes[comment.comment_id],
                          controller: _RecordreplyControllers[comment
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
                                    _RecordreplyControllers[comment.comment_id]
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
                                  _RecordreplyControllers[comment.comment_id]
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
