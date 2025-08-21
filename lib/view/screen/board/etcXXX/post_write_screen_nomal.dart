// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
//
// import '../../../provider/user_provider.dart';
// import '../../../util/global_notifier.dart';
//
// import '../widget/appbar.dart';
// import '../widget/drawer.dart';
// import 'nwm_news_screen.dart';
//
// class PostWriteNomal extends StatefulWidget {
//   const PostWriteNomal({
//     super.key,
//     this.passedSubMenuCode, // 전달받은 서브메뉴 코드
//   });
//
//   final String? passedSubMenuCode;
//
//   @override
//   State<PostWriteNomal> createState() => _PostWriteNomalState();
// }
//
// class _PostWriteNomalState extends State<PostWriteNomal> {
//   String? selectedMenu; // 선택된 상위 메뉴
//   String? selectedSubMenu; // 선택된 서브메뉴
//   String? subMenuId; // 선택된 서브메뉴의 ID (board_id)
//   List<String> menuOptions = []; // 상위 메뉴 옵션 리스트
//   List<String> subMenus = []; // 서브메뉴 옵션 리스트
//
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _contentController = TextEditingController(); // 콘텐츠 입력용 컨트롤러
//
//   // 서브메뉴들을 정의합니다.
//   List<List<String>> subMenus1 = [
//     ["새소식", "nwm", ""],
//     ["뉴스", "news", "1"],
//     ["공지사항", "notice", "2"],
//     ["제휴문의", "partnership", "3"],
//   ];
//
//   List<List<String>> subMenus2 = [
//     ["커뮤니티", "comm", ""],
//     ["자유게시판", "free", "4"],
//     ["기록/일지", "experiment", "5"],
//   ];
//
//   // 모든 서브메뉴 리스트를 모은 리스트
//   List<List<List<String>>> subMenusList = [];
//
//   @override
//   void initState() {
//     super.initState();
//
//     // subMenusList를 초기화합니다.
//     subMenusList = [
//       subMenus1,
//       subMenus2,
//     ];
//
//     // 상위 메뉴 옵션을 초기화합니다.
//     menuOptions = getMenuOptions();
//
//     _initializeSelectedMenus();
//
//     // 콘텐츠 입력 필드가 변경될 때마다 UI를 갱신하여 미리보기가 업데이트되도록 합니다.
//     _contentController.addListener(() {
//       setState(() {});
//     });
//   }
//
//   void _initializeSelectedMenus() {
//     if (widget.passedSubMenuCode != null) {
//       // 전달받은 서브메뉴 코드가 있을 경우 초기 선택 상태를 설정합니다.
//       String passedSubMenuCode = widget.passedSubMenuCode!;
//       var higherMenu = getHigherMenuFromSubMenuCode(passedSubMenuCode);
//       if (higherMenu.isNotEmpty) {
//         setState(() {
//           selectedMenu = higherMenu['menuDisplayName'];
//           subMenus = getSubMenus(selectedMenu!);
//           selectedSubMenu = getSubMenuDisplayName(passedSubMenuCode);
//           subMenuId = getBoardIdFromSubMenuCode(passedSubMenuCode);
//         });
//       }
//     } else {
//       // 초기 선택 사항이 없을 경우
//       setState(() {
//         selectedMenu = null;
//         selectedSubMenu = null;
//         subMenuId = null;
//         subMenus = [];
//       });
//     }
//   }
//
//   @override
//   void didUpdateWidget(PostWriteNomal oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     if (widget.passedSubMenuCode != oldWidget.passedSubMenuCode) {
//       _initializeSelectedMenus();
//     }
//   }
//
//   // 상위 메뉴 옵션 리스트를 반환하는 함수
//   List<String> getMenuOptions() {
//     List<String> menuOptions = [];
//     for (var subMenus in subMenusList) {
//       String menuDisplayName = subMenus[0][0];
//       menuOptions.add(menuDisplayName);
//     }
//     return menuOptions;
//   }
//
//   // 선택된 상위 메뉴에 해당하는 서브메뉴 리스트를 반환하는 함수
//   List<String> getSubMenus(String selectedMenu) {
//     for (var subMenus in subMenusList) {
//       String menuDisplayName = subMenus[0][0];
//       if (menuDisplayName == selectedMenu) {
//         // 첫 번째 항목(상위 메뉴)을 제외하고 서브메뉴를 반환합니다.
//         return subMenus.skip(1).map((item) => item[0]).toList();
//       }
//     }
//     return [];
//   }
//
//   // 서브메뉴의 표시 이름을 받아 해당 코드(subMenuCode)를 반환하는 함수
//   String getSubMenuCode(String subMenuDisplayName) {
//     for (var subMenus in subMenusList) {
//       for (var item in subMenus) {
//         if (item[0] == subMenuDisplayName) {
//           return item[1];
//         }
//       }
//     }
//     return '';
//   }
//
//   // 서브메뉴의 코드(subMenuCode)를 받아 board_id를 반환하는 함수
//   String getBoardIdFromSubMenuCode(String subMenuCode) {
//     for (var subMenus in subMenusList) {
//       for (var item in subMenus) {
//         if (item[1] == subMenuCode) {
//           return item[2]; // board_id 반환
//         }
//       }
//     }
//     return '';
//   }
//
//   // 서브메뉴 코드를 받아 상위 메뉴 정보를 반환하는 함수
//   Map<String, String> getHigherMenuFromSubMenuCode(String subMenuCode) {
//     for (var subMenus in subMenusList) {
//       for (var item in subMenus) {
//         if (item[1] == subMenuCode) {
//           return {
//             'menuDisplayName': subMenus[0][0],
//             'menuCode': subMenus[0][1],
//           };
//         }
//       }
//     }
//     return {};
//   }
//
//   // 서브메뉴 코드를 받아 표시 이름을 반환하는 함수
//   String getSubMenuDisplayName(String subMenuCode) {
//     for (var subMenus in subMenusList) {
//       for (var item in subMenus) {
//         if (item[1] == subMenuCode) {
//           return item[0];
//         }
//       }
//     }
//     return '';
//   }
//
//   // 제출 버튼을 눌렀을 때의 처리 함수
//   void _handleSubmit(UserProvider userProvider) async {
//     String? accessToken = userProvider.accessToken;
//     int id = userProvider.id;
//     String? board = subMenuId;
//     String title = _titleController.text;
//     String content = _contentController.text; // TextEditingController 사용
//
//     // 유효성 검사
//     if (title.isEmpty) {
//       _showError('제목을 입력해주세요.');
//       return;
//     }
//
//     if (content.isEmpty) {
//       _showError('내용을 입력해주세요.');
//       return;
//     }
//
//     if (selectedMenu == null || selectedSubMenu == null || subMenuId == null) {
//       _showError('메뉴와 게시판을 선택해주세요.');
//       return;
//     }
//
//     if (accessToken == null) {
//       _showError('액세스 토큰이 없습니다. 로그인이 필요합니다.');
//       return;
//     }
//
//     print('_handleSubmit 액세스 토큰 : $accessToken');
//     print('_handleSubmit 시작');
//     const String url = "https://terraforming.info/api/posts"; // 서버의 API 엔드포인트 (예시)
//
//     try {
//       final response = await Dio().post(
//         url,
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json; charset=UTF-8',
//             'Authorization': 'Bearer $accessToken',
//           },
//         ),
//         data: jsonEncode(<String, dynamic>{
//           'user_id': id,
//           "board_id": board ?? '',
//           'title': title,
//           'content': content, // 텍스트 콘텐츠 전송
//         }),
//       );
//
//       print('응답 상태 코드: ${response.statusCode}');
//       if (response.statusCode == 200) {
//         print('서버로 데이터 전송 성공');
//         _titleController.clear();
//         _contentController.clear();
//
//         // 성공적으로 작성되었을 때의 네비게이션 처리
//         if (kIsWeb) {
//           context.go('/nwn/news', extra: UniqueKey());
//           refreshNotifier.value++;
//         } else {
//           Navigator.of(context).push(MaterialPageRoute(
//             builder: (BuildContext context) => const News(
//               label: 'News라우팅s',
//               detailPath: '/nwn/news/s',
//             ),
//           ));
//         }
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('글이 성공적으로 작성되었습니다.')),
//         );
//       } else {
//         print('데이터 전송 실패');
//         _showError('데이터 전송에 실패했습니다. 다시 시도해주세요.');
//       }
//     } catch (error) {
//       print('데이터 전송 중 오류 발생: $error');
//       _showError('데이터 전송 중 오류가 발생했습니다.');
//     }
//
//     print('유저 ID: $id');
//     print('보드 ID: $board');
//     print('제목: $title');
//     print('내용: $content');
//   }
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: SelectableText(message),
//         duration: const Duration(seconds: 3),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//
//     // MediaQuery를 사용하여 키보드가 열려있는지 감지
//     final bottomInset = MediaQuery.of(context).viewInsets.bottom;
//     final isKeyboardVisible = bottomInset > 100; // 임계값 조정
//
//     return Scaffold(
//       appBar: BaseAppBar(
//         title: "글작성 페이지Nomal",
//         appBar: AppBar(),
//       ),
//       drawer: const BaseDrawer(),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               // 상위 메뉴 선택 드롭다운
//               DropdownButtonFormField<String>(
//                 value: selectedMenu,
//                 hint: const Text('메뉴 선택'),
//                 onChanged: (newValue) {
//                   setState(() {
//                     selectedMenu = newValue;
//                     subMenus = getSubMenus(selectedMenu!);
//                     selectedSubMenu = null;
//                     subMenuId = null;
//                   });
//                 },
//                 items: menuOptions.map((menu) {
//                   return DropdownMenuItem(
//                     value: menu,
//                     child: Text(menu),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 16),
//               // 서브메뉴 선택 드롭다운
//               DropdownButtonFormField<String>(
//                 value: selectedSubMenu,
//                 hint: const Text('게시판 선택'),
//                 onChanged: (newValue) {
//                   setState(() {
//                     selectedSubMenu = newValue;
//                     String subMenuCode = getSubMenuCode(selectedSubMenu ?? '');
//                     subMenuId = getBoardIdFromSubMenuCode(subMenuCode);
//                     // 서브메뉴 선택 시 상위 메뉴도 자동 선택
//                     var higherMenu = getHigherMenuFromSubMenuCode(subMenuCode);
//                     if (higherMenu.isNotEmpty) {
//                       selectedMenu = higherMenu['menuDisplayName'];
//                       subMenus = getSubMenus(selectedMenu!);
//                     }
//                   });
//                 },
//                 items: subMenus.map((board) {
//                   return DropdownMenuItem(
//                     value: board,
//                     child: Text(board),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 16),
//               // 제목 입력 필드
//               TextField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(
//                   labelText: '제목',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // 콘텐츠 입력 필드 (멀티라인)
//               TextField(
//                 controller: _contentController,
//                 maxLines: 15,
//                 decoration: const InputDecoration(
//                   hintText: '여기에 글을 작성하세요...',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // 작성자 정보 표시
//               SelectableText('작성자 ${userProvider.nickname}'),
//               const SizedBox(height: 16),
//               // 버튼 그룹
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () => _handleSubmit(userProvider),
//                     child: const Text('작성하기'),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       // 취소 로직 (예: 이전 페이지로 돌아가기)
//                       context.pop();
//                     },
//                     child: const Text('취소하기'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//       // 키보드가 올라올 때 레이아웃이 변하지 않도록 설정
//       resizeToAvoidBottomInset: true,
//     );
//   }
// }
