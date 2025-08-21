// 조건부 import로 dart:ui_web 제거
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:universal_html/html.dart' as html;

import '../widget/appbar.dart';
import '../widget/drawer.dart';

// 플랫폼에 따라 viewFactory 등록 분기
import 'platform_view_stub3.dart'
if (dart.library.ui_web) 'platform_view_web3.dart';

class PostWriteScreen3 extends StatefulWidget {
  const PostWriteScreen3({super.key, this.passedSubMenuCode});

  final String? passedSubMenuCode;

  @override
  _PostWriteScreen3State createState() => _PostWriteScreen3State();
}

class _PostWriteScreen3State extends State<PostWriteScreen3> {
  InAppWebViewController? _webViewCtrl;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      registerTiptapIframeViewFactory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(appBar: AppBar(), title: '게시글 작성'),
      drawer: const BaseDrawer(),
      body: kIsWeb
          ? const SizedBox.expand(
        child: HtmlElementView(viewType: 'tiptap-editor-iframe'),
      )
          : InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri('asset:///assets/editor/server.html'),
        ),
        initialSettings: InAppWebViewSettings(
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true,
        ),
        onWebViewCreated: (controller) {
          _webViewCtrl = controller;
          controller.addJavaScriptHandler(
            handlerName: 'onContentChange',
            callback: (args) {
              final htmlContent = args.first as String;
              debugPrint('Mobile: content length=\${htmlContent.length}');
            },
          );
        },
      ),
    );
  }
}


// // lib/view/screen/post_write_screen2.dart
//
// // 웹 전용 platformViewRegistry를 사용하기 위한 import
// // ignore: undefined_prefixed_name
//
//
// import 'dart:ui_web' as ui show platformViewRegistry;
//
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:universal_html/html.dart' as html;
//
// import '../widget/appbar.dart';
// import '../widget/drawer.dart';
//
// class PostWriteScreen3 extends StatefulWidget {
//   const PostWriteScreen3({super.key, this.passedSubMenuCode});
//
//   final String? passedSubMenuCode;
//
//   @override
//   _PostWriteScreen3State createState() => _PostWriteScreen3State();
// }
//
// class _PostWriteScreen3State extends State<PostWriteScreen3> {
//   InAppWebViewController? _webViewCtrl;
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (kIsWeb) {
//       // 웹/데스크탑: TipTap HTML 을 띄울 iframe 뷰 등록
//       ui.platformViewRegistry.registerViewFactory(
//         'tiptap-editor-iframe',
//             (int viewId) {
//           final iframe = html.IFrameElement()
//             ..src = '/assets/editor/server.html'  // 빌드 결과물 경로
//             ..style.border = 'none'
//             ..style.width = '100%'
//             ..style.height = '100%';
//
//           // JS → Flutter 메시지 수신
//           html.window.onMessage.listen((event) {
//             if (event.data is Map && event.data['type'] == 'onContentChange') {
//               debugPrint('Web: content updated length=${(event.data['html'] as String).length}');
//             }
//           });
//
//           return iframe;
//         },
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: BaseAppBar(appBar: AppBar(), title: '게시글 작성'),
//       drawer: const BaseDrawer(),
//       body: kIsWeb
//       // 웹/데스크탑: iframe 으로 로드
//           ? const SizedBox.expand(
//         child: HtmlElementView(viewType: 'tiptap-editor-iframe'),
//       )
//       // 모바일(iOS/Android): InAppWebView 로 로드
//           : InAppWebView(
//         initialUrlRequest: URLRequest(
//           url: WebUri('asset:///assets/editor/server.html'),
//         ),
//         initialSettings: InAppWebViewSettings(
//           allowFileAccessFromFileURLs: true,
//           allowUniversalAccessFromFileURLs: true,
//         ),
//         onWebViewCreated: (controller) {
//           _webViewCtrl = controller;
//           controller.addJavaScriptHandler(
//             handlerName: 'onContentChange',
//             callback: (args) {
//               final htmlContent = args.first as String;
//               debugPrint('Mobile: content length=${htmlContent.length}');
//             },
//           );
//         },
//       ),
//     );
//   }
// }
