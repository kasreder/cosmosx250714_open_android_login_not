import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../../../model/BoardP.dart';
import '../../../../model/CommentP.dart';
import '../../../../model/Model.dart';
import '../../../../model/PostWithComments.dart';
import '../../../../util/date_util.dart';
import '../../../../util/responsive_width.dart';

import '../../../widget/appbar.dart';
import '../../../widget/drawer.dart';
import '../../../widget/floating_action_widget.dart';

/// Widget for the root/initial pages in the bottom navigation bar.
class BMain extends StatefulWidget {
  /// Creates a RootScreen
  const BMain({
    required this.label,
    required this.detailsPath,
    super.key,
  });

  /// The label
  final String label;
  final String detailsPath;

  @override
  State<BMain> createState() => BMainState();
}

class BMainState extends State<BMain> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// 메인 페이지 내용
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: "새소식",
        appBar: AppBar(),
      ),
      //라우팅쪽 label
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Screen ${widget.label}',
                style: Theme.of(context).textTheme.titleLarge),
            const Padding(padding: EdgeInsets.all(4)),
            const Text('BMain 페이지로 자동 이동합니다'),
          ],
        ),
      ),
      drawer: const BaseDrawer(),
    );
  }
}

class Board extends StatefulWidget {
  final String label;
  final String detailPath;

  const Board({super.key, required this.label, required this.detailPath});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamController<List<BoardP>> _streamController;
  final String url = "https://terraforming.info/main/news";
  final int itemsPerPage = 20;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<List<BoardP>>();
    _loadDataToStream();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Future<void> _loadDataToStream() async {
    final http.Response res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final List<BoardP> result = jsonDecode(res.body)
          .map<BoardP>((data) => BoardP.fromJson(data))
          .toList();
      _streamController.add(result);
    } else {
      _streamController.addError('Failed to load boards');
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = ResponsiveWidth.getResponsiveWidth(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('stream'),
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: _loadDataToStream,
          child: StreamBuilder<List<BoardP>>(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              var newsData = snapshot.data;
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return SelectableText("Error: ${snapshot.error}");
              } else if (snapshot.hasData && snapshot.data != null) {
                print('StreamBuilder StreamBuilder');
                // UI 구성 부분, 예: ListView.builder
                return ListView.separated(
                  primary: false,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: min(itemsPerPage,
                      newsData!.length - currentPage * itemsPerPage),
                  itemBuilder: (BuildContext context, int index) {
                    int itemIndex = (newsData.length - 1) -
                        (currentPage * itemsPerPage +
                            index); // 내림차순으로 항목의 실제 인덱스 계산
                    int totalItemsCount =
                        newsData.length; // 내림차순으로 news로 검색된 인덱스 계산
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
                                  Text(
                                    // "${NewsData![itemIndex].id} ",
                                    '$listOrderNumber',
                                    style:
                                    Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(
                                          width: deviceWidth * 0.6,
                                          child: InkWell(
                                            onTap: () {
                                              String newPath =
                                                  '${widget.detailPath}?itemIndex=${newsData[itemIndex].id}';
                                              context.go(newPath);
                                            },
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "${newsData[itemIndex].title} ",
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
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                // "${snapshot.data![index].created_at}",
                                                DateUtil.formatDate(
                                                    newsData[itemIndex]
                                                        .created_at),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall!
                                                    .copyWith(
                                                    color: Colors.black54),
                                              ),
                                              Text(
                                                snapshot
                                                    .data![itemIndex].nickname,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall!
                                                    .copyWith(
                                                    color: Colors.black54),
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
                );
              } else {
                return const Text("데이터가 없습니다.");
              }
            },
          ),
        ),
      ),
    );
  }
}


class BoardDetailsScreen extends StatefulWidget {
  final String label;
  final String? itemIndex;

  const BoardDetailsScreen({
    super.key,
    required this.label,
    this.itemIndex, // 옵셔널로 변경
  });

  @override
  State<StatefulWidget> createState() => BoardDetailsScreenState();
}

/// The state for DetailsScreen
class BoardDetailsScreenState extends State<BoardDetailsScreen> {
  bool _isFloatingActionButtonVisible = true;

  void _updateFloatingActionButtonVisibility(bool isVisible) {
    setState(() {
      _isFloatingActionButtonVisible = isVisible;
    });
    print("After update, _isFloatingActionButtonVisible: $_isFloatingActionButtonVisible");
  }

  Future<PostWithComments>? _NewsPostComment;

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
    return "https://terraforming.info/main/news/$itemIndex";
  }

  Future<PostWithComments> _getNewsData() async {
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
    _NewsPostComment = _getNewsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(title: "새소식", appBar: AppBar()),
      body: FutureBuilder<PostWithComments>(
          future: _NewsPostComment,
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
            var NewsData = snapshot.data?.post;
            var commentData = snapshot.data!.comments;

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
                              NewsData!.title,
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
                                              Text('NO: ${NewsData.id}',
                                                  style: const TextStyle(
                                                      color: Colors.grey)),
                                            ],
                                          ),
                                          SelectableText(
                                              NewsData.nickname ??
                                                  'No nickname',
                                              style: const TextStyle(
                                                  color: Colors.grey)),
                                          Text(
                                              DateUtil.formatDate(
                                                  NewsData.created_at),
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
                                          child: SelectableText(
                                            NewsData.content,
                                            style: const TextStyle(
                                              height:
                                              1.5, // 줄 간격을 글자 크기의 1.5배로 설정
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
                                        width:
                                        ResponsiveWidth.getResponsiveWidth(
                                            context),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: <Widget>[
                                            // 구글 로그인 버튼
                                            Padding(
                                              padding:
                                              const EdgeInsets.all(8.0),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // 구글 로그인 처리
                                                },
                                                child: const Text('구글'),
                                              ),
                                            ),
                                            // 네이버 로그인 버튼
                                            Padding(
                                              padding:
                                              const EdgeInsets.all(8.0),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // 네이버 로그인 처리
                                                },
                                                child: const Text('네이버'),
                                              ),
                                            ),
                                            // 카카오톡 로그인 버튼
                                            Padding(
                                              padding:
                                              const EdgeInsets.all(8.0),
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  // 카카오톡 로그인 처리
                                                },
                                                child: const Text('카톡'),
                                              ),
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
                        child: _buildCommentListNews(
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
      _isFloatingActionButtonVisible ? const NaviFloatingAction() : null, //
    );
  }
}

// ignore: camel_case_types
class _buildCommentListNews extends StatefulWidget {
  final Function(bool) updateVisibility;
  final List<CommentP> commentData;
  final String? itemIndex;

  const _buildCommentListNews({
    required this.commentData,
    required this.itemIndex,
    required this.updateVisibility,
  });

  @override
  State<_buildCommentListNews> createState() => _buildCommentListNewsState();
}

class _buildCommentListNewsState extends State<_buildCommentListNews> {
  final FocusNode _commentFocusNode = FocusNode();
  final FocusNode _replyFocusNode = FocusNode();
  final Map<int, bool> _showReplyField = {};
  final TextEditingController _newCommentController =
  TextEditingController(); // 새 댓글을 위한 컨트롤러
  final Map<int, TextEditingController> _replyControllers = {};
  List<CommentP?> comments = [];
  List<CommentP?> primaryComments = []; // 일반 댓글 목록
  Map<int, List<CommentP>> replyComments = {}; // 대댓글 목록

  // get parent_comment_id => null; // 대댓글을 위한 컨트롤러 Map
  String constructUrl() {
    // `widget.itemIndex` 또는 쿼리 파라미터를 사용하여 URL 구성
    final itemIndex = widget.itemIndex ?? Uri.base.queryParameters['itemIndex'];
    if (itemIndex == null) {
      throw Exception('No item index provided');
    }
    print(widget.itemIndex);
    return "https://terraforming.info/main/news/$itemIndex";
  }

  // 댓글 또는 대댓글 전송 함수
  Future<void> _sendComment(String content,
      {int? parent_comment_id, int? parent_comment_order}) async {
    final String url = constructUrl(); // API 엔드포인트 URL
    int calculateParentCommentOrder(int? parentCommentOrder) {
      if (parentCommentOrder == null) {
        // parent_comment_order 값이 Null 이면 0
        return 0;
      } else if (parentCommentOrder == 0) {
        // parent_comment_order 값이 0이면 1
        return 1;
      } else if (parentCommentOrder == 1) {
        // parent_comment_order 값이 1이면 2
        return 2;
      } else {
        // parent_comment_order 값이 2 초과면 2
        return parentCommentOrder > 2 ? 2 : parentCommentOrder;
      }
    }

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': 8,
        'post_id': widget.itemIndex ?? Uri.base.queryParameters['itemIndex'],
        'comment_content': content,
        'parent_comment_id': parent_comment_id,
        'parent_comment_order':
        calculateParentCommentOrder(parent_comment_order),
        // 'parent_comment_order' : "0"
        // 'commentId': commentId, // 새 댓글의 경우 null일 수 있음
        // 'parentCommentOrder': parentCommentOrder, // 주 댓글의 경우 null일 수 있음
        // 'parentCommentId': parentCommentId, // 대댓글이 아닌 경우 null일 수 있음
      }),
    );

    // 서버에 데이터를 전송하는 코드...
    if (response.statusCode == 200) {
      print('Comment sent successfully');
      print(response.body);
      final jsonResponse = jsonDecode(response.body);
      // final itemIndex = widget.itemIndex ?? Uri.base.queryParameters['itemIndex'];
      print(jsonResponse);
      // 서버 응답으로부터 CommentP 객체 생성 (가정)
      // CommentP newComment = CommentP(
      //   comment_id: jsonResponse['id'],
      //   post_id: jsonResponse['post_id'].toString(),
      //   comment_author_nickname: jsonResponse['user_id'].toString(),
      //   comment_content: jsonResponse['comment_content'],
      //   parent_comment_id: jsonResponse['parent_comment_id'],
      //   parent_comment_order: jsonResponse['parent_comment_order'],
      //   comment_created_at: jsonResponse['comment_created_at'].toString(),
      // );
      print('Comment sent successfully+++++setState');
      // html.window.location.reload();
      // Navigator.pushReplacementNamed(context, '/main/news/$itemIndex');
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => const BoardDetailsScreen(
            label: 'NewsSSSSSSSSS',
          )));
    } else {
      print('Failed to send comment');
      // 실패 처리...
    }
  }

  @override
  void initState() {
    super.initState();
    _commentFocusNode.addListener(_handleFocusChange);
    _replyFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    // 댓글 또는 대댓글 입력 필드 중 하나라도 포커스를 가지고 있으면 플로팅 액션 버튼을 숨깁니다.
    if (_commentFocusNode.hasFocus || _replyFocusNode.hasFocus) {
      widget.updateVisibility(false);
    } else {
      // 두 입력 필드 모두 포커스를 잃었을 때만 플로팅 액션 버튼을 다시 표시합니다.
      widget.updateVisibility(true);
    }
  }

  @override
  void dispose() {
    _commentFocusNode.removeListener(_handleFocusChange);
    _commentFocusNode.dispose();
    _replyFocusNode.removeListener(_handleFocusChange);
    _replyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 댓글을 일반 댓글과 대댓글로 분류
    List<CommentP> primaryComments = [];
    Map<int, List<CommentP>> replyComments = {};

    for (var comment in widget.commentData) {
      if (comment.parent_comment_id == null) {
        primaryComments.add(comment);
        print('primaryCommentsprimaryComments');
        replyComments[comment.comment_id] = [];
      } else {
        replyComments[comment.parent_comment_id]?.add(comment);
        print('replyCommentsreplyCommentsreplyComments');
      }
    }
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: ResponsiveWidth.getResponsiveWidth(context),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 자식 크기에 맞춤
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  SizedBox(
                    width: ResponsiveWidth.getResponsiveWidth(context),
                    child: TextFormField(
                      focusNode: _commentFocusNode,
                      controller: _newCommentController,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: '댓글을 작성하세요',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            // TODO: 댓글 작성 로직 구현
                            dynamic text = _newCommentController.text
                                .trim(); // 입력값의 앞뒤 공백 제거
                            if (text.isNotEmpty) {
                              // 입력값이 공백이 아닌 경우, 댓글 전송 로직 실행
                              _sendComment(text);
                              _newCommentController.clear(); // 텍스트 필드 초기화
                              // Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => CurrentPage()));
                            } else {
                              // 실제로 내용을 입력하지 않았을 경우 경고 메시지 표시
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('댓글을 입력해주세요.')));
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 0.1, 4, 0.1),
      child: SizedBox(
        width: ResponsiveWidth.getResponsiveWidth(context),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            paddingValue < 20 ? 8.0 : (paddingValue > 38 ? 24.0 : 16.0),
            paddingValue < 20 ? 16.0 : 1.0,
            paddingValue < 20 ? 1.0 : 1.0,
            paddingValue < 20 ? 1.0 : 1.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                    color: const Color(0x8bd7d7d7),
                    width: paddingValue < 20 ? 10.0 : 3.0),
                // left: BorderSide(color: Colors.grey.shade400, width: 5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 댓글 작성자와 내용
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingValue * 0.3),
                  child: Row(
                    children: [
                      // const Icon(Icons.reply_sharp, color: Colors.grey, size: 15),
                      buildIcon(paddingValue),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SelectableText(
                            comment.comment_author_nickname ?? 'No nickname',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 15)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                            DateUtil.formatDate(comment.comment_created_at),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 15)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.subdirectory_arrow_left_outlined,
                            color: Colors.grey, size: 15),
                        onPressed: () {
                          setState(() {
                            // 현재 클릭된 대댓글 입력 필드의 상태를 토글합니다.
                            bool currentFieldState =
                            !(_showReplyField[comment.comment_id] ?? false);
                            // 모든 대댓글 입력 필드를 닫습니다.
                            for (var key in _showReplyField.keys) {
                              _showReplyField[key] = false;
                            }
                            // 클릭된 대댓글 입력 필드만 상태를 업데이트합니다.
                            _showReplyField[comment.comment_id] =
                                currentFieldState;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 1.0, left: paddingValue * 0.3),
                  child: SelectableText(comment.comment_content),
                ),
                if (_showReplyField[comment.comment_id] ?? false)
                  Padding(
                    padding:
                    EdgeInsets.only(top: 8.0, left: paddingValue * 0.3),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: deviceWidth * 0.8, // 너비 설정
                        child: TextFormField(
                          focusNode: _replyFocusNode,
                          controller: _replyControllers[comment.comment_id] ??=
                              TextEditingController(
                                  text: '@${comment.comment_author_nickname} '),
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
                                    _replyControllers[comment.comment_id]
                                        ?.text
                                        .trim() ??
                                        '';
                                String actualText = text
                                    .replaceAll(
                                    '@${comment.comment_author_nickname}',
                                    '')
                                    .trim();

                                if (actualText.isNotEmpty) {
                                  print("actualText");
                                  print(actualText);
                                  print(text);
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
                                  _replyControllers[comment.comment_id]
                                      ?.clear(); // 텍스트 필드 초기화

                                  // 페이지 새로고침 로직 여기에 포함시키기
                                  // Flutter 웹 애플리케이션의 경우
                                  // html.window.location.reload();
                                } else {
                                  // 실제로 내용을 입력하지 않았을 경우 경고 메시지 표시
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('대 댓글을 입력해주세요.')));
                                }
                              },
                            ),
                          ),
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
      iconData = Icons.arrow_upward; // 기본값 설정
    }

    return Icon(iconData, color: Colors.grey, size: 15);
  }
}

