import 'dart:convert';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../../model/CommentP.dart';
import '../../../../../model/Model.dart';
import '../../../../../model/PostWithComments.dart';
import '../../../../../provider/user_provider.dart';
import '../../../../../util/date_util.dart';
import '../../../../../util/responsive_width.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../../../widget/appbar.dart';
import '../../../../widget/drawer.dart';
import '../../../../widget/floating_action_widget.dart';
import 'comm_free_comment_list_screen.dart';

class FreeDetailsScreen extends StatefulWidget {
  final String label;
  final String? itemIndex;
  final Map<String, dynamic>? extraData; // extraData 필드 추가

  const FreeDetailsScreen({
    super.key,
    required this.label,
    this.itemIndex,
    this.extraData,
  });

  @override
  State<StatefulWidget> createState() => FreeDetailsScreenState();
}

/// The state for DetailsScreen
class FreeDetailsScreenState extends State<FreeDetailsScreen> {
  bool _isFloatingActionButtonVisible = true;
  late int currentIndex;
  late List<dynamic> mappedIds;
  Map<String, dynamic>? extraData; // extraData 필드 추가
  final String middleMunu = 'comm/free';

  void _updateFloatingActionButtonVisibility(bool isVisible) {
    setState(() {
      _isFloatingActionButtonVisible = isVisible;
    });
    print("After update, _isFloatingActionButtonVisible: $_isFloatingActionButtonVisible");
  }

  Future<PostWithComments>? _FreePostComment;

  String constructUrl() {
    // `widget.itemIndex` 또는 쿼리 파라미터를 사용하여 URL 구성
    final itemIndex = widget.itemIndex ?? Uri.base.queryParameters['itemIndex'];
    print('디테일 itemIndex : ${widget.itemIndex}');
    print('디테일 itemIndex : $itemIndex');

    if (itemIndex == null) {
      print("itemIndex == null 일때");
      throw Exception('No item index provided');
    }
    return "https://api.cosmosx.co.kr/free/$itemIndex";
  }

  String? extractMiddleValue(String url) {
    final parts = url.split('/'); // '/'를 기준으로 URL 분리
    return parts.length > 3 ? parts[3] : null; // 3번째 요소 추출 (index 3)
  }

  Future<PostWithComments> _getFreeData() async {
    final url = constructUrl();
    final http.Response res = await http.get(Uri.parse(url));

    if (res.statusCode != 200) {
      throw Exception('Failed to load data from $url');
    }

    print("_getFreeData()");
    final jsonData = jsonDecode(res.body) as Map<String, dynamic>;
    final post = Model.fromJson(jsonData['post']);
    final comments = (jsonData['comments'] as List).map<CommentP>((data) => CommentP.fromJson(data)).toList();

    return PostWithComments(post: post, comments: comments);
  }

  @override
  void initState() {
    super.initState();
    _FreePostComment = _getFreeData();

    if (widget.extraData == null) {
      extractMenuMapData2(widget.itemIndex);
    } else {
      // 전달된 데이터 사용
      currentIndex = widget.extraData!['currentIndex'];
      mappedIds = widget.extraData!['mappedIds'];
    }
  }

  Future<void> extractMenuMapData2(String? itemIndex) async {
    if (itemIndex == null) {
      print('Error: itemIndex is null');
      return;
    }

    try {
      // 서버에서 게시글 데이터를 가져올 API URL
      final url = "https://api.cosmosx.co.kr/free/$itemIndex";
      print('Fetching data from: $url');

      // 서버 요청
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // JSON 데이터를 디코드
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

        // mappedIds와 currentIndex 추출
        final ids = (jsonData['mappedIds'] as List<dynamic>).map((id) => id).toList(); // 명시적 변환
        final index = jsonData['currentIndex'] as int; // currentIndex 가져오기

        // 상태 업데이트
        setState(() {
          mappedIds = ids;
          currentIndex = index;

          // 필요하면 key도 추가 설정 (랜덤 생성 또는 특정 값 사용)또는
          final key = UniqueKey(); // 고유한 키 생성
          extraData = {
            'key': key,
            'currentIndex': currentIndex,
            'mappedIds': mappedIds,
          };
        });

        print('Data loaded successfully: mappedIds = $mappedIds, currentIndex = $currentIndex');
      } else {
        throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  /// ✅ **이전글 & 다음글 이동을 위한 공통 함수**
  Map<String, dynamic>? getUpdatedExtraData(bool isPrevious) {
    print('${isPrevious ? "이전글" : "다음글"} extraData: ${widget.extraData}');

    final extraData = widget.extraData;
    print('${isPrevious ? "이전글" : "다음글"} extraData length: ${widget.extraData?.length}');

    final currentIndex = extraData?['currentIndex'] as int? ?? 0;
    print('${isPrevious ? "이전글" : "다음글"} currentIndex: $currentIndex');

    final mappedIds = extraData?['mappedIds'] as List<int>? ?? [];
    print('${isPrevious ? "이전글" : "다음글"} mappedIds 갯수: ${mappedIds.length}');

    if (isPrevious && currentIndex < mappedIds.length) {
      final updatedIndex = mappedIds.length - 1 - currentIndex;
      print('이전글 updatedIndex: $updatedIndex');
      final newItemIndex = mappedIds[updatedIndex - 1];
      print('이전글 newItemIndex: $newItemIndex');

      return {
        'newItemIndex': newItemIndex,
        'currentIndex': currentIndex + 1,
        'mappedIds': mappedIds,
      };
    }

    if (!isPrevious && currentIndex > 0) {
      final updatedIndex = mappedIds.length - 1 - currentIndex;
      print('다음글 updatedIndex: $updatedIndex');
      final newItemIndex = mappedIds[updatedIndex + 1];
      print('다음글 newItemIndex: $newItemIndex');

      return {
        'newItemIndex': newItemIndex,
        'currentIndex': currentIndex - 1,
        'mappedIds': mappedIds,
      };
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // 로그인 여부를 확인
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.username.isNotEmpty;
    final currentUser = userProvider.nickname; // 현재 로그인된 사용자 이름
    final mappedCount = mappedIds.length;

    return Scaffold(
      appBar: BaseAppBar(title: widget.label, appBar: AppBar()),
      body: FutureBuilder<PostWithComments>(
          future: _FreePostComment,
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
            var FreeData = snapshot.data?.post;
            var commentData = snapshot.data!.comments;
            final quillController = quill.QuillController(
              document: quill.Document.fromJson(jsonDecode(FreeData!.content)),
              selection: const TextSelection.collapsed(offset: 0),
            );

            print('currentUserId : $currentUser');
            print('FreeData11: ${jsonEncode(FreeData.toJson())}');

            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 10, 8, 1),
                        child: Column(
                          children: [
                            SizedBox(
                              width: ResponsiveWidth.getResponsiveWidth(context),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      // 현재 데이터를 가져옴
                                      final updatedExtraData = getUpdatedExtraData(true);
                                      if (updatedExtraData != null) {
                                        final extraData = {'currentIndex': updatedExtraData['currentIndex'], 'mappedIds': updatedExtraData['mappedIds']};
                                        context.go(
                                          '/$middleMunu/${updatedExtraData['newItemIndex']}',
                                          extra: ValueKey(extraData),
                                        );
                                      }
                                    },
                                    child: const Text('<', style: const TextStyle(fontSize: 15, color: Color(0xff4C6EF5))),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final updatedExtraData = getUpdatedExtraData(false);
                                      if (updatedExtraData != null) {
                                        final extraData = {'currentIndex': updatedExtraData['currentIndex'], 'mappedIds': updatedExtraData['mappedIds']};
                                        context.go(
                                          '/$middleMunu/${updatedExtraData['newItemIndex']}',
                                          extra: ValueKey(extraData),
                                        );
                                      }
                                    },
                                    child: const Text('>', style: const TextStyle(fontSize: 15, color: Color(0xff4C6EF5))),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: ResponsiveWidth.getResponsiveWidth(context),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SelectableText(
                                  FreeData.title,
                                  style: Theme.of(context).textTheme.displayMedium,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: ResponsiveWidth.getResponsiveWidth(context),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                                                  child: Icon(
                                                    // Icons.add_chart,
                                                    Icons.import_contacts_sharp,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                    'NO:'
                                                    // ' ${FreeData.id},'
                                                    '${mappedCount - currentIndex}',
                                                    style: const TextStyle(color: Colors.grey, fontSize: 15)),
                                              ],
                                            ),
                                            SelectableText(FreeData.nickname ?? 'No nickname', style: const TextStyle(color: Colors.grey, fontSize: 15)),
                                            SelectableText(
                                              '조회 ${(FreeData.views ?? 0).toString()}',
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey, fontSize: 15),
                                            ),
                                            Text(DateUtil.formatDate(FreeData.created_at), style: const TextStyle(color: Colors.grey, fontSize: 15)),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: ResponsiveWidth.getResponsiveWidth(context), child: const Divider(color: Colors.black54, thickness: 0.3)),
                                      SizedBox(width: ResponsiveWidth.getResponsiveWidth(context), child: const Divider(color: Colors.black54, thickness: 0.1)),
                                      SizedBox(
                                        width: ResponsiveWidth.getResponsiveWidth(context),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: quill.QuillEditor(
                                            controller: quillController,
                                            config: quill.QuillEditorConfig(
                                              placeholder: "본문에 내용을 입력하세요",
                                              scrollable: true,
                                              autoFocus: false,
                                              showCursor: false,
                                              expands: false,
                                              padding: EdgeInsets.zero,
                                              embedBuilders: kIsWeb
                                                  ? FlutterQuillEmbeds.editorWebBuilders()
                                                  : FlutterQuillEmbeds.editorBuilders(),
                                              customStyles: const quill.DefaultStyles(
                                                paragraph: quill.DefaultTextBlockStyle(
                                                  TextStyle(
                                                    fontSize: 16.0,
                                                    height: 1.5, // 줄 간격 설정 (1.5배)
                                                    color: Colors.black,
                                                  ),
                                                  quill.HorizontalSpacing(6, 6), // 좌/우 간격 (HorizontalSpacing 사용)
                                                  quill.VerticalSpacing(6, 0),   // 단락 간 간격 (VerticalSpacing 사용)
                                                  quill.VerticalSpacing(0, 0),   // 추가 간격 (필요 시 조정)
                                                  null, // BoxDecoration (필요 시 설정)
                                                ),
                                              ),// ✅ 이미지 빌더 추가
                                            ),
                                            focusNode: FocusNode(),
                                            scrollController: ScrollController(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: ResponsiveWidth.getResponsiveWidth(context), child: const Divider(color: Colors.black54, thickness: 0.1)),
                                      SizedBox(width: ResponsiveWidth.getResponsiveWidth(context), child: const Divider(color: Colors.black54, thickness: 0.3)),
                                      SizedBox(
                                        width: ResponsiveWidth.getResponsiveWidth(context),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          // "목록"과 오른쪽 버튼 그룹 사이 간격 확보
                                          children: <Widget>[
                                            // 왼쪽 "목록" 버튼
                                            TextButton(
                                              onPressed: () {
                                                // 목록 버튼 로직 (예: 뒤로 가기)pushReplacement
                                                context.pushReplacement(
                                                  '/$middleMunu',
                                                  extra: ValueKey({}),
                                                );
                                              },
                                              child: const Text('목록', style: const TextStyle(fontSize: 15)),
                                            ),
                                            HeroMode(
                                              enabled: false,
                                              child: TextButton(
                                                onPressed: () {
                                                  // context.pop();
                                                  // 현재 데이터를 가져옴
                                                  final updatedExtraData = getUpdatedExtraData(true);
                                                  if (updatedExtraData != null) {
                                                    final extraData = {'currentIndex': updatedExtraData['currentIndex'], 'mappedIds': updatedExtraData['mappedIds']};
                                                    context.go(
                                                      '/$middleMunu/${updatedExtraData['newItemIndex']}',
                                                      extra: ValueKey(extraData),
                                                    );
                                                  }
                                                },
                                                child: const Text('< 이전글', style: const TextStyle(fontSize: 15)),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // context.pop();
                                                final updatedExtraData = getUpdatedExtraData(false);
                                                if (updatedExtraData != null) {
                                                  final extraData = {'currentIndex': updatedExtraData['currentIndex'], 'mappedIds': updatedExtraData['mappedIds']};
                                                  context.go(
                                                    '/$middleMunu/${updatedExtraData['newItemIndex']}',
                                                    extra: ValueKey(extraData),
                                                  );
                                                }
                                              },
                                              child: const Text('다음글 >', style: const TextStyle(fontSize: 15)),
                                            ),
                                            // 오른쪽 버튼 그룹
                                            Row(
                                              children: [
                                                if (isLoggedIn)
                                                  FreeData.nickname == currentUser
                                                      ? Row(
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                final itemIndex = widget.itemIndex ?? Uri.base.queryParameters['itemIndex'];
                                                                final updateIdParam = itemIndex;

                                                                // 수정 페이지로 이동
                                                                context.go(
                                                                  '/$middleMunu/$updateIdParam/update',
                                                                  extra: UniqueKey(),
                                                                );
                                                              },
                                                              child: const Text('수정', style: const TextStyle(fontSize: 15)),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                // 삭제 로직
                                                              },
                                                              child: const Text('삭제', style: const TextStyle(fontSize: 15)),
                                                            ),
                                                          ],
                                                        )
                                                      : Row(
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                // 추천 로직
                                                              },
                                                              child: const Text('추천', style: const TextStyle(fontSize: 15)),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                // 비추천 로직
                                                              },
                                                              child: const Text('비추천', style: const TextStyle(fontSize: 15)),
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
                        child: FreebuildCommentList(
                          commentData: commentData,
                          itemIndex: widget.itemIndex,
                          updateVisibility: _updateFloatingActionButtonVisibility,
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
      floatingActionButton: _isFloatingActionButtonVisible ? const NaviFloatingAction() : null,
      floatingActionButtonLocation: _isFloatingActionButtonVisible ? FloatingActionButtonLocation.endFloat : FloatingActionButtonLocation.endFloat, // Adjust as needed//
    );
  }
}
