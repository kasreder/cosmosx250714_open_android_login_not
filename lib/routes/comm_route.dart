// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
// import '../util/pageindex.dart';
// import '../view/screen/board/community/free/comm_free_details_screen.dart';
// import '../view/screen/board/community/free/comm_free_list_screen.dart';
// import '../view/screen/board/community/record/comm_record_details_screen.dart';
// import '../view/screen/board/community/record/comm_record_list_screen.dart'; // fetchDataFromServer 관련 함수 사용
//
// /// ✅ **뉴스 & 공지사항 브랜치**
// StatefulShellBranch buildCommBranch() {
//   return StatefulShellBranch(
//     navigatorKey: GlobalKey<NavigatorState>(debugLabel: '커뮤니티'),
//     routes: [
//       GoRoute(
//         path: '/comm',
//         redirect: (context, state) => state.location == '/comm' ? '/comm/free/' : null,
//         pageBuilder: (context, state) {
//           print('comm_routes.dart: /comm 접근');
//           return const NoTransitionPage(
//             child: FreeListScreen(label: 'comm', detailPath: '/comm/free/'),
//           );
//         },
//         routes: [
//           _buildBoardRoute(
//             board: 'free',
//             label: '자유',
//             listScreen: const FreeListScreen(label: '자유', detailPath: '/comm/free/'),
//             detailsScreen: (label, itemIndex, extraData) => FreeDetailsScreen(
//               label: label, itemIndex: itemIndex, extraData: extraData,
//             ),
//           ),
//           _buildBoardRoute(
//             board: 'record',
//             label: '기록/실험',
//             listScreen: const RecordListScreen(label: '기록/실험', detailPath: '/comm/record/'),
//             detailsScreen: (label, itemIndex, extraData) => RecordDetailsScreen(
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
//       print('comm_routes.dart: /comm/$board 접근');
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
//             print('❌ comm_routes.dart: /comm/$board/:itemIndex 값이 없음!');
//             return const Scaffold(
//               body: Center(child: Text("잘못된 접근입니다.")),
//             );
//           }
//
//           print('✅ comm_routes.dart: /comm/$board/$id 접근 (fullUrl: $splitUrl)');
//
//           return FutureBuilder<Map<String, dynamic>>(
//             future: extractMenuMapData1(splitUrl, id), // 서버에서 데이터 로드
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 print('🔄 comm_routes.dart: /comm/$board/$id 데이터 로드 중...');
//                 return const Scaffold(
//                   body: Center(child: CircularProgressIndicator()),
//                 );
//               }
//
//               if (snapshot.hasError) {
//                 print('❌ comm_routes.dart: /comm/$board/$id 에러 발생: ${snapshot.error}');
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
//               print('✅ comm_routes.dart: /comm/$board/$id 데이터 로드 완료 (currentIndex: $currentIndex)');
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
//               print('🛠 comm_routes.dart: /comm/$board/:itemIndex/update 접근');
//               return const Text('게시글 수정 페이지'); // 🛠️ 여기에 실제 수정 화면 추가 필요
//             },
//           ),
//         ],
//       ),
//     ],
//   );
// }
