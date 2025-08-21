import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import '../../provider/list_provider.dart';

// Stateful navigation based on:
// https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({
    Key? key,
    required this.navigationShell,
  }) : super(
      key: key ?? const ValueKey<String>('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index, BuildContext context) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
    // 🚀 네비게이션 이동 시 조회수 업데이트 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final boardProvider = Provider.of<ViewCountProvider>(context, listen: false);

      switch (index) {
        case 0:
          // boardProvider.fetchBoardData('news'); // 🔹 뉴스 데이터 가져오기
          break;
        case 1:
          boardProvider.fetchPostDataFromAPI('news'); // 🔹 뉴스 데이터 가져오기
          break;
        case 2:
          boardProvider.fetchPostDataFromAPI('free'); // 🔹 자유게시판 데이터 가져오기
          break;
        case 3:
          boardProvider.fetchPostDataFromAPI('record'); // 🔹 자유게시판 데이터 가져오기
          break;
        case 4:
          boardProvider.fetchPostDataFromAPI('notice'); // 🔹 자유게시판 데이터 가져오기
          break;
        case 5:
          // boardProvider.fetchPostDataFromAPI('free'); // 🔹 자유게시판 데이터 가져오기
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 450) {
        return ScaffoldWithNavigationBar(
          body: navigationShell,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => _goBranch(index, context),
        );
      } else {
        return FutureBuilder(
          future: Future.delayed(Duration(milliseconds: 100)), // ✅ go_router가 완전히 로드될 때까지 대기
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()), // ✅ 로딩 화면 표시
              );
            }
            return ScaffoldWithNavigationRail(
              body: navigationShell,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => _goBranch(index, context),
            );
          },
        );
      }
    });
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       ///크기 450 이하일때 하단 네비게이션 적용
//       if (constraints.maxWidth < 450) {
//         return ScaffoldWithNavigationBar(
//           body: navigationShell,
//           selectedIndex: navigationShell.currentIndex,
//           onDestinationSelected: (index) => _goBranch(index, context),
//           // onDestinationSelected: _goBranch,
//         );
//       } else {
//         ///크기 450 초과 좌측세로 네비게이션 적용
//         return ScaffoldWithNavigationRail(
//           body: navigationShell,
//           selectedIndex: navigationShell.currentIndex,
//           onDestinationSelected: (index) => _goBranch(index, context),
//           // onDestinationSelected: _goBranch,
//         );
//       }
//     });
//   }
// }


///하단 네비게이션 바 적용
class ScaffoldWithNavigationBar extends StatelessWidget {
  const ScaffoldWithNavigationBar({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        height: 40,
        selectedIndex: selectedIndex,
        destinations: const [
          NavigationDestination(label: '홈', icon: Icon(UniconsLine.home)),
          NavigationDestination(label: '뉴스', icon: Icon(UniconsLine.megaphone),),
          NavigationDestination(label: '자유게시판', icon: Icon(UniconsLine.comment_alt_dots),),
          NavigationDestination(label: '기록/실험', icon: Icon(UniconsLine.flask)),
          NavigationDestination(label: '공지/제휴', icon: Icon(UniconsLine.newspaper)),
          NavigationDestination(label: '설정', icon: Icon(UniconsLine.user_circle)),
          //Icon(Icons.person)
        ],
        onDestinationSelected: onDestinationSelected,
        // 스타일로 텍스트 숨기기
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // 텍스트 숨김
      ),
      // floatingActionButton: const NaviFloatingAction()
    );
  }
}

/// 세로 네비게이션 바 적용
class ScaffoldWithNavigationRail extends StatelessWidget {
  const ScaffoldWithNavigationRail({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            ///링크
            onDestinationSelected: onDestinationSelected,
            ///아이콘 라벨이름
            ///.none 라벨 전부다 보임
            ///.selected 라벨 선택되니 아이콘만 보임
            labelType: NavigationRailLabelType.none,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                label: Text('Home'),
                icon: Icon(UniconsLine.home),
              ),
              NavigationRailDestination(
                label: Text('News'),
                icon: Icon(UniconsLine.megaphone),
              ),
              NavigationRailDestination(
                label: Text('Free'),
                icon: Icon(UniconsLine.comment_alt_dots),
              ),
              NavigationRailDestination(
                label: Text('Record'),
                icon: Icon(UniconsLine.flask),
              ),// setting
              NavigationRailDestination(
                label: Text('Notice'),
                icon: Icon(UniconsLine.newspaper),
              ),
              NavigationRailDestination(
                label: Text('Info'),
                icon: Icon(UniconsLine.user_circle),
              ),
            ],
          ),
          ///메뉴바 본문사이 구분줄
          const VerticalDivider(thickness: 1, width: 1),
          /// This is the main content. 페이지 내용
          Expanded(child: body),
        ],
      ),
      // floatingActionButton: const NaviFloatingAction()
    );
  }
}

