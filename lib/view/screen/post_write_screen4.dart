// 조건부 import로 dart:ui_web 제거
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:universal_html/html.dart' as html;

import '../widget/appbar.dart';
import '../widget/drawer.dart';

// 플랫폼에 따라 viewFactory 등록 분기
import 'platform_view_stub4.dart'
if (dart.library.ui_web) 'platform_view_web4.dart';

class PostWriteScreen4 extends StatefulWidget {
  const PostWriteScreen4({super.key, this.passedSubMenuCode});

  final String? passedSubMenuCode;

  @override
  _PostWriteScreen4State createState() => _PostWriteScreen4State();
}

class _PostWriteScreen4State extends State<PostWriteScreen4> {
  InAppWebViewController? _webViewCtrl;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      registerCkeditorIframeViewFactory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(appBar: AppBar(), title: '게시글 작성'),
      drawer: const BaseDrawer(),
      body: kIsWeb
          ? const SizedBox.expand(
        child: HtmlElementView(viewType: 'ckeditor-editor-iframe'),
      )
          : InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri('asset:///assets/editor/CKeditor.html'),
        ),
        initialSettings: InAppWebViewSettings(
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true,
        ),
        onWebViewCreated: (controller) {
          _webViewCtrl = controller;
          controller.addJavaScriptHandler(
            handlerName: 'onDataChange',
            callback: (args) {
              final html = args.first as String;
              debugPrint('Mobile content length=\${html.length}');
            },
          );
        },
      ),
    );
  }
}


// // ignore: undefined_prefixed_name
//
// import 'dart:ui_web' as ui show platformViewRegistry;
//
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:universal_html/html.dart' as html;
//
//
// import '../widget/appbar.dart';
// import '../widget/drawer.dart';
//
// class PostWriteScreen4 extends StatefulWidget {
//   const PostWriteScreen4({super.key, this.passedSubMenuCode});
//
//   final String? passedSubMenuCode;
//
//   @override
//   _PostWriteScreen4State createState() => _PostWriteScreen4State();
// }
//
// class _PostWriteScreen4State extends State<PostWriteScreen4> {
//   InAppWebViewController? _webViewCtrl;
//
//   @override
//   void initState() {
//     super.initState();
//     if (kIsWeb) {
//       ui.platformViewRegistry.registerViewFactory(
//         'ckeditor-editor-iframe',
//             (int viewId) {
//           final iframe = html.IFrameElement()
//             ..src = '/assets/editor/CKeditor.html'
//             ..style.border = 'none'
//             ..style.width = '100%'
//             ..style.height = '100%';
//           html.window.onMessage.listen((event) {
//             if (event.data is Map && event.data['type'] == 'onDataChange') {
//               debugPrint('Web content length=${(event.data['data'] as String).length}');
//             }
//           });
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
//           ? const SizedBox.expand(
//         child: HtmlElementView(viewType: 'ckeditor-editor-iframe'),
//       )
//           : InAppWebView(
//         initialUrlRequest: URLRequest(
//           url: WebUri('asset:///assets/editor/CKeditor.html'),
//         ),
//         initialSettings: InAppWebViewSettings(
//           allowFileAccessFromFileURLs: true,
//           allowUniversalAccessFromFileURLs: true,
//         ),
//         onWebViewCreated: (controller) {
//           _webViewCtrl = controller;
//           controller.addJavaScriptHandler(
//             handlerName: 'onDataChange',
//             callback: (args) {
//               final html = args.first as String;
//               debugPrint('Mobile content length=${html.length}');
//             },
//           );
//         },
//       ),
//     );
//   }
// }