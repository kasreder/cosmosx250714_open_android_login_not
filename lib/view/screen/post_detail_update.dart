import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import '../../../../../provider/user_provider.dart';
import '../../util/global_notifier.dart';
import '../widget/appbar.dart';
import '../widget/drawer.dart';
import 'board/community/free/comm_free_details_screen.dart';

class PostDetailUpdate extends StatefulWidget {
  final String? itemIndex;
  final String middleMunu;
  final String topMunu;

  const PostDetailUpdate({
    super.key,
    required String label,
    this.itemIndex,
    required this.middleMunu, required this.topMunu,
  });

  @override
  State<StatefulWidget> createState() => PostDetailUpdateState();
}

class PostDetailUpdateState extends State<PostDetailUpdate> {
  final _updateFormKey = GlobalKey<FormState>();
  late quill.QuillController _controller;
  late FocusNode _editorFocusNode;
  late FocusNode _editorFocusNode2;
  late ScrollController _editorScrollController;
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = true;
  bool _isReadOnly = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _controller = quill.QuillController.basic();
    _editorFocusNode = FocusNode();
    _editorFocusNode2 = FocusNode();
    _editorScrollController = ScrollController();
    _editorFocusNode.unfocus(); // FocusNode를 비활성화 상태로 만듦
    _editorFocusNode2.unfocus(); // FocusNode를 비활성화 상태로 만듦
    _loadPostData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPostData() async {
    try {
      final response =
          await Dio().get('https://api.cosmosx.co.kr/${widget.middleMunu}/${widget.itemIndex}');
      print('Response: ${response.data}');

      if (response.statusCode == 200) {
        var data = response.data;
        print('Data: $data');

        if (data.containsKey('post')) {
          var post = data['post'];

          setState(() {
            _titleController.text = post['title'] ?? ''; // 제목 데이터 반영

            var content = post['content'];
            if (content is List<dynamic>) {
              _controller = quill.QuillController(
                document: quill.Document.fromJson(content),
                selection: const TextSelection.collapsed(offset: 0),
              );
            } else if (content is String) {
              try {
                var decodedContent = json.decode(content);
                if (decodedContent is List<dynamic>) {
                  _controller = quill.QuillController(
                    document: quill.Document.fromJson(decodedContent),
                    selection: const TextSelection.collapsed(offset: 0),
                  );
                } else {
                  _errorMessage = '콘텐츠 형식이 올바르지 않습니다.';
                }
              } catch (e) {
                _errorMessage = '콘텐츠 파싱 오류: $e';
              }
            } else {
              _errorMessage = '콘텐츠 형식이 올바르지 않습니다.';
            }

            _isLoading = false; // 데이터 로드 완료 시 로딩 종료
          });
        } else {
          setState(() {
            _errorMessage = '게시물 데이터를 찾을 수 없습니다.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = '서버 응답이 올바르지 않습니다. 상태 코드: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '데이터 로딩 중 오류 발생: $e';
        _isLoading = false;
      });
      print('Error loading post data: $e');
    }
  }

  Future<void> _updatePost(UserProvider userProvider) async {
    if (_updateFormKey.currentState!.validate()) {
      try {
        final response = await Dio().post(
          'https://api.cosmosx.co.kr/${widget.middleMunu}/${widget.itemIndex}/update',
          options: Options(
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer ${userProvider.accessToken}',
            },
          ),
          data: jsonEncode(<String, dynamic>{
            'title': _titleController.text,
            'content': jsonEncode(_controller.document.toDelta().toJson()),
            'user_id': userProvider.id
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('수정 완료!')));
          Navigator.pop(context, true); // 수정 성공 시 true 반환
          print('수정 완료!');
          // 성공적으로 작성되었을 때의 네비게이션 처리
          if (kIsWeb) {
            print('수정 완료!수정 완료!수정 완료!');
            // Navigator.pop(context);
            context.go('/${widget.topMunu}/${widget.middleMunu}/${widget.itemIndex}');
            refreshNotifier.value++;
          } else {
            print('수수수정 완료!수정 완료!수정 완료!');
            Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => FreeDetailsScreen(
                label: '수정된 글',
                itemIndex: widget.itemIndex,
              ),
            ));
          }
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('수정 실패')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('수정 중 오류 발생')));
        print('Error updating post: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _controller.readOnly = _isReadOnly;
    MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: BaseAppBar(title: "글 수정", appBar: AppBar()),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Form(
                key: _updateFormKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    const Text('글수정 페이지'),
                    TextFormField(
                      focusNode: _editorFocusNode,
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: '제목'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '제목을 입력하세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: quill.QuillSimpleToolbar(
                        controller: _controller,
                        config: quill.QuillSimpleToolbarConfig(
                          embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                        ),
                      ),
                    ),
                    Container(
                      height: 400,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: quill.QuillEditor.basic(
                        controller: _controller,
                        scrollController: ScrollController(),
                        config: quill.QuillEditorConfig(
                          placeholder: "본문에 내용을 입력하세요",
                          scrollable: true,
                          autoFocus: true,
                          expands: true,
                          // padding: EdgeInsets.zero,
                          textSelectionThemeData: TextSelectionThemeData(
                            cursorColor: Colors.purple,
                            // 커서 색상을 보라색으로 설정
                            selectionColor: Colors.purple.withOpacity(0.5),
                            // 선택 영역의 색상 설정 (필요에 따라)
                            selectionHandleColor:
                            Colors.purple, // 선택 핸들 색상 설정 (필요에 따라)
                          ),
                          embedBuilders: kIsWeb
                              ? FlutterQuillEmbeds.editorWebBuilders()
                              : FlutterQuillEmbeds.editorBuilders(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () => _updatePost(userProvider),
                        child: const Text('수정 완료'),
                      ),
                    ),
                    // Text('1111택'),
                    // Text('게시판 선택'),
                    // Text('게시판 선택'),
                    // Text('게시판 선택'),
                    // Text('게시판 선택'),
                    // Text('게시판 선택'),
                    // Text('게시판 선택'),
                    // Text('게시판 선택'),
                    // Text('게시판 선택'),
                    // Text('게시판 선택'),
                    // Text('2게시판 선택'),
                    // Text('게시판 선택'),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        child: Icon(!_isReadOnly ? Icons.lock : Icons.edit),
        onPressed: () => setState(() => _isReadOnly = !_isReadOnly),
      ),
      drawer: const BaseDrawer(),
    );
  }
}
