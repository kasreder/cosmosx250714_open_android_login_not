// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:provider/provider.dart';
// //
// // import 'provider/user_provider.dart';
// // import 'util/pageindex.dart';
// // import 'view/screen/board/community/free/comm_free_details_screen.dart';
// // import 'view/screen/board/community/free/comm_free_list_screen.dart';
// // import 'view/screen/board/community/record/nwn_record_screen.dart';
// // import 'view/screen/board/nwn/notice/nwn_notice_list_screen.dart';
// // import 'view/screen/board/nwn/news/nwn_news_details_screen.dart';
// // import 'view/screen/board/nwn/news/nwn_news_list_screen.dart';
// // import 'view/screen/board/nwn/notice/nwn_notice_details_screen.dart';
// // import 'view/screen/home.dart';
// // import 'view/screen/login.dart';
// // import 'view/screen/member_page.dart';
// // import 'view/screen/post_detail_update.dart';
// // import 'view/screen/post_write_screen.dart';
// // import 'view/screen/post_write_screen2.dart';
// // import 'view/widget/navigation.dart';
// // import 'view/screen/board/etc/sns_signup.dart';
// // import 'view/screen/local_signup.dart';
// //
// // final _rootNavigatorKey = GlobalKey<NavigatorState>();
// // final _shellNavigator1Key = GlobalKey<NavigatorState>(debugLabel: 'Home');
// // final _shellNavigator2Key = GlobalKey<NavigatorState>(debugLabel: '새소식');
// // final _shellNavigator3Key = GlobalKey<NavigatorState>(debugLabel: '커뮤니티');
// // final _shellNavigator4Key = GlobalKey<NavigatorState>(debugLabel: '설정');
// // final _shellNavigator5Key = GlobalKey<NavigatorState>(debugLabel: '이바타');
// //
// // final GoRouter router = GoRouter(
// //   initialLocation: '/',
// //   navigatorKey: _rootNavigatorKey,
// //   debugLogDiagnostics: true,
// //   routes: [
// //     StatefulShellRoute.indexedStack(
// //       builder: (context, state, navigationShell) {
// //         return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
// //       },
// //       branches: [
// //         /// 🌟 Home 경로
// //         _buildHomeBranch(),
// //
// //         /// 🌟 새소식 (News & Notice)
// //         _buildNewsBranch(),
// //
// //         /// 🌟 커뮤니티 (자유게시판 & 기록)
// //         _buildCommunityBranch(),
// //
// //         /// 🌟 설정 페이지
// //         _buildSettingsBranch(),
// //
// //         /// 🌟 회원 관련 페이지 (로그인/회원가입)
// //         _buildMemberBranch(),
// //       ],
// //     ),
// //
// //     /// 🌟 이미지 업로드가 포함된 글쓰기
// //     GoRoute(
// //       path: '/PostWriteWithImageUpload',
// //       pageBuilder: (context, state) {
// //         final extraData = state.extra as Map<String, dynamic>?;
// //         final lastParam = extraData?['lastParam'];
// //
// //         return MaterialPage(
// //           key: state.pageKey,
// //           child: PostWriteWithImageUpload(),
// //         );
// //       },
// //     ),
// //   ],
// // );
// //
// // /// ✅ Home 브랜치
// // StatefulShellBranch _buildHomeBranch() {
// //   return StatefulShellBranch(
// //     navigatorKey: _shellNavigator1Key,
// //     routes: [
// //       GoRoute(
// //         path: '/',
// //         pageBuilder: (context, state) => const NoTransitionPage(
// //           child: RootScreen(label: 'COSMOSX 월컴', detailsPath: "/PostWrite"),
// //         ),
// //         routes: [
// //           GoRoute(
// //             path: 'PostWrite',
// //             redirect: (context, state) {
// //               final isLoggedIn = Provider.of<UserProvider>(context, listen: false).accessToken != null;
// //               return isLoggedIn ? null : '/login';
// //             },
// //             pageBuilder: (context, state) {
// //               final extraData = state.extra as Map<String, dynamic>?;
// //               final lastParam = extraData?['lastParam'];
// //
// //               return MaterialPage(
// //                 key: state.pageKey,
// //                 child: PostWrite(passedSubMenuCode: lastParam),
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //     ],
// //   );
// // }
// //
// // /// ✅ 새소식 브랜치 (뉴스 & 공지사항)
// // StatefulShellBranch _buildNewsBranch() {
// //   return StatefulShellBranch(
// //     navigatorKey: _shellNavigator2Key,
// //     routes: [
// //       GoRoute(
// //         path: '/nwn',
// //         redirect: (context, state) => state.location == '/nwn' ? '/nwn/news' : null,
// //         pageBuilder: (context, state) => const NoTransitionPage(
// //           child: NewsListScreen(label: 'nwn', detailPath: '/nwn/news'),
// //         ),
// //         routes: [
// //           _buildBoardRoute('news', NewsListScreen(label: '뉴스라벨', detailPath: '1',), NewsDetailsScreen(label: '뉴스라벨1',)),
// //           _buildBoardRoute('notice', NoticeListScreen(label: '공지라벨', detailPath: '2',), NoticeDetailsScreen(label: '공지라벨2',)),
// //         ],
// //       ),
// //     ],
// //   );
// // }
// //
// // /// ✅ 커뮤니티 브랜치 (자유게시판 & 기록)
// // StatefulShellBranch _buildCommunityBranch() {
// //   return StatefulShellBranch(
// //     navigatorKey: _shellNavigator3Key,
// //     routes: [
// //       GoRoute(
// //         path: '/comm',
// //         redirect: (context, state) => state.location == '/comm' ? '/comm/free' : null,
// //         pageBuilder: (context, state) => const NoTransitionPage(
// //           child: FreeListScreen(label: 'comm', detailPath: '/comm/free'),
// //         ),
// //         routes: [
// //           _buildBoardRoute('free', FreeListScreen(label: '자유라벨', detailPath: '3',), FreeDetailsScreen(label: '자유라벨1',)),
// //           _buildBoardRoute('record', Record(label: '기록라벨', detailPath: '4',), RecordDetailsScreen(label: '기록라벨4',)),
// //         ],
// //       ),
// //     ],
// //   );
// // }
// //
// // /// ✅ 설정 브랜치
// // StatefulShellBranch _buildSettingsBranch() {
// //   return StatefulShellBranch(
// //     navigatorKey: _shellNavigator4Key,
// //     routes: [
// //       GoRoute(
// //         path: '/set',
// //         pageBuilder: (context, state) => const NoTransitionPage(
// //           child: RootScreen(label: '셋업', detailsPath: '/set/details'),
// //         ),
// //         // routes: [
// //         //   GoRoute(
// //         //     path: 'details',
// //         //     builder: (context, state) => const DetailsScreen(label: 'C'),
// //         //   ),
// //         // ],
// //       ),
// //     ],
// //   );
// // }
// //
// // /// ✅ 회원 관련 브랜치 (로그인 & 회원가입)
// // StatefulShellBranch _buildMemberBranch() {
// //   return StatefulShellBranch(
// //     navigatorKey: _shellNavigator5Key,
// //     routes: [
// //       GoRoute(
// //         path: '/member',
// //         pageBuilder: (context, state) {
// //           final userProvider = Provider.of<UserProvider>(context, listen: false);
// //           if (userProvider.accessToken != null) {
// //             return const NoTransitionPage(child: MemberPage());
// //           } else {
// //             WidgetsBinding.instance.addPostFrameCallback((_) {
// //               context.go('/login', extra: UniqueKey());
// //             });
// //             return const NoTransitionPage(child: Login(label: 'Login', detailsPath_a: '/login'));
// //           }
// //         },
// //       ),
// //       GoRoute(
// //         path: '/login',
// //         pageBuilder: (context, state) {
// //           final userProvider = Provider.of<UserProvider>(context, listen: false);
// //           return userProvider.accessToken == null
// //               ? const NoTransitionPage(child: Login(label: 'Login', detailsPath_a: '/login/details'))
// //               : const NoTransitionPage(child: MemberPage());
// //         },
// //       ),
// //       GoRoute(path: '/localSignup', builder: (context, state) => const LocalSignupPage()),
// //       GoRoute(path: '/snsSignup', builder: (context, state) => const SnsSignupPage()),
// //     ],
// //   );
// // }
// //
// // /// ✅ 공통 게시판 라우트 생성 함수 (뉴스, 자유게시판 등)
// // GoRoute _buildBoardRoute(String board, Widget listScreen, Widget detailsScreen) {
// //   return GoRoute(
// //     path: board,
// //     pageBuilder: (context, state) => NoTransitionPage(child: listScreen),
// //     routes: [
// //       GoRoute(
// //         path: ':itemIndex',
// //         builder: (context, state) {
// //           final id = state.pathParameters['itemIndex'];
// //           final fullUrl = state.location;
// //           return FutureBuilder<Map<String, dynamic>>(
// //             future: extractMenuMapData1(fullUrl, id!),
// //             builder: (context, snapshot) {
// //               if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
// //               final data = snapshot.data!;
// //               return detailsScreen;
// //             },
// //           );
// //         },
// //         routes: [
// //           GoRoute(
// //             path: 'update',
// //             builder: (context, state) => PostDetailUpdate(label: '게시판 수정', itemIndex: state.pathParameters['itemIndex']),
// //           ),
// //         ],
// //       ),
// //     ],
// //   );
// // }
//
//
//
//
//
//
//
//
//
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
//
// import 'provider/user_provider.dart';
// import 'util/pageindex.dart';
// import 'view/screen/board/community/free/comm_free_details_screen.dart';
// import 'view/screen/board/community/free/comm_free_list_screen.dart';
// import 'view/screen/board/community/record/nwn_record_screen.dart';
// import 'view/screen/board/nwn/notice/nwn_notice_list_screen.dart';
// import 'view/screen/board/nwn/news/nwn_news_details_screen.dart';
// import 'view/screen/board/nwn/news/nwn_news_list_screen.dart';
//
// import 'view/screen/board/nwn/notice/nwn_notice_details_screen.dart';
// import 'view/screen/home.dart';
// import 'view/screen/login.dart';
// import 'view/screen/member_page.dart';
//
//
// import 'view/screen/post_detail_update.dart';
// import 'view/screen/post_write_screen.dart';
//
// import 'view/screen/post_write_screen2.dart';
// import 'view/widget/navigation.dart';
// import 'view/screen/board/etc/sns_signup.dart';
// import 'view/screen/local_signup.dart';
//
// final _rootNavigatorKey = GlobalKey<NavigatorState>();
// final _shellNavigator1Key = GlobalKey<NavigatorState>(debugLabel: 'Home');
// final _shellNavigator2Key = GlobalKey<NavigatorState>(debugLabel: '새소식');
// final _shellNavigator3Key = GlobalKey<NavigatorState>(debugLabel: '커뮤니티');
// final _shellNavigator4Key = GlobalKey<NavigatorState>(debugLabel: '설정');
// final _shellNavigator5Key = GlobalKey<NavigatorState>(debugLabel: '이바타');
//
// final GoRouter router = GoRouter(
//   initialLocation: '/',
//   // * Passing a navigatorKey causes an issue on hot reload:
//   // * https://github.com/flutter/flutter/issues/113757#issuecomment-1518421380
//   // * However it's still necessary otherwise the navigator pops back to
//   // * root on hot reload
//   navigatorKey: _rootNavigatorKey,
//   debugLogDiagnostics: true,
//   routes: [
//     // Stateful navigation based on:
//     // https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
//     StatefulShellRoute.indexedStack(
//       builder: (context, state, navigationShell) {
//         return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
//       },
//       branches: [
//         StatefulShellBranch(
//           navigatorKey: _shellNavigator1Key,
//           routes: [
//             GoRoute(
//               path: '/',
//               pageBuilder: (context, state) => const NoTransitionPage(
//                 child: RootScreen(label: 'COSMOSX 월컴', detailsPath: "/PostWrite"),
//               ),
//               routes: [
//                 GoRoute(
//                   path: 'PostWrite',
//                   redirect: (BuildContext context, GoRouterState state) {
//                     // 로그인 여부 확인
//                     final isLoggedIn = Provider.of<UserProvider>(context, listen: false).accessToken != null;
//
//                     if (!isLoggedIn) {
//                       // 로그인하지 않은 경우 리다이렉트
//                       return '/login'; // 로그인 페이지로 이동
//                     }
//
//                     // 로그인 상태인 경우 접근 허용 (리다이렉트하지 않음)
//                     return null;
//                   },
//                   pageBuilder: (context, state) {
//                     final extraData = state.extra as Map<String, dynamic>?; // 전달된 extra 값을 받습니다.
//                     final lastParam = extraData?['lastParam']; // 'lastParam' 키의 값을 추출합니다.
//                     print(state.extra);
//                     return MaterialPage(
//                       key: state.pageKey,
//                       child: PostWrite(
//                         passedSubMenuCode: lastParam, // PostWrite 위젯에 전달합니다.
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//
//           ],
//         ),
//         StatefulShellBranch(
//           navigatorKey: _shellNavigator2Key,
//           routes: [
//             // Shopping Cart
//             GoRoute(
//               path: '/nwn',
//               redirect: (context, state) {
//                 if (state.location == '/nwn') {
//                   return '/nwn/news';
//                 }
//                 return null;
//               },
//               pageBuilder: (BuildContext context, GoRouterState state) =>
//                   const NoTransitionPage(
//                 child: NewsListScreen(label: 'nwn', detailPath: '/nwn/news',),
//               ),
//               routes: [
//                 GoRoute(
//                   path: 'news',
//                   pageBuilder: (BuildContext context, GoRouterState state) {
//                     final localKey = state.extra as LocalKey?;
//                     return MaterialPage(
//                       key: localKey,
//                       child: const NewsListScreen(
//                         label: 'News',
//                         detailPath: '/nwn/news/',
//                       ),
//                     );
//                   },
//                   routes: [
//                     GoRoute(
//                       path: ':itemIndex',
//                       builder: (BuildContext context, GoRouterState state) {
//                         final id = state.pathParameters['itemIndex'];
//                         print('라우팅 id 0000: $id');
//
//                         // localKey 확인 및 처리
//                         final localKey = state.extra as LocalKey?;
//                         print('라우팅 localKey 111: $localKey');
//                         if (localKey != null) {
//                           // localKey가 있을 경우 데이터를 바로 사용
//                           final extraData = (localKey as ValueKey).value as Map<String, dynamic>;
//                           print('라우팅 extraData 22: $extraData');
//
//                           return NewsDetailsScreen(
//                             label: 'COSMOSX > 뉴스게시판',
//                             itemIndex: id,
//                             extraData: extraData,
//                           );
//                         } else {
//                           print('ididididididid3333: $id');
//                           final splitUrl = state.location; // 현재 라우트의 일부 URL
//                           print('라우팅 fullUrl: $splitUrl');
//                           // localKey가 없을 경우 서버에서 데이터 로드
//                           return FutureBuilder<Map<String, dynamic>>(
//                             future: extractMenuMapData1(splitUrl, id!), // 서버에서 데이터 로드
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState == ConnectionState.waiting) {
//                                 print('ididididididid44: $id');
//                                 // 데이터 로드 중 로딩 스피너 표시
//                                 return const Scaffold(
//                                   body: Center(child: CircularProgressIndicator()),
//                                 );
//                               }
//
//                               if (snapshot.hasError) {
//                                 // 에러 발생 시
//                                 return Scaffold(
//                                   body: Center(
//                                     child: Text('Error: ${snapshot.error}'),
//                                   ),
//                                 );
//                               }
//
//                               // 데이터를 성공적으로 로드한 경우
//                               final data = snapshot.data!;
//                               final mappedIds = data['mappedIds'];
//                               final currentIndex = data['currentIndex'];
//
//                               // 데이터를 NewsDetailsScreen에 전달
//                               return NewsDetailsScreen(
//                                 label: 'COSMOSX > 뉴스게시판',
//                                 itemIndex: id,
//                                 extraData: {
//                                   'currentIndex': currentIndex,
//                                   'mappedIds': mappedIds,
//                                 },
//                               );
//                             },
//                           );
//                         }
//                       },
//                       routes: [
//                         GoRoute(
//                           path: 'update',
//                           builder: (context, state) {
//                             return PostDetailUpdate(
//                               label: 'COSMOSX > 뉴스게시판 수정',
//                               itemIndex: state.pathParameters['itemIndex'], // 파라미터 전달
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 GoRoute(
//                   path: 'notice',
//                   pageBuilder: (context, state) => const NoTransitionPage(
//                     child: NoticeListScreen(
//                       label: 'Notice',
//                       detailPath: '/nwn/notice/',
//                     ),
//                   ),
//                   routes: [
//                     GoRoute(
//                       path: ':itemIndex',
//                       builder: (BuildContext context, GoRouterState state) {
//                         print('Current path: ${state.location}');
//                         print('Query parameters: ${state.queryParameters}');
//                         final id = state.pathParameters['itemIndex'];
//                         return NoticeDetailsScreen(
//                           label: 'COSMOSX > 공지게시판',
//                           itemIndex: id,
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//         StatefulShellBranch(
//           navigatorKey: _shellNavigator3Key,
//           routes: [
//             GoRoute(
//               path: '/comm',
//               redirect: (context, state) {
//                 if (state.location == '/comm') {
//                   return '/comm/free'; // 기본 경로로 리다이렉트
//                 }
//                 return null;
//               },
//               pageBuilder: (BuildContext context, GoRouterState state) =>
//               const NoTransitionPage(
//                 child: FreeListScreen(label: 'comm', detailPath: '/comm/free'),
//               ),
//               routes: [
//                 // 기존 free 경로
//                 GoRoute(
//                   path: 'free',
//                   pageBuilder: (BuildContext context, GoRouterState state) {
//                     final localKey = state.extra as LocalKey?;
//                     return MaterialPage(
//                       key: localKey,
//                       child: const FreeListScreen(
//                         label: 'Free',
//                         detailPath: '/comm/free/',
//                       ),
//                     );
//                   },
//                   routes: [
//                     GoRoute(
//                       path: ':itemIndex',
//                       builder: (BuildContext context, GoRouterState state) {
//                         final id = state.pathParameters['itemIndex'];
//                         print('라우팅 id 0000: $id');
//
//                         // localKey 확인 및 처리
//                         final localKey = state.extra as LocalKey?;
//                         print('라우팅 localKey 111: $localKey');
//                         if (localKey != null) {
//                           // localKey가 있을 경우 데이터를 바로 사용
//                           final extraData = (localKey as ValueKey).value as Map<String, dynamic>;
//                           print('라우팅 extraData 22: $extraData');
//
//                           return FreeDetailsScreen(
//                             label: 'COSMOSX > 자유게시판',
//                             itemIndex: id,
//                             extraData: extraData,
//                           );
//                         } else {
//                           print('ididididididid3333: $id');
//                           final splitUrl = state.location; // 현재 라우트의 전체 URL
//                           print('라우팅 fullUrl: $splitUrl');
//                           // localKey가 없을 경우 서버에서 데이터 로드
//                           return FutureBuilder<Map<String, dynamic>>(
//                             future: extractMenuMapData1(splitUrl, id!), // 서버에서 데이터 로드
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState == ConnectionState.waiting) {
//                                 print('ididididididid44: $id');
//                                 // 데이터 로드 중 로딩 스피너 표시
//                                 return const Scaffold(
//                                   body: Center(child: CircularProgressIndicator()),
//                                 );
//                               }
//
//                               if (snapshot.hasError) {
//                                 // 에러 발생 시
//                                 return Scaffold(
//                                   body: Center(
//                                     child: Text('Error: ${snapshot.error}'),
//                                   ),
//                                 );
//                               }
//
//                               // 데이터를 성공적으로 로드한 경우
//                               final data = snapshot.data!;
//                               final mappedIds = data['mappedIds'];
//                               final currentIndex = data['currentIndex'];
//
//                               // 데이터를 FreeDetailsScreen에 전달
//                               return FreeDetailsScreen(
//                                 label: 'COSMOSX > 자유게시판',
//                                 itemIndex: id,
//                                 extraData: {
//                                   'currentIndex': currentIndex,
//                                   'mappedIds': mappedIds,
//                                 },
//                               );
//                             },
//                           );
//                         }
//                       },
//                       routes: [
//                         GoRoute(
//                           path: 'update',
//                           builder: (context, state) {
//                             return PostDetailUpdate(
//                               label: 'COSMOSX > 자유게시판 수정',
//                               itemIndex: state.pathParameters['itemIndex'], // 파라미터 전달
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 // 새로 추가된 record 경로
//                 GoRoute(
//                   path: 'record',
//                   pageBuilder: (BuildContext context, GoRouterState state) {
//                     final localKey = state.extra as LocalKey?;
//                     return MaterialPage(
//                       key: localKey,
//                       child: Record(
//                         label: 'Record',
//                         detailPath: '/comm/record/',
//                       ),
//                     );
//                   },
//                   routes: [
//                     GoRoute(
//                       path: ':itemIndex',
//                       builder: (BuildContext context, GoRouterState state) {
//                         final id = state.pathParameters['itemIndex'];
//                         return RecordDetailsScreen(
//                           label: 'COSMOSX > 기록/실험 게시판',
//                           itemIndex: id,
//                         );
//                       },
//                       routes: [
//                         GoRoute(
//                           path: 'update',
//                           builder: (context, state) {
//                             return PostDetailUpdate(
//                               label: 'COSMOSX > 기록/실험 게시판 수정',
//                               itemIndex: state.pathParameters['itemIndex'], // 파라미터 전달
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//
//
//           ],
//         ),
//         StatefulShellBranch(
//           navigatorKey: _shellNavigator4Key,
//           routes: [
//             // Shopping Cart
//             GoRoute(
//               path: '/set',
//               pageBuilder: (context, state) => const NoTransitionPage(
//                 child: RootScreen(label: '셋업', detailsPath: '/set/details'),
//               ),
//               // routes: [
//               //   GoRoute(
//               //     path: 'details',
//               //     builder: (context, state) => const DetailsScreen(label: 'C'),
//               //   ),
//               // ],
//             ),
//           ],
//         ),
//         StatefulShellBranch(
//           navigatorKey: _shellNavigator5Key,
//           routes: [
//             GoRoute(
//               path: '/member',
//               pageBuilder: (context, state) {
//                 final userProvider =
//                     Provider.of<UserProvider>(context, listen: false);
//                 if (userProvider.accessToken != null) {
//                   return const NoTransitionPage(
//                     child: MemberPage(),
//                   );
//                 } else {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     context.go('/login', extra: UniqueKey());
//                   });
//                   return const NoTransitionPage(
//                     child: Login(
//                       label: 'Login',
//                       detailsPath_a: '/login',
//                     ),
//                   );
//                 }
//               },
//             ),
//             // 토큰 유효성 검사 및 사용자 정보 가져오기
//             GoRoute(
//               path: '/login',
//               pageBuilder: (context, state) {
//                 final userProvider =
//                     Provider.of<UserProvider>(context, listen: false);
//                 if (userProvider.accessToken == null) {
//                   return const NoTransitionPage(
//                     child: Login(
//                       label: 'Login',
//                       detailsPath_a: '/login/details',
//                     ),
//                   );
//                 } else {
//                   context.go('/member', extra: UniqueKey());
//                   return const NoTransitionPage(
//                     child: MemberPage(),
//                   );
//                 }
//               },
//             ),
//             GoRoute(
//               path: '/localSignup',
//               builder: (context, state) => const LocalSignupPage(),
//             ),
//             GoRoute(
//               path: '/snsSignup',
//               builder: (context, state) => const SnsSignupPage(),
//             ),
//             GoRoute(
//               path: '/auth/kakao/callback',
//               builder: (context, state) {
//                 // 여기서 로그인 콜백을 처리합니다.
//                 final queryParams = state.queryParameters;
//                 final code = queryParams['code'];
//                 final error = queryParams['error'];
//                 if (error != null) {
//                   // 에러 처리 로직 추가
//                   print('Error: $error');
//                 } else if (code != null) {
//                   // 인증 코드를 사용하여 액세스 토큰을 가져오는 로직 추가
//                   print('Auth Code: $code');
//                 }
//                 // 임시로 메인 페이지로 리다이렉트
//                 return const RootScreen(
//                     label: 'COSMOSX 월컴', detailsPath: "/PostWrite");
//               },
//             ),
//           ],
//         ),
//       ],
//     ),
//     GoRoute(
//       path: '/PostWriteWithImageUpload',
//       pageBuilder: (context, state) {
//         final extraData = state.extra
//         as Map<String, dynamic>?; // 전달된 extra 값을 받습니다.
//         final lastParam =
//         extraData?['lastParam']; // 'lastParam' 키의 값을 추출합니다.
//         print(state.extra);
//         return MaterialPage(
//           key: state.pageKey,
//           child: PostWriteWithImageUpload(// PostWrite 위젯에 전달합니다.
//           ),
//         );
//       },
//     ),
//   ],
// );
