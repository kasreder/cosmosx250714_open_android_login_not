// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:unicons/unicons.dart';
//
// // Stateful navigation based on:
// // https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
// class ScaffoldWithNestedNavigation extends StatelessWidget {
//   const ScaffoldWithNestedNavigation({
//     Key? key,
//     required this.navigationShell,
//   }) : super(
//       key: key ?? const ValueKey<String>('ScaffoldWithNestedNavigation'));
//   final StatefulNavigationShell navigationShell;
//
//   void _goBranch(int index) {
//     navigationShell.goBranch(
//       index,
//       // A common pattern when using bottom navigation bars is to support
//       // navigating to the initial location when tapping the item that is
//       // already active. This example demonstrates how to support this behavior,
//       // using the initialLocation parameter of goBranch.
//       initialLocation: index == navigationShell.currentIndex,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       ///크기 450 이하일때 하단 네비게이션 적용
//       if (constraints.maxWidth < 450) {
//         return ScaffoldWithNavigationBar(
//           body: navigationShell,
//           selectedIndex: navigationShell.currentIndex,
//           onDestinationSelected: _goBranch,
//         );
//       } else {
//         ///크기 450 초과 좌측세로 네비게이션 적용
//         return ScaffoldWithNavigationRail(
//           body: navigationShell,
//           selectedIndex: navigationShell.currentIndex,
//           onDestinationSelected: _goBranch,
//         );
//       }
//     });
//   }
// }
//
//
// ///하단일때 메뉴바
// class ScaffoldWithNavigationBar extends StatelessWidget {
//   const ScaffoldWithNavigationBar({
//     super.key,
//     required this.body,
//     required this.selectedIndex,
//     required this.onDestinationSelected,
//   });
//   final Widget body;
//   final int selectedIndex;
//   final ValueChanged<int> onDestinationSelected;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: body,
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: selectedIndex,
//         destinations: const [
//           NavigationDestination(label: 'Home', icon: Icon(Icons.home)),
//           NavigationDestination(label: 'News', icon: Icon(Icons.newspaper),),
//           NavigationDestination(label: '커뮤니티', icon: Icon(Icons.dashboard)),
//           NavigationDestination(label: '설정', icon: Icon(Icons.settings)),
//           NavigationDestination(label: '아바타', icon: Icon(Icons.person)),
//         ],
//         onDestinationSelected: onDestinationSelected,
//       ),
//       // floatingActionButton: const NaviFloatingAction()
//     );
//   }
// }
//
// /// 세로메뉴바
// class ScaffoldWithNavigationRail extends StatelessWidget {
//   const ScaffoldWithNavigationRail({
//     super.key,
//     required this.body,
//     required this.selectedIndex,
//     required this.onDestinationSelected,
//   });
//   final Widget body;
//   final int selectedIndex;
//   final ValueChanged<int> onDestinationSelected;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           NavigationRail(
//             selectedIndex: selectedIndex,
//             ///링크
//             onDestinationSelected: onDestinationSelected,
//             ///아이콘 라벨이름
//             ///.none 라벨 전부다 보임
//             ///.selected 라벨 선택되니 아이콘만 보임
//             labelType: NavigationRailLabelType.none,
//             destinations: const <NavigationRailDestination>[
//               NavigationRailDestination(
//                 label: Text('Home'),
//                 icon: Icon(UniconsLine.home),
//               ),
//               NavigationRailDestination(
//                 label: Text('News'),
//                 icon: Icon(UniconsLine.swatchbook),
//               ),
//               NavigationRailDestination(
//                 label: Text('커뮤니티'),
//                 icon: Icon(UniconsLine.flask),
//               ),
//               NavigationRailDestination(
//                 label: Text('세팅'),
//                 icon: Icon(UniconsLine.setting),
//               ),
//               NavigationRailDestination(
//                 label: Text('세팅'),
//                 icon: Icon(UniconsLine.user_circle),
//               ),
//             ],
//           ),
//           ///메뉴바 본문사이 구분줄
//           const VerticalDivider(thickness: 1, width: 1),
//           /// This is the main content. 페이지 내용
//           Expanded(
//             child: body,
//           ),
//         ],
//       ),
//       // floatingActionButton: const NaviFloatingAction()
//     );
//   }
// }
//
