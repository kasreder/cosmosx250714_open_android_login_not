// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
// import '../view/screen/board/nwn/news/nwn_news_list_screen.dart';
// import '../view/screen/board/nwn/news/nwn_news_details_screen.dart';
// import '../view/screen/board/nwn/notice/nwn_notice_list_screen.dart';
// import '../view/screen/board/nwn/notice/nwn_notice_details_screen.dart';
// import '../util/pageindex.dart'; // fetchDataFromServer 관련 함수 사용
//
// /// ✅ **뉴스 & 공지사항 브랜치**
// StatefulShellBranch buildNwnBranch() {
//   return StatefulShellBranch(
//     navigatorKey: GlobalKey<NavigatorState>(debugLabel: '새소식'),
//     routes: [
//       GoRoute(
//         path: '/nwn',
//         redirect: (context, state) => state.location == '/nwn' ? '/nwn/news/' : null,
//         pageBuilder: (context, state) {
//           print('nwn_routes.dart: /nwn 접근');
//           return const NoTransitionPage(
//             child: NewsListScreen(label: 'nwn', detailPath: '/nwn/news/'),
//           );
//         },
//         routes: [
//           _buildBoardRoute(
//             board: 'news',
//             label: '뉴스',
//             listScreen: const NewsListScreen(label: '뉴스', detailPath: '/nwn/news/'),
//             detailsScreen: (label, itemIndex, extraData) => NewsDetailsScreen(
//               label: label, itemIndex: itemIndex, extraData: extraData,
//             ),
//           ),
//           _buildBoardRoute(
//             board: 'notice',
//             label: '공지사항',
//             listScreen: const NoticeListScreen(label: '공지사항', detailPath: '/nwn/notice/'),
//             detailsScreen: (label, itemIndex, extraData) => NoticeDetailsScreen(
//               label: label, itemIndex: itemIndex, extraData: extraData,
//             ),
//           ),
//         ],
//       ),
//     ],
//   );
// }
//
// /// ✅ **공통 게시판 라우트 생성 함수**
// GoRoute _buildBoardRoute({
//   required String board, // 📌 기존 `board` 그대로 유지 (URL 경로용)
//   required String label, // 📌 `label`을 추가하여 UI에서 사용
//   required Widget listScreen,
//   required Widget Function(String label, String itemIndex, Map<String, dynamic>? extraData) detailsScreen,
// }) {
//   return GoRoute(
//     path: board,
//     pageBuilder: (context, state) {
//       print('nwn_routes.dart: /nwn/$board 접근');
//       return NoTransitionPage(child: listScreen);
//     },
//     routes: [
//       GoRoute(
//         path: ':itemIndex',
//         builder: (context, state) {
//           final id = state.pathParameters['itemIndex'];
//           final splitUrl = state.location;
//
//           if (id == null) {
//             print('❌ nwn_routes.dart: /nwn/$board/:itemIndex 값이 없음!');
//             return const Scaffold(
//               body: Center(child: Text("잘못된 접근입니다.")),
//             );
//           }
//
//           print('✅ nwn_routes.dart: /nwn/$board/$id 접근 (fullUrl: $splitUrl)');
//
//           return FutureBuilder<Map<String, dynamic>>(
//             future: extractMenuMapData1(splitUrl, id), // 서버에서 데이터 로드
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 print('🔄 nwn_routes.dart: /nwn/$board/$id 데이터 로드 중...');
//                 return const Scaffold(
//                   body: Center(child: CircularProgressIndicator()),
//                 );
//               }
//
//               if (snapshot.hasError) {
//                 print('❌ nwn_routes.dart: /nwn/$board/$id 에러 발생: ${snapshot.error}');
//                 return Scaffold(
//                   body: Center(
//                     child: Text('Error: ${snapshot.error}'),
//                   ),
//                 );
//               }
//
//               final data = snapshot.data!;
//               final mappedIds = data['mappedIds'];
//               final currentIndex = data['currentIndex'];
//
//               print('✅ nwn_routes.dart: /nwn/$board/$id 데이터 로드 완료 (currentIndex: $currentIndex)');
//
//               // ✅ `detailsScreen`을 반환할 때 `label` 값을 사용하도록 변경 ✅
//               return detailsScreen(
//                 label, // 💡 `board` 대신 `label` 사용!
//                 id,
//                 {
//                   'currentIndex': currentIndex,
//                   'mappedIds': mappedIds,
//                 },
//               );
//             },
//           );
//         },
//         routes: [
//           GoRoute(
//             path: 'update',
//             builder: (context, state) {
//               print('🛠 nwn_routes.dart: /nwn/$board/:itemIndex/update 접근');
//               return const Text('게시글 수정 페이지'); // 🛠️ 여기에 실제 수정 화면 추가 필요
//             },
//           ),
//         ],
//       ),
//     ],
//   );
// }
