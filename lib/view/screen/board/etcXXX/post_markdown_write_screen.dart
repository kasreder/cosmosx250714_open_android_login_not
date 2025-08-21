// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
//
// import '../../../provider/user_provider.dart';
// import '../../../util/global_notifier.dart';
// import '../widget/appbar.dart';
// import '../widget/drawer.dart';
// import 'nwn_notice_screen.dart';
//
// class PostMarkDownWrite extends StatefulWidget {
//   const PostMarkDownWrite({
//     super.key,
//     this.passedSubMenuCode,
//   });
//
//   final String? passedSubMenuCode;
//
//   @override
//   State<PostMarkDownWrite> createState() => _PostMarkDownWriteState();
// }
//
// class _PostMarkDownWriteState extends State<PostMarkDownWrite> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _markdownController = TextEditingController();
//   String? selectedMenu;
//   String? selectedSubMenu;
//   String? subMenuId;
//   List<String> menuOptions = [];
//   List<String> subMenus = [];
//
//   final TextEditingController _titleController = TextEditingController();
//
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
//   List<List<List<String>>> subMenusList = [];
//
//   @override
//   void initState() {
//     super.initState();
//
//     subMenusList = [
//       subMenus1,
//       subMenus2,
//     ];
//
//     menuOptions = getMenuOptions();
//     _initializeSelectedMenus();
//
//     // Add listener to update the UI when the markdown input changes
//     _markdownController.addListener(() {
//       setState(() {});
//     });
//   }
//
//   void _initializeSelectedMenus() {
//     if (widget.passedSubMenuCode != null) {
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
//   void didUpdateWidget(PostMarkDownWrite oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     if (widget.passedSubMenuCode != oldWidget.passedSubMenuCode) {
//       _initializeSelectedMenus();
//     }
//   }
//
//   List<String> getMenuOptions() {
//     List<String> menuOptions = [];
//     for (var subMenus in subMenusList) {
//       String menuDisplayName = subMenus[0][0];
//       menuOptions.add(menuDisplayName);
//     }
//     return menuOptions;
//   }
//
//   List<String> getSubMenus(String selectedMenu) {
//     for (var subMenus in subMenusList) {
//       String menuDisplayName = subMenus[0][0];
//       if (menuDisplayName == selectedMenu) {
//         return subMenus.skip(1).map((item) => item[0]).toList();
//       }
//     }
//     return [];
//   }
//
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
//   String getBoardIdFromSubMenuCode(String subMenuCode) {
//     for (var subMenus in subMenusList) {
//       for (var item in subMenus) {
//         if (item[1] == subMenuCode) {
//           return item[2];
//         }
//       }
//     }
//     return '';
//   }
//
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
//   void _handleSubmit(UserProvider userProvider) async {
//     if (_formKey.currentState!.validate()) {
//       String? accessToken = userProvider.accessToken;
//       int id = userProvider.id;
//       String? board = subMenuId;
//       String title = _titleController.text;
//       String content = _markdownController.text;
//
//       if (accessToken != null) {
//         const String url = "https://terraforming.info/";
//         try {
//           final response = await Dio().post(
//             url,
//             options: Options(
//               headers: {
//                 'Content-Type': 'application/json; charset=UTF-8',
//                 'Authorization': 'Bearer $accessToken',
//               },
//             ),
//             data: jsonEncode(<String, dynamic>{
//               'user_id': id,
//               "board_id": board ?? '',
//               'title': title,
//               'content': content,
//             }),
//           );
//
//           if (response.statusCode == 200) {
//             _titleController.clear();
//             _markdownController.clear();
//
//             if (kIsWeb) {
//               context.go('/nwn/notice', extra: UniqueKey());
//               refreshNotifier.value++;
//             } else {
//               Navigator.of(context).push(MaterialPageRoute(
//                 builder: (BuildContext context) =>
//                 const Notice(
//                   label: 'News',
//                   detailPath: '/nwn/notice',
//                 ),
//               ));
//             }
//           } else {
//             print('데이터 전송 실패');
//           }
//         } catch (error) {
//           print('데이터 전송 중 오류 발생: $error');
//         }
//       } else {
//         print('액세스 토큰이 없습니다.');
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//
//     return Scaffold(
//       appBar: BaseAppBar(
//         title: "글작성 페이지",
//         appBar: AppBar(),
//       ),
//       body: Column(
//         children: [
//           Form(
//             key: _formKey,
//             child: Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.all(16),
//                 children: <Widget>[
//                   DropdownButtonFormField<String>(
//                     value: selectedMenu,
//                     hint: const Text('메뉴 선택'),
//                     onChanged: (newValue) {
//                       setState(() {
//                         selectedMenu = newValue;
//                         subMenus = getSubMenus(selectedMenu!);
//                         selectedSubMenu = null;
//                         subMenuId = null;
//                       });
//                     },
//                     items: menuOptions.map((menu) {
//                       return DropdownMenuItem(
//                         value: menu,
//                         child: Text(menu),
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 16),
//                   DropdownButtonFormField<String>(
//                     value: selectedSubMenu,
//                     hint: const Text('게시판 선택'),
//                     onChanged: (newValue) {
//                       setState(() {
//                         selectedSubMenu = newValue;
//                         String subMenuCode = getSubMenuCode(selectedSubMenu ?? '');
//                         subMenuId = getBoardIdFromSubMenuCode(subMenuCode);
//                         var higherMenu = getHigherMenuFromSubMenuCode(subMenuCode);
//                         if (higherMenu.isNotEmpty) {
//                           selectedMenu = higherMenu['menuDisplayName'];
//                           subMenus = getSubMenus(selectedMenu!);
//                         }
//                       });
//                     },
//                     items: subMenus.map((board) {
//                       return DropdownMenuItem(
//                         value: board,
//                         child: Text(board),
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _titleController,
//                     decoration: const InputDecoration(labelText: '제목'),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return '제목을 입력해주세요';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _markdownController,
//                     maxLines: 15,
//                     decoration: const InputDecoration(
//                       hintText: '여기에 마크다운으로 글을 작성하세요...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text('미리보기'),
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                     ),
//                     child: MarkdownBody(data: _markdownController.text),
//                   ),
//                   const SizedBox(height: 16),
//                   Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       children: [
//                         SelectableText('작성자 ${userProvider.nickname}'),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: () => _handleSubmit(userProvider),
//                           child: const Text('작성하기'),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: const Text('취소하기'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       drawer: const BaseDrawer(),
//     );
//   }
// }
