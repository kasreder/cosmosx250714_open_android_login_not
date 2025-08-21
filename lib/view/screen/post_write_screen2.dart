//웹 quill
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart' as quill show Delta;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

import '../../../provider/user_provider.dart';
import '../../../util/global_notifier.dart';
import '../widget/appbar.dart';
import '../widget/drawer.dart';
//PostWriteScreen2
//PostWrite
class PostWriteScreen2 extends StatefulWidget {
  const PostWriteScreen2({
    super.key,
    this.passedSubMenuCode,
  });

  final String? passedSubMenuCode;

  @override
  State<PostWriteScreen2> createState() => _PostWriteScreen2State();
}

class _PostWriteScreen2State extends State<PostWriteScreen2> {
  late quill.QuillController _controller;
  final ImagePicker _picker = ImagePicker();
  String? selectedMenu;
  String? selectedSubMenu;
  String? subMenuId;
  List<String> menuOptions = [];
  List<String> subMenus = [];
  ScrollController? _scrollController;
  final TextEditingController _titleController = TextEditingController();
  final Map<String, String> _uuidToUrlMap = {};
  final Uuid _uuid = Uuid();

  List<List<String>> subMenus1 = [
    ["새소식", "nwn", ""],
    ["뉴스", "news", "1"],
  ];

  List<List<String>> subMenus2 = [
    ["공지/제휴", "nwn1", ""],
    ["공지사항", "notice", "2"],
  ];

  List<List<String>> subMenus3 = [
    ["커뮤니티", "comm", ""],
    ["자유게시판", "free", "4"],
  ];

  List<List<String>> subMenus4 = [
    ["정보자료", "comm1", ""],
    ["기록/일지", "record", "5"],
  ];

  List<List<List<String>>> subMenusList = [];

  @override
  void initState() {
    super.initState();
    _controller = quill.QuillController.basic();
    _scrollController = ScrollController();
    _controller.addListener(() {
      final deltaJson = _controller.document.toDelta().toJson();
      print('✍️ 실시간 에디터 입력값: $deltaJson');
    });
    subMenusList = [subMenus1, subMenus2, subMenus3, subMenus4];
    menuOptions = getMenuOptions();
    _initializeSelectedMenus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController?.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _initializeSelectedMenus() {
    if (widget.passedSubMenuCode != null) {
      String passedSubMenuCode = widget.passedSubMenuCode!;
      var higherMenu = getHigherMenuFromSubMenuCode(passedSubMenuCode);
      if (higherMenu.isNotEmpty) {
        setState(() {
          selectedMenu = higherMenu['menuDisplayName'];
          subMenus = getSubMenus(selectedMenu!);
          selectedSubMenu = getSubMenuDisplayName(passedSubMenuCode);
          subMenuId = getBoardIdFromSubMenuCode(passedSubMenuCode);
        });
      }
    } else {
      setState(() {
        selectedMenu = null;
        selectedSubMenu = null;
        subMenuId = null;
        subMenus = [];
      });
    }
  }

  String _getMimeSubType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      case 'webp':
        return 'webp';
      case 'svg':
        return 'svg+xml';
      default:
        return 'jpeg'; // 기본값
    }
  }

  @override
  void didUpdateWidget(PostWriteScreen2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.passedSubMenuCode != oldWidget.passedSubMenuCode) {
      _initializeSelectedMenus();
    }
  }

  List<String> getMenuOptions() {
    List<String> menuOptions = [];
    for (var subMenus in subMenusList) {
      String menuDisplayName = subMenus[0][0];
      menuOptions.add(menuDisplayName);
    }
    return menuOptions;
  }

  List<String> getSubMenus(String selectedMenu) {
    for (var subMenus in subMenusList) {
      String menuDisplayName = subMenus[0][0];
      if (menuDisplayName == selectedMenu) {
        return subMenus.skip(1).map((item) => item[0]).toList();
      }
    }
    return [];
  }

  String getSubMenuCode(String subMenuDisplayName) {
    for (var subMenus in subMenusList) {
      for (var item in subMenus) {
        if (item[0] == subMenuDisplayName) {
          return item[1];
        }
      }
    }
    return '';
  }

  String getBoardIdFromSubMenuCode(String subMenuCode) {
    for (var subMenus in subMenusList) {
      for (var item in subMenus) {
        if (item[1] == subMenuCode) {
          return item[2];
        }
      }
    }
    return '';
  }

  Map<String, String> getHigherMenuFromSubMenuCode(String subMenuCode) {
    for (var subMenus in subMenusList) {
      for (var item in subMenus) {
        if (item[1] == subMenuCode) {
          return {
            'menuDisplayName': subMenus[0][0],
            'menuCode': subMenus[0][1],
          };
        }
      }
    }
    return {};
  }

  String getSubMenuDisplayName(String subMenuCode) {
    for (var subMenus in subMenusList) {
      for (var item in subMenus) {
        if (item[1] == subMenuCode) {
          return item[0];
        }
      }
    }
    return '';
  }

  void _handleSubmit(UserProvider userProvider) async {
    String? accessToken = userProvider.accessToken;
    // String nickname = userProvider.nickname;
    int id = userProvider.id;
    String? board = subMenuId;
    String title = _titleController.text;

    if (title.isEmpty) {
      _showError('제목을 입력해주세요.');
      return;
    }

    if (_controller.document.isEmpty()) {
      _showError('내용을 입력해주세요.');
      return;
    }

    if (selectedMenu == null || selectedSubMenu == null || subMenuId == null) {
      _showError('메뉴와 게시판을 선택해주세요.');
      return;
    }

    if (accessToken == null) {
      _showError('액세스 토큰이 없습니다. 로그인이 필요합니다.');
      return;
    }

    print('글을 업로드하는 최종코드A ~~~~~~~~~: ');
    String content = await _replaceUuidWithUrls();
    print('글을 업로드하는 최종코드B ~~~~~~~~~: $content');

    const String url = "https://api.cosmosx.co.kr/";

    try {
      // 1️⃣ 페이로드를 변수에 담아둡니다.
      final contentP = <String, dynamic>{
        'user_id': id,
        'board_id': board ?? '',
        'title': title,
        'content': content,
      };

      // 2️⃣ 요청 직전에 디버그용으로 콘솔에 찍어봅니다.
      print('🆙 Request Payload: ${jsonEncode(contentP)}');
      final response = await Dio().post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
          },
        ),
        // data: jsonEncode(<String, dynamic>{
        //   'user_id': id,
        //   'board_id': board ?? '',
        //   'title': title,
        //   'content': content,
        // }
        // ),
        data: jsonEncode(contentP),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('responseData: $responseData');
        if (responseData != null) {
          userProvider.updatePoints(responseData['points']);
        }

        _titleController.clear();
        _controller.clear();
        _uuidToUrlMap.clear();

        String subMenuCode = getRedirectPath();
        String path = generatePath(subMenuCode);
        context.push('$path', extra: UniqueKey());
        refreshNotifier.value++;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('글이 성공적으로 작성되었습니다.')),
        );
      } else {
        _showError('데이터 전송에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (error) {
      print('데이터 전송 중 오류 발생: $error');
      _showError('데이터 전송 중 오류가 발생했습니다.');
    }
  }

  Future<String> _replaceUuidWithUrls() async {
    final deltaJson = _controller.document.toDelta();
    final newDelta = quill.Delta();
    print('데이터 전송  1 : $deltaJson');
    print('데이터 전송  2 : $newDelta');

    for (var op in deltaJson.toList()) {
      final data = op.data;
      final attrs = op.attributes;
      // print('데이터 전송 _replaceUuidWithUrls for 2 : $deltaJson');
      print('데이터 전송 _replaceUuidWithUrls for 2 data : $data');
      print('데이터 전송 _replaceUuidWithUrls for 2 attrs : $attrs');

      if (op.isInsert &&
          data is Map<String, dynamic> &&
          data.containsKey('image')) {
        final imageKey = data['image']; // UUID or URL
        final imageUrl = _uuidToUrlMap[imageKey] ?? imageKey;

        newDelta.insert({'image': imageUrl}, attrs);
      } else {
        newDelta.insert(data, attrs);
      }
    }

    return jsonEncode(newDelta.toJson());
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: BaseAppBar(
        title: subMenus.isNotEmpty ? '$selectedSubMenu 글작성' : '글작성 페이지',
        appBar: AppBar(),
      ),
      drawer: const BaseDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          DropdownButtonFormField<String>(
            value: selectedMenu,
            hint: const Text('메뉴 선택'),
            onChanged: (newValue) {
              setState(() {
                selectedMenu = newValue;
                subMenus = getSubMenus(selectedMenu!);
                selectedSubMenu = null;
                subMenuId = null;
              });
            },
            items: menuOptions.map((menu) {
              return DropdownMenuItem(
                value: menu,
                child: Text(menu),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedSubMenu,
            hint: const Text('게시판 선택'),
            onChanged: (newValue) {
              setState(() {
                selectedSubMenu = newValue;
                String subMenuCode = getSubMenuCode(selectedSubMenu ?? '');
                subMenuId = getBoardIdFromSubMenuCode(subMenuCode);
                var higherMenu = getHigherMenuFromSubMenuCode(subMenuCode);
                if (higherMenu.isNotEmpty) {
                  selectedMenu = higherMenu['menuDisplayName'];
                  subMenus = getSubMenus(selectedMenu!);
                }
              });
            },
            items: subMenus.map((board) {
              return DropdownMenuItem(
                value: board,
                child: Text(board),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '제목',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: quill.QuillSimpleToolbar(
              controller: _controller,
              config: quill.QuillSimpleToolbarConfig(
                showClipboardCut: true,
                showClipboardCopy: true,
                showClipboardPaste: true,
                embedButtons: FlutterQuillEmbeds.toolbarButtons(
                  imageButtonOptions: QuillToolbarImageButtonOptions(
                    imageButtonConfig: QuillToolbarImageConfig(
                      onRequestPickImage: (context) async {
                        final pickedFile = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile == null) return null;
                        return pickedFile.path;
                      },
                      onImageInsertedCallback: (imagePath) async {
                        String uuid = _uuid.v4();
                        String fileName = path.basename(imagePath);
                        print('Uploading image with UUID: $uuid, fileName: $fileName');

                        // 1. 현재 Delta에서 임시 blob URL 찾기
                        final delta = _controller.document.toDelta();
                        int? blobIndex;
                        String? blobUrl;
                        for (int i = 0; i < delta.length; i++) {
                          final op = delta.toList()[i];
                          if (op.isInsert &&
                              op.data is Map &&
                              (op.data as Map).containsKey('image')) {
                            final image = (op.data as Map)['image'] as String;
                            if (image.startsWith('blob:')) {
                              blobIndex = i;
                              blobUrl = image;
                              break;
                            }
                          }
                        }
                        print('Found blob URL at index $blobIndex: $blobUrl');

                        // 2. 이미지 업로드
                        String? imageUrl = await _uploadImage(imagePath, fileName, uuid, context);
                        print('onImageInsertedCallback imageUrl: $imageUrl');

                        if (imageUrl != null && imageUrl.isNotEmpty) {
                          _uuidToUrlMap[uuid] = imageUrl;

                          // 3. blob URL 제거 및 서버 URL 삽입
                          if (blobIndex != null && blobUrl != null) {
                            // 기존 blob URL 제거
                            final newDelta = quill.Delta();
                            int currentIndex = 0;
                            for (var op in delta.toList()) {
                              if (currentIndex == blobIndex &&
                                  op.isInsert &&
                                  op.data is Map &&
                                  (op.data as Map)['image'] == blobUrl) {
                                // blob URL을 서버 URL로 교체
                                newDelta.insert({'image': imageUrl}, op.attributes);
                              } else {
                                newDelta.insert(op.data, op.attributes);
                              }
                              currentIndex++;
                            }
                            _controller.document = quill.Document.fromDelta(newDelta);
                            print('Replaced blob URL: $blobUrl with server URL: $imageUrl');
                          } else {
                            // blob URL이 없으면 현재 커서 위치에 삽입
                            final index = _controller.selection.baseOffset;
                            _controller.document.insert(
                              index,
                              quill.BlockEmbed.image(imageUrl),
                            );
                            print('Inserted image with URL: $imageUrl at index: $index');
                          }
                        } else {
                          print('Image upload failed, removing blob URL if exists: $uuid');
                          // 업로드 실패 시 blob URL 제거
                          if (blobIndex != null && blobUrl != null) {
                            final newDelta = quill.Delta();
                            int currentIndex = 0;
                            for (var op in delta.toList()) {
                              if (currentIndex == blobIndex &&
                                  op.isInsert &&
                                  op.data is Map &&
                                  (op.data as Map)['image'] == blobUrl) {
                                // blob URL 제거 (삽입 안 함)
                              } else {
                                newDelta.insert(op.data, op.attributes);
                              }
                              currentIndex++;
                            }
                            _controller.document = quill.Document.fromDelta(newDelta);
                            print('Removed blob URL: $blobUrl due to upload failure');
                          }
                          _showError('이미지 업로드에 실패했습니다.');
                        }
                      },

                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 300,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: quill.QuillEditor(
              controller: _controller,
              scrollController: ScrollController(),
              config: quill.QuillEditorConfig(
                placeholder: "본문에 내용을 입력하세요",
                scrollable: true,
                // autoFocus: true,
                expands: true,
                enableInteractiveSelection: true,
                readOnlyMouseCursor: SystemMouseCursors.click,
                padding: EdgeInsets.zero,
                textSelectionThemeData: TextSelectionThemeData(
                  cursorColor: Colors.purple,
                  selectionColor: Colors.purple.withOpacity(0.5),
                  selectionHandleColor: Colors.purple,
                ),
                embedBuilders: kIsWeb
                    ? FlutterQuillEmbeds.editorWebBuilders()
                    : FlutterQuillEmbeds.editorBuilders(),
              ),
              focusNode: FocusNode(),
            ),
          ),
          const SizedBox(height: 16),
          Text('작성자: ${userProvider.nickname}'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text('취소하기'),
              ),
              ElevatedButton(
                onPressed: () => _handleSubmit(userProvider),
                child: const Text('작성하기'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getRedirectPath() {
    if (subMenuId == null) return '/';
    for (var subMenus in subMenusList) {
      for (var item in subMenus) {
        if (item[2] == subMenuId) {
          return '${item[1]}';
        }
      }
    }
    return '/';
  }

  String generatePath(String subMenuCode) {
    Map<String, String> higherMenu = getHigherMenuFromSubMenuCode(subMenuCode);
    if (higherMenu.isNotEmpty) {
      String menuCode = higherMenu['menuCode'] ?? '';
      return '/$menuCode/$subMenuCode/';
    }
    return '/';
  }

  Future<String?> _uploadImage(
      String imagePath,
      String fileName,
      String uuid,
      BuildContext context,
      ) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String? accessToken = userProvider.accessToken;

      if (accessToken == null) {
        _showError('액세스 토큰이 없습니다. 로그인이 필요합니다.');
        return null;
      }

      var dio = Dio();
      var formData = FormData.fromMap({
        'fileName': fileName,
        'uuid': uuid,
      });

      if (kIsWeb) {
        final pickedFile = XFile(imagePath);
        final bytes = await pickedFile.readAsBytes();

        final originalFileName = path.basename(pickedFile.path);
        final extension = originalFileName.contains('.') ? originalFileName.split('.').last : 'jpg';
        final fileNameWithExt = '$uuid.$extension';

        formData.files.add(MapEntry(
          'images',
          MultipartFile.fromBytes(
            bytes,
            filename: fileNameWithExt,
            contentType: MediaType('image', _getMimeSubType(fileNameWithExt)),
          ),
        ));
      } else {
        formData.files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(imagePath, filename: fileName),
        ));
      }

      final response = await dio.post(
        'https://api.cosmosx.co.kr/api/images/uploads/data/tmp',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('응답값 responseData: $responseData');
        print('responseData["url"]: ${responseData['url']}');
        print('responseData["imageUrls"]: ${responseData['imageUrls']}');

        if (responseData is Map && responseData.containsKey('imageUrls')) {
          final imageUrls = responseData['imageUrls'];
          String reImageUrl;
          if (imageUrls is List && imageUrls.isNotEmpty) {
            final imageUrl = imageUrls[0] as String?;
            if (imageUrl != null && imageUrl.isNotEmpty) {
              print('Returning image URL: $imageUrl');
              reImageUrl = imageUrl;
              return reImageUrl;
            } else {
              print('Error: imageUrls[0] is null or empty');
              _showError('이미지 URL이 유효하지 않습니다.');
              return null;
            }
          } else {
            print('Error: imageUrls is not a non-empty List');
            _showError('서버 응답의 imageUrls 형식이 올바르지 않습니다.');
            return null;
          }
        } else {
          print('Error: responseData does not contain "imageUrls" key');
          _showError('서버 응답에 imageUrls가 포함되어 있지 않습니다.');
          return null;
        }
      } else {
        print('Image upload failed with status: ${response.statusCode}');
        _showError('이미지 업로드 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('이미지 업로드 오류: $e');
      _showError('이미지 업로드 중 오류가 발생했습니다.');
      return null;
    }
  }



}




