import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../util/pageindex.dart';
import '../view/screen/post_detail_update.dart';
import '../view/screen/board/nwn/notice/nwn_notice_list_screen.dart';
import '../view/screen/board/nwn/notice/nwn_notice_details_screen.dart';

/// ✅ **뉴스 & 공지사항 브랜치**
StatefulShellBranch buildNoticeBranch() {
  return StatefulShellBranch(
    navigatorKey: GlobalKey<NavigatorState>(debugLabel: '공지사항'),
    routes: [
      GoRoute(
        path: '/nwn1',
        redirect: (context, state) => state.location == '/nwn1' ? '/nwn1/notice/' : null,
        pageBuilder: (context, state) {
          print('notice_routes.dart: /nwn1 접근');
          return const NoTransitionPage(
            child: NoticeListScreen(label: 'nwn1', detailPath: '/nwn1/notice/'),
          );
        },
        routes: [
          // _buildBoardRoute(
          //   board: 'news',
          //   label: '뉴스',
          //   listScreen: const NewsListScreen(label: '뉴스', detailPath: '/$topMunu/news/'),
          //   detailsScreen: (label, itemIndex, extraData) => NewsDetailsScreen(
          //     label: label, itemIndex: itemIndex, extraData: extraData,
          //   ),
          // ),
          _buildBoardRoute(
            middleMunu: 'notice',
            topMunu : 'nwn1',
            label: '공지사항',
            listScreen: const NoticeListScreen(label: '공지사항', detailPath: '/nwn1/notice/'),
            detailsScreen: (label, itemIndex, extraData) => NoticeDetailsScreen(
              label: label, itemIndex: itemIndex, extraData: extraData,
            ),
          ),
        ],
      ),
    ],
  );
}

/// ✅ **공통 게시판 라우트 생성 함수**
GoRoute _buildBoardRoute({
  required String middleMunu, // 📌 기존 `middleMunu` 그대로 유지 (URL 경로용)
  required String topMunu, // 📌 기존 `topMunu` 그대로 유지 (URL 경로용)
  required String label, // 📌 `label`을 추가하여 UI에서 사용
  required Widget listScreen,
  required Widget Function(String label, String itemIndex, Map<String, dynamic>? extraData) detailsScreen,
}) {
  return GoRoute(
    path: middleMunu,
    pageBuilder: (context, state) {
      print('notice_routes.dart: /$topMunu/$middleMunu 접근');
      return NoTransitionPage(child: listScreen);
    },
    routes: [
      GoRoute(
        path: ':itemIndex',
        builder: (context, state) {
          final id = state.pathParameters['itemIndex'];
          final splitUrl = state.location;

          if (id == null) {
            print('❌ notice_routes.dart: /$topMunu/$middleMunu/:itemIndex 값이 없음!');
            return const Scaffold(
              body: Center(child: Text("잘못된 접근입니다.")),
            );
          }

          print('✅ notice_routes.dart: /$topMunu/$middleMunu/$id 접근 (fullUrl: $splitUrl)');

          return FutureBuilder<Map<String, dynamic>>(
            future: extractMenuMapData1(splitUrl, id), // 서버에서 데이터 로드
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                print('🔄 notice_routes.dart: /$topMunu/$middleMunu/$id 데이터 로드 중...');
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                print('❌ notice_routes.dart: /$topMunu/$middleMunu/$id 에러 발생: ${snapshot.error}');
                return Scaffold(
                  body: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              }

              final data = snapshot.data!;
              final mappedIds = data['mappedIds'];
              final currentIndex = data['currentIndex'];

              print('✅ notice_routes.dart: /$topMunu/$middleMunu/$id 데이터 로드 완료 (currentIndex: $currentIndex)');

              // ✅ `detailsScreen`을 반환할 때 `label` 값을 사용하도록 변경 ✅
              return detailsScreen(
                label, // 💡 `board` 대신 `label` 사용!
                id,
                {
                  'currentIndex': currentIndex,
                  'mappedIds': mappedIds,
                },
              );
            },
          );
        },
        routes: [
          GoRoute(
            path: 'update',
            builder: (context, state) {
              print('🛠 notice_routes.dart: /$topMunu/$middleMunu/:itemIndex/update 접근');
              return PostDetailUpdate(
                label: '공지/문의 게시판 수정',
                middleMunu: middleMunu,
                topMunu : topMunu,
                itemIndex: state.pathParameters['itemIndex'], // 파라미터 전달
              );
            },
          ),
        ],
      ),
    ],
  );
}
