import 'dart:ui_web' as ui;
import 'package:universal_html/html.dart' as html;

void registerCkeditorIframeViewFactory() {
  ui.platformViewRegistry.registerViewFactory(
    'ckeditor-editor-iframe',
        (int viewId) {
      final iframe = html.IFrameElement()
        ..src = '/assets/editor/CKeditor.html'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      html.window.onMessage.listen((event) {
        if (event.data is Map && event.data['type'] == 'onDataChange') {
          print('Web content length=${(event.data['data'] as String).length}');
        }
      });
      return iframe;
    },
  );
}
