import 'dart:ui_web' as ui;
import 'package:universal_html/html.dart' as html;

void registerTiptapIframeViewFactory() {
  ui.platformViewRegistry.registerViewFactory(
    'tiptap-editor-iframe',
        (int viewId) {
      final iframe = html.IFrameElement()
        ..src = '/assets/editor/server.html'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';

      html.window.onMessage.listen((event) {
        if (event.data is Map && event.data['type'] == 'onContentChange') {
          print('Web: content updated length=${(event.data['html'] as String).length}');
        }
      });

      return iframe;
    },
  );
}
