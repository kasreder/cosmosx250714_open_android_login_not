import 'dart:ui_web' as ui;
import 'package:universal_html/html.dart' as html;

void registerQuillIframeViewFactory(String viewType) {
  ui.platformViewRegistry.registerViewFactory(
    viewType,
        (int viewId) => html.IFrameElement()
      ..id = viewType
      ..src = 'assets/poke/editor/index.html'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%',
  );
}
