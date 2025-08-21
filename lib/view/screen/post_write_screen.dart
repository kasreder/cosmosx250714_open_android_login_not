//플러터 quill
import 'dart:async';
import 'dart:convert';
// import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';
import 'package:http_parser/http_parser.dart';

import '../../../provider/user_provider.dart';
import '../../../util/global_notifier.dart';
import '../widget/appbar.dart';
import '../widget/drawer.dart';

import 'platform_view_stub.dart'
if (dart.library.ui_web) 'platform_view_web.dart';
//PostWriteScreen2
class PostWrite extends StatefulWidget {
  const PostWrite({super.key, this.passedSubMenuCode});

  final String? passedSubMenuCode;

  @override
  State<PostWrite> createState() => _PostWriteState();
}

class _PostWriteState extends State<PostWrite> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  InAppWebViewController? _webViewCtrl;
  bool _isLoading = true;
  String? selectedMenu;
  String? selectedSubMenu;
  String? subMenuId;
  List<String> menuOptions = [];
  List<String> subMenus = [];
  StreamSubscription? _htmlSub;
  late final String _iframeViewType;

  // HTML에서 실시간 받아오는 제목·본문 Delta JSON
  String _titleFromHtml = '';
  String _contentFromHtml = '';

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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print('[1] PostWrite: initState called');
    subMenusList = [subMenus1, subMenus2, subMenus3, subMenus4];
    print('[2] PostWrite: subMenusList initialized with ${subMenusList.length} menus');
    menuOptions = getMenuOptions();
    print('[3] PostWrite: menuOptions initialized with ${menuOptions.length} options');
    _initializeSelectedMenus();
    print('[4] PostWrite: _initializeSelectedMenus called');
    // iframe viewType 생성
    _iframeViewType = 'quill-iframe-${const Uuid().v4()}';
    print('[6] PostWrite: _iframeViewType');

    if (kIsWeb) {
      registerQuillIframeViewFactory(_iframeViewType);

      _htmlSub = html.window.onMessage.listen((event) async {
        if (event.data is Map) {
          final data = event.data as Map;

          switch (data['type']) {
            case 'onTextChange':
              final payload = data['payload'] as Map;
              _titleFromHtml   = payload['title']   as String;
              _contentFromHtml = payload['content'] as String;
              if (mounted) setState(() {});
              break;

            case 'uploadImage':
              final String name   = data['name']   as String;
              final String mime   = data['mime']   as String;
              final String b64    = data['base64'] as String;
              final bytes = base64Decode(b64);

              final form = FormData.fromMap({
                'uuid':     name.split('.').first,
                'fileName': name,
                'images': MultipartFile.fromBytes(
                  bytes,
                  filename: name,
                  contentType: MediaType.parse(mime),
                ),
              });

              final response = await Dio().post(
                'https://api.cosmosx.co.kr/api/images/uploads/data/tmp',
                data: form,
                options: Options(headers: {
                  'Authorization': 'Bearer ${userProvider.accessToken}'
                }),
              );
              final url = (response.data['imageUrls'] as List).first as String;

              final iframe = html.document.getElementById(_iframeViewType);
              if (iframe is html.IFrameElement) {
                iframe.contentWindow?.postMessage(
                  {'type': 'imageUploaded', 'url': url},
                  '*',
                );
              }
              break;
          }
        }
      });
    }

    // if (kIsWeb) {
    //   // ① Flutter Web 에서 iframe 등록
    //   print('[7] PostWrite: Running in web environment');
    //   ui.platformViewRegistry.registerViewFactory(
    //     _iframeViewType,
    //         (int viewId) {
    //       return html.IFrameElement()
    //         ..id = _iframeViewType
    //         ..src = 'assets/poke/editor/index.html'
    //         ..style.border = 'none'
    //         ..style.width = '100%'
    //         ..style.height = '100%';
    //     },
    //   );
    //
    //   // ② HTML → Flutter 메시지 수신
    //   _htmlSub = html.window.onMessage.listen((event) async {
    //     print('[8] PostWrite: Received message from iframe: ${event.data}');
    //     if (event.data is Map) {
    //       final data = event.data as Map;
    //
    //       switch (data['type']) {
    //         case 'onTextChange':
    //           print('[8-1] PostWrite onTextChange');
    //           // 기존 onTextChange 처리
    //           final payload = data['payload'] as Map;
    //           _titleFromHtml   = payload['title']   as String;
    //           _contentFromHtml = payload['content'] as String;
    //           print('[onTextChange] title=$_titleFromHtml, contentLen=${_contentFromHtml.length}');
    //           if (mounted) setState(() {});
    //           break;
    //
    //         case 'uploadImage':
    //           print('[8-2] PostWrite uploadImage');
    //           // HTML 쪽에서 보낸 base64, 파일명, mime
    //           final String name   = data['name']   as String;
    //           final String mime   = data['mime']   as String;
    //           final String b64    = data['base64'] as String;
    //           final bytes = base64Decode(b64);
    //
    //           // FormData 구성
    //           final form = FormData.fromMap({
    //             'uuid':     name.split('.').first,
    //             'fileName': name,
    //             'images': MultipartFile.fromBytes(
    //               bytes,
    //               filename: name,
    //               contentType: MediaType.parse(mime),
    //             ),
    //           });
    //
    //           print('[8-3] PostWrite form');
    //           // 서버 업로드
    //           final response = await Dio().post(
    //             'https://api.cosmosx.co.kr/api/images/uploads/data/tmp',
    //             data: form,
    //             options: Options(headers: {
    //               'Authorization': 'Bearer ${userProvider.accessToken}'
    //             }),
    //           );
    //           // 반환된 URL
    //           final url = (response.data['imageUrls'] as List).first as String;
    //
    //           // ③ 업로드 완료 후 iframe 에 응답
    //           final iframe = html.document.getElementById(_iframeViewType);
    //           if (iframe is html.IFrameElement) {
    //             iframe.contentWindow?.postMessage(
    //               {'type': 'imageUploaded', 'url': url},
    //               '*',
    //             );
    //           }
    //           break;
    //       }
    //     }
    //   });
    // }
  }


  @override
  void dispose() {
    print('[12] PostWrite: dispose called');
    if (kIsWeb) {
      _htmlSub?.cancel();
      print('[13] PostWrite: _htmlSub cancelled');
    }
    super.dispose();
  }

  void _initializeSelectedMenus() {
    print('[14] PostWrite: _initializeSelectedMenus called with passedSubMenuCode: ${widget.passedSubMenuCode}');
    if (widget.passedSubMenuCode != null) {
      String passedSubMenuCode = widget.passedSubMenuCode!;
      var higherMenu = getHigherMenuFromSubMenuCode(passedSubMenuCode);
      print('[15] PostWrite: higherMenu retrieved: $higherMenu');
      if (higherMenu.isNotEmpty) {
        setState(() {
          selectedMenu = higherMenu['menuDisplayName'];
          subMenus = getSubMenus(selectedMenu!);
          selectedSubMenu = getSubMenuDisplayName(passedSubMenuCode);
          subMenuId = getBoardIdFromSubMenuCode(passedSubMenuCode);
          print('[16] PostWrite: Selected menu: $selectedMenu, subMenu: $selectedSubMenu, subMenuId: $subMenuId');
        });
      }
    } else {
      setState(() {
        selectedMenu = null;
        selectedSubMenu = null;
        subMenuId = null;
        subMenus = [];
        print('[17] PostWrite: Menus reset to null');
      });
    }
  }

  @override
  void didUpdateWidget(PostWrite oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('[18] PostWrite: didUpdateWidget called, old passedSubMenuCode: ${oldWidget.passedSubMenuCode}, new: ${widget.passedSubMenuCode}');
    if (widget.passedSubMenuCode != oldWidget.passedSubMenuCode) {
      _initializeSelectedMenus();
      print('[19] PostWrite: _initializeSelectedMenus called due to passedSubMenuCode change');
    }
  }

  List<String> getMenuOptions() {
    print('[20] PostWrite: getMenuOptions called');
    List<String> menuOptions = [];
    for (var subMenus in subMenusList) {
      String menuDisplayName = subMenus[0][0];
      menuOptions.add(menuDisplayName);
    }
    print('[21] PostWrite: Returning ${menuOptions.length} menu options');
    return menuOptions;
  }

  List<String> getSubMenus(String selectedMenu) {
    print('[22] PostWrite: getSubMenus called with selectedMenu: $selectedMenu');
    for (var subMenus in subMenusList) {
      String menuDisplayName = subMenus[0][0];
      if (menuDisplayName == selectedMenu) {
        var result = subMenus.skip(1).map((item) => item[0]).toList();
        print('[23] PostWrite: Returning ${result.length} subMenus for $selectedMenu');
        return result;
      }
    }
    print('[24] PostWrite: No subMenus found for $selectedMenu');
    return [];
  }

  String getSubMenuCode(String subMenuDisplayName) {
    print('[25] PostWrite: getSubMenuCode called with subMenuDisplayName: $subMenuDisplayName');
    for (var subMenus in subMenusList) {
      for (var item in subMenus) {
        if (item[0] == subMenuDisplayName) {
          print('[26] PostWrite: Found subMenuCode: ${item[1]}');
          return item[1];
        }
      }
    }
    print('[27] PostWrite: No subMenuCode found for $subMenuDisplayName');
    return '';
  }

  String getBoardIdFromSubMenuCode(String subMenuCode) {
    print('[28] PostWrite: getBoardIdFromSubMenuCode called with subMenuCode: $subMenuCode');
    for (var subMenus in subMenusList) {
      for (var item in subMenus) {
        if (item[1] == subMenuCode) {
          print('[29] PostWrite: Found boardId: ${item[2]}');
          return item[2];
        }
      }
    }
    print('[30] PostWrite: No boardId found for $subMenuCode');
    return '';
  }

  Map<String, String> getHigherMenuFromSubMenuCode(String subMenuCode) {
    print('[31] PostWrite: getHigherMenuFromSubMenuCode called with subMenuCode: $subMenuCode');
    for (var subMenus in subMenusList) {
      for (var item in subMenus) {
        if (item[1] == subMenuCode) {
          var result = {'menuDisplayName': subMenus[0][0], 'menuCode': subMenus[0][1]};
          print('[32] PostWrite: Found higherMenu: $result');
          return result;
        }
      }
    }
    print('[33] PostWrite: No higherMenu found for $subMenuCode');
    return {};
  }

  String getSubMenuDisplayName(String subMenuCode) {
    print('[34] PostWrite: getSubMenuDisplayName called with subMenuCode: $subMenuCode');
    for (var subMenus in subMenusList) {
      for (var item in subMenus) {
        if (item[1] == subMenuCode) {
          print('[35] PostWrite: Found subMenuDisplayName: ${item[0]}');
          return item[0];
        }
      }
    }
    print('[36] PostWrite: No subMenuDisplayName found for $subMenuCode');
    return '';
  }

  String getRedirectPath() {
    print('[37] PostWrite: getRedirectPath called with subMenuId: $subMenuId');
    if (subMenuId == null) {
      print('[38] PostWrite: subMenuId is null, returning /');
      return '/';
    }
    for (var subMenus in subMenusList) {
      for (var item in subMenus) {
        if (item[2] == subMenuId) {
          print('[39] PostWrite: Found redirect path: ${item[1]}');
          return '${item[1]}';
        }
      }
    }
    print('[40] PostWrite: No redirect path found, returning /');
    return '/';
  }

  String generatePath(String subMenuCode) {
    print('[41] PostWrite: generatePath called with subMenuCode: $subMenuCode');
    Map<String, String> higherMenu = getHigherMenuFromSubMenuCode(subMenuCode);
    if (higherMenu.isNotEmpty) {
      String menuCode = higherMenu['menuCode'] ?? '';
      var path = '/$menuCode/$subMenuCode/';
      print('[42] PostWrite: Generated path: $path');
      return path;
    }
    print('[43] PostWrite: No higherMenu found, returning /');
    return '/';
  }

  Future<String> _prepareContentAndUploadImages(String deltaJson) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final List<dynamic> ops = jsonDecode(deltaJson);
    print('[43-1] _prepareContentAndUploadImages 진입, ops: $ops');

    for (var op in ops) {
      // 1) insert 가 Map 이고, 그 안에 image 필드가 있는 경우만 처리
      if (op is Map && op['insert'] is Map && op['insert']['image'] != null) {
        // 편하게 다룰 수 있도록 복사
        final insert = Map<String, dynamic>.from(op['insert'] as Map);
        String? src;      // 실제 이미지 src (base64 혹은 URL)
        String? wPx;      // px 단위로 붙어온 width
        String? hPx;      // px 단위로 붙어온 height

        // 2) insert['image'] 가 Map 인 경우 (url, width, height 가 담겨있을 때)
        if (insert['image'] is Map) {
          final imgMap = Map<String, dynamic>.from(insert['image'] as Map);
          src = imgMap['url'] as String?;
          wPx = imgMap['width']  as String?;
          hPx = imgMap['height'] as String?;
        }
        // 3) insert['image'] 가 String 인 경우 (직접 base64 가 넘어올 때)
        else if (insert['image'] is String) {
          src = insert['image'] as String;
        }

        // 4) base64 이면 업로드
        String? uploadedUrl;
        if (src != null && src.startsWith('data:')) {
          print('[43-2] base64 발견, 업로드 시작');
          final parts = src.split(',');
          final meta = parts.first;      // data:image/png;base64
          final b64  = parts.last;       // 실제 base64
          final mime= meta.substring(5, meta.indexOf(';')); // image/png

          final bytes = base64Decode(b64);
          final uuid  = const Uuid().v4();
          final ext   = mime.split('/').last;
          final fileName = '$uuid.$ext';

          // FormData 준비
          final form = FormData.fromMap({
            'uuid': uuid,
            'fileName': fileName,
            'images': MultipartFile.fromBytes(
              bytes,
              filename: fileName,
              contentType: MediaType.parse(mime),
            ),
          });
          print('[43-3] FormData: $form');

          // 서버 업로드
          final resp = await Dio().post(
            'https://api.cosmosx.co.kr/api/images/uploads/data/tmp',
            data: form,
            options: Options(headers: {
              'Authorization': 'Bearer ${userProvider.accessToken}'
            }),
          );
          final urls = resp.data['imageUrls'] as List<dynamic>;
          if (urls.isNotEmpty) {
            uploadedUrl = urls.first as String;
            print('[43-4] 업로드 완료 URL: $uploadedUrl');
          }
        }

        // 5) 업로드된 URL 이 있으면 op 구조 갱신
        if (uploadedUrl != null) {
          final bool hasW = wPx != null && wPx.isNotEmpty;
          final bool hasH = hPx != null && hPx.isNotEmpty;

          if (hasW || hasH) {
            // px 제거하고 숫자만
            final rawW = hasW ? wPx!.replaceAll('px', '') : '';
            final rawH = hasH ? hPx!.replaceAll('px', '') : '';
            // insert/attributes 모두 재구성
            op
              ..remove('insert')
              ..remove('attributes');
            op['insert'] = {'image': uploadedUrl};
            op['attributes'] = {
              'style': 'width: ${rawW}px; height: ${rawH}px;'
            };
          } else {
            // width/height 없으면 URL 만 교체
            op['insert']['image'] = uploadedUrl;
            op.remove('attributes');
          }
        }
      }
    }

    final result = jsonEncode(ops);
    print('[43-5] 변환 후 ops JSON: $result');
    return result;
  }


  Future<void> _handleSubmit(UserProvider userProvider) async {
    print('[51] PostWrite: _handleSubmit called');
    String? accessToken = userProvider.accessToken;
    int id = userProvider.id;
    String? board = subMenuId;
    final title = _titleFromHtml.trim();
    final content = _contentFromHtml.trim();
    print('[52] PostWrite: Submit data - userId: $id, board: $board, title: $title, content length: ${content.length}');

    if (title.isEmpty) {
      print('[53] PostWrite: Title is empty');
      _showError('제목을 입력해주세요.');
      return;
    }
    if (content.isEmpty) {
      print('[54] PostWrite: Content is empty');
      _showError('본문을 입력해주세요.');
      return;
    }

    if (selectedMenu == null || selectedSubMenu == null || subMenuId == null) {
      print('[55] PostWrite: Menu or subMenu not selected');
      _showError('메뉴와 게시판을 선택해주세요.');
      return;
    }

    if (accessToken == null) {
      print('[56] PostWrite: Access token is null');
      _showError('액세스 토큰이 없습니다. 로그인이 필요합니다.');
      return;
    }

    // 1) base64 포함된 _contentFromHtml → 이미지 업로드 & URL 교체
    final processedContent = await _prepareContentAndUploadImages(_contentFromHtml);
    // final rawOps = jsonDecode(_contentFromHtml) as List<dynamic>;
    //
    // // 2) Map each op to the desired format
    // final transformedOps = rawOps.map((op) {
    //   // op is a Map<String, dynamic>
    //   if (op is Map && op['insert'] is Map) {
    //     final insert = op['insert'] as Map;
    //     final imageField = insert['image'];
    //     // 이미지가 {url, width, height} 형태로 들어온 경우
    //     if (imageField is Map && imageField['url'] != null) {
    //       final url    = imageField['url']    as String;
    //       final width  = imageField['width']  as String? ?? '';
    //       final height = imageField['height'] as String? ?? '';
    //       return {
    //         'insert': {
    //           'image': url,
    //         },
    //         'attributes': {
    //           'style': 'width: $width; height: $height;'
    //         }
    //       };
    //     }
    //   }
    //   // 나머지 op는 그대로 반환
    //   return op;
    // }).toList();
    //
    // // 3) 재직렬화
    // final contentForServer = jsonEncode(transformedOps);

    // setState(() => _isLoading = true);
    print('[57] PostWrite: Setting _isLoading to true');
    const String url = "https://api.cosmosx.co.kr/";
    print('[577] PostWrite: Setting _isLoading to true');
    try {
      print('[5777] PostWrite: Setting _isLoading to true');
      final response = await Dio().post(
        url,
        options: Options(headers: {'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'Bearer $accessToken'}),
        data: jsonEncode(<String, dynamic>{
          'user_id': id,
          'board_id': board ?? '',
          'title': title,
          // 'content': content
          'content': processedContent
        }),
      );
      print('[58] PostWrite: Post submission response status: ${response.statusCode}');

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        print('[59] PostWrite: Post submitted successfully');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('글이 성공적으로 등록되었습니다.')));

        String subMenuCode = getRedirectPath();
        String path = generatePath(subMenuCode);
        context.push('$path', extra: UniqueKey());
        refreshNotifier.value++;
        print('[60] PostWrite: 라우팅');
        // Flutter 상태도 비우기
        _titleFromHtml = '';
        _contentFromHtml = '';

        if (kIsWeb) {
          print('[61] PostWrite: 인터넷일때 ');

          print('[611] PostWrite: 초기화 ');

          final iframe = html.document.getElementById(_iframeViewType);
          if (iframe is html.IFrameElement) {
            // HTML에서 위에 등록한 message 이벤트로 전달
            iframe.contentWindow?.postMessage({'type': 'clearInputs'}, '*');
          }

          // 메시지 전송

          // html.window.postMessage({'type': 'clearInputs'}, '*');
          print('[61111] PostWrite: 클리러 날리기 ');
          print('[Flutter->Html] clearInputs via window.postMessage');
        } else {
          print('[611111] PostWrite: else ');
          // 모바일 WebView 쪽 초기화
          _titleFromHtml = '';
          _contentFromHtml = '';
          _webViewCtrl?.evaluateJavascript(
            source: """
            window.postMessage({type:'clearInputs'}, '*');
            """,
          );
          print('[Flutter->WebView] clearInputs via JS');
        }
      } else {
        print('[62] PostWrite: Post submission failed with status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패: ${response.statusCode}')));
      }
    } catch (e) {
      print('[63] PostWrite: Post submission error: $e');
      if (e is DioException) {
        print('[63]✉️ 요청 페이로드: ${e.requestOptions.data}');
        print('[63]📬 응답코드: ${e.response?.statusCode}');
        print('[63]📭 응답본문: ${e.response?.data}');
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류 발생:1 $e')));
      print('[63]📭 오류 발생eee:$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
      print('[64] PostWrite: Setting _isLoading to false');
    }
  }

  void _showError(String message) {
    print('[65] PostWrite: _showError called with message: $message');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 3), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('[66] PostWrite: build called');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // final userProvider = context.read<UserProvider>();
    print('[67] PostWrite: UserProvider accessed');
    Widget editorView;
    if (kIsWeb) {
      print('[68] PostWrite: Building editorView for web');
      // editorView = const HtmlElementView(viewType: 'quill-editor-iframe');
      editorView = HtmlElementView(key: ValueKey(_iframeViewType), viewType: _iframeViewType);
    } else {
      print('[69] PostWrite: Building editorView for mobile');
      editorView = InAppWebView(
        initialUrlRequest: URLRequest(
          // url: WebUri('asset:///poke/editor/index.html'
          url: WebUri('asset:///poke/editor/index.html?ts=${DateTime.now().millisecondsSinceEpoch}'),
        ),
        initialSettings: InAppWebViewSettings(allowFileAccessFromFileURLs: true, allowUniversalAccessFromFileURLs: true),
        onWebViewCreated: (ctrl) {
          _webViewCtrl = ctrl;
          ctrl.reload();
          print('[70] PostWrite: InAppWebView created');
          ctrl.addJavaScriptHandler(
            handlerName: 'onTextChange',
            callback: (args) {
              print('[74] PostWrite: onTextChange JS handler called with args: $args');
              final payload = args.first as Map;
              _titleFromHtml = payload['title'] as String;
              _contentFromHtml = payload['content'] as String;
              print('[75] PostWrite: onTextChange - title: $_titleFromHtml, content length: ${_contentFromHtml.length}');
              if (mounted) setState(() {});
            },
          );
          ctrl.addJavaScriptHandler(
            handlerName: 'getAccessToken',
            callback: (args) {
              print('[755555] PostWrite:${userProvider.accessToken}');
              return context.read<UserProvider>().accessToken;
            },
          );
        },
        // onLoadStop: (_, __) {
        //   setState(() => _isLoading = false);
        //   print('[78] PostWrite: WebView load stopped, _isLoading set to false');
        // },
      );
    }

    return Scaffold(
      appBar: BaseAppBar(appBar: AppBar(), title: '게시글 작성'),
      drawer: const BaseDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: selectedMenu,
              hint: const Text('메뉴 선택'),
              onChanged: (newValue) {
                setState(() {
                  selectedMenu = newValue;
                  subMenus = getSubMenus(selectedMenu!);
                  selectedSubMenu = null;
                  subMenuId = null;
                  print('[79] PostWrite: Menu changed to $newValue, subMenus updated');
                });
              },
              items:
              menuOptions.map((menu) {
                return DropdownMenuItem(value: menu, child: Text(menu));
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
                  print('[80] PostWrite: SubMenu changed to $newValue, subMenuId: $subMenuId, selectedMenu: $selectedMenu');
                });
              },
              items:
              subMenus.map((board) {
                return DropdownMenuItem(value: board, child: Text(board));
              }).toList(),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Stack(
                children: [
                  editorView,
                  // if (_isLoading) const Center(child: CircularProgressIndicator()
                  // )
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('작성하기'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: () => _handleSubmit(userProvider),
            ),
          ],
        ),
      ),
    );
  }
}

//플러터 quill
// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui_web' as ui;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:universal_html/html.dart' as html;
// import 'package:uuid/uuid.dart';
// import 'package:http_parser/http_parser.dart';
//
// import '../../../provider/user_provider.dart';
// import '../../../util/global_notifier.dart';
// import '../widget/appbar.dart';
// import '../widget/drawer.dart';
// //PostWriteScreen2
// class PostWrite extends StatefulWidget {
//   const PostWrite({super.key, this.passedSubMenuCode});
//
//   final String? passedSubMenuCode;
//
//   @override
//   State<PostWrite> createState() => _PostWriteState();
// }
//
// class _PostWriteState extends State<PostWrite> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;
//
//   InAppWebViewController? _webViewCtrl;
//   bool _isLoading = true;
//   String? selectedMenu;
//   String? selectedSubMenu;
//   String? subMenuId;
//   List<String> menuOptions = [];
//   List<String> subMenus = [];
//   StreamSubscription? _htmlSub;
//   late final String _iframeViewType;
//
//   // HTML에서 실시간 받아오는 제목·본문 Delta JSON
//   String _titleFromHtml = '';
//   String _contentFromHtml = '';
//
//   List<List<String>> subMenus1 = [
//     ["새소식", "nwn", ""],
//     ["뉴스", "news", "1"],
//   ];
//
//   List<List<String>> subMenus2 = [
//     ["공지/제휴", "nwn1", ""],
//     ["공지사항", "notice", "2"],
//   ];
//
//   List<List<String>> subMenus3 = [
//     ["커뮤니티", "comm", ""],
//     ["자유게시판", "free", "4"],
//   ];
//
//   List<List<String>> subMenus4 = [
//     ["정보자료", "comm1", ""],
//     ["기록/일지", "record", "5"],
//   ];
//
//   List<List<List<String>>> subMenusList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     print('[1] PostWrite: initState called');
//     subMenusList = [subMenus1, subMenus2, subMenus3, subMenus4];
//     print('[2] PostWrite: subMenusList initialized with ${subMenusList.length} menus');
//     menuOptions = getMenuOptions();
//     print('[3] PostWrite: menuOptions initialized with ${menuOptions.length} options');
//     _initializeSelectedMenus();
//     print('[4] PostWrite: _initializeSelectedMenus called');
//     // iframe viewType 생성
//     _iframeViewType = 'quill-iframe-${const Uuid().v4()}';
//     print('[6] PostWrite: _iframeViewType');
//
//     if (kIsWeb) {
//       // ① Flutter Web 에서 iframe 등록
//       print('[7] PostWrite: Running in web environment');
//       ui.platformViewRegistry.registerViewFactory(
//         _iframeViewType,
//             (int viewId) {
//           return html.IFrameElement()
//             ..id = _iframeViewType
//             ..src = 'assets/poke/editor/index.html'
//             ..style.border = 'none'
//             ..style.width = '100%'
//             ..style.height = '100%';
//         },
//       );
//
//       // ② HTML → Flutter 메시지 수신
//       _htmlSub = html.window.onMessage.listen((event) async {
//         print('[8] PostWrite: Received message from iframe: ${event.data}');
//         if (event.data is Map) {
//           final data = event.data as Map;
//
//           switch (data['type']) {
//             case 'onTextChange':
//               print('[8-1] PostWrite onTextChange');
//               // 기존 onTextChange 처리
//               final payload = data['payload'] as Map;
//               _titleFromHtml   = payload['title']   as String;
//               _contentFromHtml = payload['content'] as String;
//               print('[onTextChange] title=$_titleFromHtml, contentLen=${_contentFromHtml.length}');
//               if (mounted) setState(() {});
//               break;
//
//             case 'uploadImage':
//               print('[8-2] PostWrite uploadImage');
//               // HTML 쪽에서 보낸 base64, 파일명, mime
//               final String name   = data['name']   as String;
//               final String mime   = data['mime']   as String;
//               final String b64    = data['base64'] as String;
//               final bytes = base64Decode(b64);
//
//               // FormData 구성
//               final form = FormData.fromMap({
//                 'uuid':     name.split('.').first,
//                 'fileName': name,
//                 'images': MultipartFile.fromBytes(
//                   bytes,
//                   filename: name,
//                   contentType: MediaType.parse(mime),
//                 ),
//               });
//
//               print('[8-3] PostWrite form');
//               // 서버 업로드
//               final response = await Dio().post(
//                 'https://api.cosmosx.co.kr/api/images/uploads/data/tmp',
//                 data: form,
//                 options: Options(headers: {
//                   'Authorization': 'Bearer ${userProvider.accessToken}'
//                 }),
//               );
//               // 반환된 URL
//               final url = (response.data['imageUrls'] as List).first as String;
//
//               // ③ 업로드 완료 후 iframe 에 응답
//               final iframe = html.document.getElementById(_iframeViewType);
//               if (iframe is html.IFrameElement) {
//                 iframe.contentWindow?.postMessage(
//                   {'type': 'imageUploaded', 'url': url},
//                   '*',
//                 );
//               }
//               break;
//           }
//         }
//       });
//     }
//   }
//
//
//   @override
//   void dispose() {
//     print('[12] PostWrite: dispose called');
//     if (kIsWeb) {
//       _htmlSub?.cancel();
//       print('[13] PostWrite: _htmlSub cancelled');
//     }
//     super.dispose();
//   }
//
//   void _initializeSelectedMenus() {
//     print('[14] PostWrite: _initializeSelectedMenus called with passedSubMenuCode: ${widget.passedSubMenuCode}');
//     if (widget.passedSubMenuCode != null) {
//       String passedSubMenuCode = widget.passedSubMenuCode!;
//       var higherMenu = getHigherMenuFromSubMenuCode(passedSubMenuCode);
//       print('[15] PostWrite: higherMenu retrieved: $higherMenu');
//       if (higherMenu.isNotEmpty) {
//         setState(() {
//           selectedMenu = higherMenu['menuDisplayName'];
//           subMenus = getSubMenus(selectedMenu!);
//           selectedSubMenu = getSubMenuDisplayName(passedSubMenuCode);
//           subMenuId = getBoardIdFromSubMenuCode(passedSubMenuCode);
//           print('[16] PostWrite: Selected menu: $selectedMenu, subMenu: $selectedSubMenu, subMenuId: $subMenuId');
//         });
//       }
//     } else {
//       setState(() {
//         selectedMenu = null;
//         selectedSubMenu = null;
//         subMenuId = null;
//         subMenus = [];
//         print('[17] PostWrite: Menus reset to null');
//       });
//     }
//   }
//
//   @override
//   void didUpdateWidget(PostWrite oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     print('[18] PostWrite: didUpdateWidget called, old passedSubMenuCode: ${oldWidget.passedSubMenuCode}, new: ${widget.passedSubMenuCode}');
//     if (widget.passedSubMenuCode != oldWidget.passedSubMenuCode) {
//       _initializeSelectedMenus();
//       print('[19] PostWrite: _initializeSelectedMenus called due to passedSubMenuCode change');
//     }
//   }
//
//   List<String> getMenuOptions() {
//     print('[20] PostWrite: getMenuOptions called');
//     List<String> menuOptions = [];
//     for (var subMenus in subMenusList) {
//       String menuDisplayName = subMenus[0][0];
//       menuOptions.add(menuDisplayName);
//     }
//     print('[21] PostWrite: Returning ${menuOptions.length} menu options');
//     return menuOptions;
//   }
//
//   List<String> getSubMenus(String selectedMenu) {
//     print('[22] PostWrite: getSubMenus called with selectedMenu: $selectedMenu');
//     for (var subMenus in subMenusList) {
//       String menuDisplayName = subMenus[0][0];
//       if (menuDisplayName == selectedMenu) {
//         var result = subMenus.skip(1).map((item) => item[0]).toList();
//         print('[23] PostWrite: Returning ${result.length} subMenus for $selectedMenu');
//         return result;
//       }
//     }
//     print('[24] PostWrite: No subMenus found for $selectedMenu');
//     return [];
//   }
//
//   String getSubMenuCode(String subMenuDisplayName) {
//     print('[25] PostWrite: getSubMenuCode called with subMenuDisplayName: $subMenuDisplayName');
//     for (var subMenus in subMenusList) {
//       for (var item in subMenus) {
//         if (item[0] == subMenuDisplayName) {
//           print('[26] PostWrite: Found subMenuCode: ${item[1]}');
//           return item[1];
//         }
//       }
//     }
//     print('[27] PostWrite: No subMenuCode found for $subMenuDisplayName');
//     return '';
//   }
//
//   String getBoardIdFromSubMenuCode(String subMenuCode) {
//     print('[28] PostWrite: getBoardIdFromSubMenuCode called with subMenuCode: $subMenuCode');
//     for (var subMenus in subMenusList) {
//       for (var item in subMenus) {
//         if (item[1] == subMenuCode) {
//           print('[29] PostWrite: Found boardId: ${item[2]}');
//           return item[2];
//         }
//       }
//     }
//     print('[30] PostWrite: No boardId found for $subMenuCode');
//     return '';
//   }
//
//   Map<String, String> getHigherMenuFromSubMenuCode(String subMenuCode) {
//     print('[31] PostWrite: getHigherMenuFromSubMenuCode called with subMenuCode: $subMenuCode');
//     for (var subMenus in subMenusList) {
//       for (var item in subMenus) {
//         if (item[1] == subMenuCode) {
//           var result = {'menuDisplayName': subMenus[0][0], 'menuCode': subMenus[0][1]};
//           print('[32] PostWrite: Found higherMenu: $result');
//           return result;
//         }
//       }
//     }
//     print('[33] PostWrite: No higherMenu found for $subMenuCode');
//     return {};
//   }
//
//   String getSubMenuDisplayName(String subMenuCode) {
//     print('[34] PostWrite: getSubMenuDisplayName called with subMenuCode: $subMenuCode');
//     for (var subMenus in subMenusList) {
//       for (var item in subMenus) {
//         if (item[1] == subMenuCode) {
//           print('[35] PostWrite: Found subMenuDisplayName: ${item[0]}');
//           return item[0];
//         }
//       }
//     }
//     print('[36] PostWrite: No subMenuDisplayName found for $subMenuCode');
//     return '';
//   }
//
//   String getRedirectPath() {
//     print('[37] PostWrite: getRedirectPath called with subMenuId: $subMenuId');
//     if (subMenuId == null) {
//       print('[38] PostWrite: subMenuId is null, returning /');
//       return '/';
//     }
//     for (var subMenus in subMenusList) {
//       for (var item in subMenus) {
//         if (item[2] == subMenuId) {
//           print('[39] PostWrite: Found redirect path: ${item[1]}');
//           return '${item[1]}';
//         }
//       }
//     }
//     print('[40] PostWrite: No redirect path found, returning /');
//     return '/';
//   }
//
//   String generatePath(String subMenuCode) {
//     print('[41] PostWrite: generatePath called with subMenuCode: $subMenuCode');
//     Map<String, String> higherMenu = getHigherMenuFromSubMenuCode(subMenuCode);
//     if (higherMenu.isNotEmpty) {
//       String menuCode = higherMenu['menuCode'] ?? '';
//       var path = '/$menuCode/$subMenuCode/';
//       print('[42] PostWrite: Generated path: $path');
//       return path;
//     }
//     print('[43] PostWrite: No higherMenu found, returning /');
//     return '/';
//   }
//
//   Future<String> _prepareContentAndUploadImages(String deltaJson) async {
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     final List<dynamic> ops = jsonDecode(deltaJson);
//     print('[43-1] _prepareContentAndUploadImages 진입, ops: $ops');
//
//     for (var op in ops) {
//       // 1) insert 가 Map 이고, 그 안에 image 필드가 있는 경우만 처리
//       if (op is Map && op['insert'] is Map && op['insert']['image'] != null) {
//         // 편하게 다룰 수 있도록 복사
//         final insert = Map<String, dynamic>.from(op['insert'] as Map);
//         String? src;      // 실제 이미지 src (base64 혹은 URL)
//         String? wPx;      // px 단위로 붙어온 width
//         String? hPx;      // px 단위로 붙어온 height
//
//         // 2) insert['image'] 가 Map 인 경우 (url, width, height 가 담겨있을 때)
//         if (insert['image'] is Map) {
//           final imgMap = Map<String, dynamic>.from(insert['image'] as Map);
//           src = imgMap['url'] as String?;
//           wPx = imgMap['width']  as String?;
//           hPx = imgMap['height'] as String?;
//         }
//         // 3) insert['image'] 가 String 인 경우 (직접 base64 가 넘어올 때)
//         else if (insert['image'] is String) {
//           src = insert['image'] as String;
//         }
//
//         // 4) base64 이면 업로드
//         String? uploadedUrl;
//         if (src != null && src.startsWith('data:')) {
//           print('[43-2] base64 발견, 업로드 시작');
//           final parts = src.split(',');
//           final meta = parts.first;      // data:image/png;base64
//           final b64  = parts.last;       // 실제 base64
//           final mime= meta.substring(5, meta.indexOf(';')); // image/png
//
//           final bytes = base64Decode(b64);
//           final uuid  = const Uuid().v4();
//           final ext   = mime.split('/').last;
//           final fileName = '$uuid.$ext';
//
//           // FormData 준비
//           final form = FormData.fromMap({
//             'uuid': uuid,
//             'fileName': fileName,
//             'images': MultipartFile.fromBytes(
//               bytes,
//               filename: fileName,
//               contentType: MediaType.parse(mime),
//             ),
//           });
//           print('[43-3] FormData: $form');
//
//           // 서버 업로드
//           final resp = await Dio().post(
//             'https://api.cosmosx.co.kr/api/images/uploads/data/tmp',
//             data: form,
//             options: Options(headers: {
//               'Authorization': 'Bearer ${userProvider.accessToken}'
//             }),
//           );
//           final urls = resp.data['imageUrls'] as List<dynamic>;
//           if (urls.isNotEmpty) {
//             uploadedUrl = urls.first as String;
//             print('[43-4] 업로드 완료 URL: $uploadedUrl');
//           }
//         }
//
//         // 5) 업로드된 URL 이 있으면 op 구조 갱신
//         if (uploadedUrl != null) {
//           final bool hasW = wPx != null && wPx.isNotEmpty;
//           final bool hasH = hPx != null && hPx.isNotEmpty;
//
//           if (hasW || hasH) {
//             // px 제거하고 숫자만
//             final rawW = hasW ? wPx!.replaceAll('px', '') : '';
//             final rawH = hasH ? hPx!.replaceAll('px', '') : '';
//             // insert/attributes 모두 재구성
//             op
//               ..remove('insert')
//               ..remove('attributes');
//             op['insert'] = {'image': uploadedUrl};
//             op['attributes'] = {
//               'style': 'width: ${rawW}px; height: ${rawH}px;'
//             };
//           } else {
//             // width/height 없으면 URL 만 교체
//             op['insert']['image'] = uploadedUrl;
//             op.remove('attributes');
//           }
//         }
//       }
//     }
//
//     final result = jsonEncode(ops);
//     print('[43-5] 변환 후 ops JSON: $result');
//     return result;
//   }
//
//
//   Future<void> _handleSubmit(UserProvider userProvider) async {
//     print('[51] PostWrite: _handleSubmit called');
//     String? accessToken = userProvider.accessToken;
//     int id = userProvider.id;
//     String? board = subMenuId;
//     final title = _titleFromHtml.trim();
//     final content = _contentFromHtml.trim();
//     print('[52] PostWrite: Submit data - userId: $id, board: $board, title: $title, content length: ${content.length}');
//
//     if (title.isEmpty) {
//       print('[53] PostWrite: Title is empty');
//       _showError('제목을 입력해주세요.');
//       return;
//     }
//     if (content.isEmpty) {
//       print('[54] PostWrite: Content is empty');
//       _showError('본문을 입력해주세요.');
//       return;
//     }
//
//     if (selectedMenu == null || selectedSubMenu == null || subMenuId == null) {
//       print('[55] PostWrite: Menu or subMenu not selected');
//       _showError('메뉴와 게시판을 선택해주세요.');
//       return;
//     }
//
//     if (accessToken == null) {
//       print('[56] PostWrite: Access token is null');
//       _showError('액세스 토큰이 없습니다. 로그인이 필요합니다.');
//       return;
//     }
//
//     // 1) base64 포함된 _contentFromHtml → 이미지 업로드 & URL 교체
//     final processedContent = await _prepareContentAndUploadImages(_contentFromHtml);
//     // final rawOps = jsonDecode(_contentFromHtml) as List<dynamic>;
//     //
//     // // 2) Map each op to the desired format
//     // final transformedOps = rawOps.map((op) {
//     //   // op is a Map<String, dynamic>
//     //   if (op is Map && op['insert'] is Map) {
//     //     final insert = op['insert'] as Map;
//     //     final imageField = insert['image'];
//     //     // 이미지가 {url, width, height} 형태로 들어온 경우
//     //     if (imageField is Map && imageField['url'] != null) {
//     //       final url    = imageField['url']    as String;
//     //       final width  = imageField['width']  as String? ?? '';
//     //       final height = imageField['height'] as String? ?? '';
//     //       return {
//     //         'insert': {
//     //           'image': url,
//     //         },
//     //         'attributes': {
//     //           'style': 'width: $width; height: $height;'
//     //         }
//     //       };
//     //     }
//     //   }
//     //   // 나머지 op는 그대로 반환
//     //   return op;
//     // }).toList();
//     //
//     // // 3) 재직렬화
//     // final contentForServer = jsonEncode(transformedOps);
//
//     // setState(() => _isLoading = true);
//     print('[57] PostWrite: Setting _isLoading to true');
//     const String url = "https://api.cosmosx.co.kr/";
//     print('[577] PostWrite: Setting _isLoading to true');
//     try {
//       print('[5777] PostWrite: Setting _isLoading to true');
//       final response = await Dio().post(
//         url,
//         options: Options(headers: {'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'Bearer $accessToken'}),
//         data: jsonEncode(<String, dynamic>{
//           'user_id': id,
//           'board_id': board ?? '',
//           'title': title,
//           // 'content': content
//           'content': processedContent
//         }),
//       );
//       print('[58] PostWrite: Post submission response status: ${response.statusCode}');
//
//       if (response.statusCode! >= 200 && response.statusCode! < 300) {
//         print('[59] PostWrite: Post submitted successfully');
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('글이 성공적으로 등록되었습니다.')));
//
//         String subMenuCode = getRedirectPath();
//         String path = generatePath(subMenuCode);
//         context.push('$path', extra: UniqueKey());
//         refreshNotifier.value++;
//         print('[60] PostWrite: 라우팅');
//         // Flutter 상태도 비우기
//         _titleFromHtml = '';
//         _contentFromHtml = '';
//
//         if (kIsWeb) {
//           print('[61] PostWrite: 인터넷일때 ');
//
//           print('[611] PostWrite: 초기화 ');
//
//           final iframe = html.document.getElementById(_iframeViewType);
//           if (iframe is html.IFrameElement) {
//             // HTML에서 위에 등록한 message 이벤트로 전달
//             iframe.contentWindow?.postMessage({'type': 'clearInputs'}, '*');
//           }
//
//           // 메시지 전송
//
//           // html.window.postMessage({'type': 'clearInputs'}, '*');
//           print('[61111] PostWrite: 클리러 날리기 ');
//           print('[Flutter->Html] clearInputs via window.postMessage');
//         } else {
//           print('[611111] PostWrite: else ');
//           // 모바일 WebView 쪽 초기화
//           _titleFromHtml = '';
//           _contentFromHtml = '';
//           _webViewCtrl?.evaluateJavascript(
//             source: """
//             window.postMessage({type:'clearInputs'}, '*');
//             """,
//           );
//           print('[Flutter->WebView] clearInputs via JS');
//         }
//       } else {
//         print('[62] PostWrite: Post submission failed with status: ${response.statusCode}');
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패: ${response.statusCode}')));
//       }
//     } catch (e) {
//       print('[63] PostWrite: Post submission error: $e');
//       if (e is DioException) {
//         print('[63]✉️ 요청 페이로드: ${e.requestOptions.data}');
//         print('[63]📬 응답코드: ${e.response?.statusCode}');
//         print('[63]📭 응답본문: ${e.response?.data}');
//       }
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류 발생:1 $e')));
//       print('[63]📭 오류 발생eee:$e');
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//       print('[64] PostWrite: Setting _isLoading to false');
//     }
//   }
//
//   void _showError(String message) {
//     print('[65] PostWrite: _showError called with message: $message');
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 3), backgroundColor: Colors.red));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     print('[66] PostWrite: build called');
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     // final userProvider = context.read<UserProvider>();
//     print('[67] PostWrite: UserProvider accessed');
//     Widget editorView;
//     if (kIsWeb) {
//       print('[68] PostWrite: Building editorView for web');
//       // editorView = const HtmlElementView(viewType: 'quill-editor-iframe');
//       editorView = HtmlElementView(key: ValueKey(_iframeViewType), viewType: _iframeViewType);
//     } else {
//       print('[69] PostWrite: Building editorView for mobile');
//       editorView = InAppWebView(
//         initialUrlRequest: URLRequest(
//           // url: WebUri('asset:///poke/editor/index.html'
//           url: WebUri('asset:///poke/editor/index.html?ts=${DateTime.now().millisecondsSinceEpoch}'),
//         ),
//         initialSettings: InAppWebViewSettings(allowFileAccessFromFileURLs: true, allowUniversalAccessFromFileURLs: true),
//         onWebViewCreated: (ctrl) {
//           _webViewCtrl = ctrl;
//           ctrl.reload();
//           print('[70] PostWrite: InAppWebView created');
//           ctrl.addJavaScriptHandler(
//             handlerName: 'onTextChange',
//             callback: (args) {
//               print('[74] PostWrite: onTextChange JS handler called with args: $args');
//               final payload = args.first as Map;
//               _titleFromHtml = payload['title'] as String;
//               _contentFromHtml = payload['content'] as String;
//               print('[75] PostWrite: onTextChange - title: $_titleFromHtml, content length: ${_contentFromHtml.length}');
//               if (mounted) setState(() {});
//             },
//           );
//           ctrl.addJavaScriptHandler(
//             handlerName: 'getAccessToken',
//             callback: (args) {
//               print('[755555] PostWrite:${userProvider.accessToken}');
//               return context.read<UserProvider>().accessToken;
//             },
//           );
//         },
//         // onLoadStop: (_, __) {
//         //   setState(() => _isLoading = false);
//         //   print('[78] PostWrite: WebView load stopped, _isLoading set to false');
//         // },
//       );
//     }
//
//     return Scaffold(
//       appBar: BaseAppBar(appBar: AppBar(), title: '게시글 작성'),
//       drawer: const BaseDrawer(),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             DropdownButtonFormField<String>(
//               value: selectedMenu,
//               hint: const Text('메뉴 선택'),
//               onChanged: (newValue) {
//                 setState(() {
//                   selectedMenu = newValue;
//                   subMenus = getSubMenus(selectedMenu!);
//                   selectedSubMenu = null;
//                   subMenuId = null;
//                   print('[79] PostWrite: Menu changed to $newValue, subMenus updated');
//                 });
//               },
//               items:
//               menuOptions.map((menu) {
//                 return DropdownMenuItem(value: menu, child: Text(menu));
//               }).toList(),
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: selectedSubMenu,
//               hint: const Text('게시판 선택'),
//               onChanged: (newValue) {
//                 setState(() {
//                   selectedSubMenu = newValue;
//                   String subMenuCode = getSubMenuCode(selectedSubMenu ?? '');
//                   subMenuId = getBoardIdFromSubMenuCode(subMenuCode);
//                   var higherMenu = getHigherMenuFromSubMenuCode(subMenuCode);
//                   if (higherMenu.isNotEmpty) {
//                     selectedMenu = higherMenu['menuDisplayName'];
//                     subMenus = getSubMenus(selectedMenu!);
//                   }
//                   print('[80] PostWrite: SubMenu changed to $newValue, subMenuId: $subMenuId, selectedMenu: $selectedMenu');
//                 });
//               },
//               items:
//               subMenus.map((board) {
//                 return DropdownMenuItem(value: board, child: Text(board));
//               }).toList(),
//             ),
//             const SizedBox(height: 16),
//
//             Expanded(
//               child: Stack(
//                 children: [
//                   editorView,
//                   // if (_isLoading) const Center(child: CircularProgressIndicator()
//                   // )
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.send),
//               label: const Text('작성하기'),
//               style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
//               onPressed: () => _handleSubmit(userProvider),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// 1차
// import 'dart:ui_web' as ui;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:universal_html/html.dart' as html;
// import '../widget/appbar.dart';
// import '../widget/drawer.dart';
//
// class PostWrite extends StatefulWidget {
//   const PostWrite({super.key, this.passedSubMenuCode});
//
//   final String? passedSubMenuCode;
//
//   @override
//   _PostWriteState createState() => _PostWriteState();
// }
//
// class _PostWriteState extends State<PostWrite> {
//   InAppWebViewController? _webViewCtrl;
//
//   @override
//   void initState() {
//     super.initState();
//     if (kIsWeb) {
//       String passedSubMenuCode = widget.passedSubMenuCode!;
//       print('✍️ passedSubMenuCode $passedSubMenuCode');
//       // 웹·데스크탑: iframe 뷰 등록
//       ui.platformViewRegistry.registerViewFactory('quill-editor-iframe', (int viewId) {
//         final iframe =
//             html.IFrameElement()
//               ..src = 'assets/editor/index.html'
//               ..style.border = 'none'
//               ..style.width = '100%'
//               ..style.height = '100%';
//         // 부모 창 메시지 수신
//         html.window.onMessage.listen((event) {
//           if (event.data is Map && event.data['type'] == 'onTextChange') {
//             print('Web: content changed');
//           }
//         });
//         return iframe;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: BaseAppBar(appBar: AppBar(), title: '게시글 작성'),
//       drawer: const BaseDrawer(),
//       body:
//           kIsWeb
//               // 웹/데스크탑: iframe
//               ? const SizedBox.expand(child: HtmlElementView(viewType: 'quill-editor-iframe'))
//               // 모바일(iOS/Android): InAppWebView
//               : InAppWebView(
//                 initialUrlRequest: URLRequest(url: WebUri('asset:///assets/editor/index.html')),
//                 // 파일 접근 허용 옵션도 settings에 필요하다면 추가
//                 onWebViewCreated: (controller) {
//                   _webViewCtrl = controller;
//                   controller.addJavaScriptHandler(
//                     handlerName: 'onTextChange',
//                     callback: (args) {
//                       final htmlContent = args.first as String;
//                       debugPrint('Mobile: content length=${htmlContent.length}');
//                     },
//                   );
//                 },
//               ),
//     );
//   }
// }
