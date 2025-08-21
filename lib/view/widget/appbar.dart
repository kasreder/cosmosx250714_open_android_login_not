import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'loginout_widget.dart';

// 웹에서만 사용할 수 있는 라이브러리 (웹 플랫폼에서만 import 해야 함)
import 'package:universal_html/html.dart' as html;

/// 기본 앱바
class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BaseAppBar({
    super.key,
    required this.appBar,
    required this.title,
    this.center = false,
    // required double preferredHeight,
  });

  final AppBar appBar;
  final String title;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: const <Widget>[
        LoginoutWidget(),
      ],
      centerTitle: center,
      title: GestureDetector(
        onTap: () {
          if (kIsWeb) {
            // 웹 플랫폼인 경우 페이지 새로고침
            html.window.location.reload();
          } else {
            // 홈으로 이동 및 새로고침
            // context.go('/') -> GoRouter 사용 시
            // Navigator.pushReplacementNamed(context, '/'); -> Navigator 사용 시
            context.go('/'); // GoRouter를 사용하여 홈 경로로 이동
          }
        },
        child: Text(
          title,
          style: const TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: const Color(0xffce93d8),
    );
  }

  @override
  // Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
  Size get preferredSize => const Size.fromHeight(40.0); // 고정 높이 100.0 설정
}
