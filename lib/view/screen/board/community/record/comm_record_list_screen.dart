import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../provider/list_provider.dart';
import '../../../../../util/date_util.dart';
import '../../../../../util/responsive_width.dart';

import '../../../../widget/appbar.dart';
import '../../../../widget/drawer.dart';
import '../../../../widget/floating_action_widget.dart';

/// 실험 기록 게시판 화면
class RecordListScreen extends StatefulWidget {
  const RecordListScreen({
    required this.label,
    required this.detailPath,
    super.key,
  });

  final String label;
  final String detailPath;

  @override
  State<StatefulWidget> createState() => RecordListScreenState();
}

class RecordListScreenState extends State<RecordListScreen> {
  final int itemsPerPage = 15; // 한 페이지당 표시할 항목 수
  int totalItems = 0; // 전체 항목 수
  int currentPage = 0; // 현재 페이지 번호
  String baordname = "자료를 모아보자";

  @override
  void initState() {
    super.initState();
    // _loadBoardData();
    // 🔄 API에서 데이터를 가져옴
    Future.delayed(Duration.zero, () {
        Provider.of<ViewCountProvider>(context, listen: false).fetchPostDataFromAPI("record");
    });
  }

  final String url = "https://api.cosmosx.co.kr/record"; // 데이터 API URL

  /// 화면 빌드 함수
  @override
  Widget build(BuildContext context) {
    final viewCountProvider = Provider.of<ViewCountProvider>(context);
    final sortedPostData = viewCountProvider.getSortedPostData();
    final totalPosts = viewCountProvider.totalPosts;

    // 🔹 페이지에 맞는 데이터 필터링
    int startIndex = currentPage * itemsPerPage;
    int endIndex = min(startIndex + itemsPerPage, sortedPostData.length);
    final List<MapEntry<String, dynamic>> pageData = sortedPostData
        .sublist(startIndex, endIndex)
        .map((entry) => MapEntry(entry.key.toString(), entry.value))
        .toList();
    print("🔹 현재 페이지: $currentPage | 총 게시글 수: $totalPosts");
    print("📌 페이지 데이터 범위: $startIndex ~ $endIndex");
    print("📝 현재 페이지 데이터: ${pageData.map((e) => e.value['title']).toList()}");

    // final deviceWidth = ResponsiveWidth.getResponsiveWidth(context); // 화면 크기 계산
    return Scaffold(
      appBar: BaseAppBar(
        title: widget.label,
        appBar: AppBar(),
      ),
      body: Center(
        child: SizedBox(
          width: ResponsiveWidth.getResponsiveWidth(context) ,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
            child: Column(
              children: [
                Text(baordname),
                SizedBox(width: ResponsiveWidth.getResponsiveWidth(context), child: const Divider(color: Colors.black54, thickness: 0.3)),
                Expanded(
                  child: ListView.separated(
                    itemCount: pageData.length,
                    itemBuilder: (context, index) {
                      if (index >= sortedPostData.length) {
                        return const SizedBox(); // 🔄 인덱스 초과 에러 방지
                      }

                      // int itemIndex = (sortedPostData.length - 1) - (currentPage * itemsPerPage + index); // 내림차순으로 항목 계산
                      int totalItemsCount = sortedPostData.length; // 내림차순으로 Free로 검색된 항목 계산
                      int listOrderNumber = totalItemsCount - (currentPage * itemsPerPage + index);

                      // ✅ `pageData`에서 올바른 데이터 가져오기
                      final postId = pageData[index].key;
                      final postData = pageData[index].value;
                      final title = postData['title'];
                      final nickname = postData['nickname'];
                      final viewCount = postData['views'];
                      final date = postData['date'];
                      // // final id = postData['id'];

                      return Column(
                        children: [
                          ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            // 내부 요소 간격 더욱 줄이기,
                            contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                            // 더 타이트하게 설정
                            minTileHeight: -3,
                            minVerticalPadding: -3,
                            minLeadingWidth: 0,
                            hoverColor: const Color(0x66D8BFD8),
                            selected: false,
                            // 선택 여부
                            selectedColor: Colors.teal,
                            focusColor: const Color(0xffD8BFD8),
                            enabled: true,
                            onTap: () {
                              String newPath = '${widget.detailPath}${postId}';
                              // 🔹 현재 위젯이 트리에서 제거되지 않았는지 확인
                              if (!mounted) return;

                              context.go(newPath);
                              // context.go(
                              //   newPath,
                              // );
                            },
                            leading: SelectableText(
                              '$listOrderNumber', // 항목 번호
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                    child: Text("$title ",
                                        overflow: TextOverflow.ellipsis, maxLines: 1, softWrap: false,
                                        style: Theme.of(context).textTheme.titleMedium)),
                                const SizedBox(width: 5), // 제목과 조회수 간격 조절
                                SelectableText(
                                  "$viewCount",
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: const Color(0xff4C6EF5), fontSize: 12),),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                SelectableText(
                                  "$nickname",
                                  style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.black54, fontSize: 10),
                                ),
                                SelectableText(
                                  '     ${DateUtil.formatDate("$date")}',
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Colors.black54,
                                  ),
                                ),
                                Spacer(),
                                // Spacer(flex: 1,),
                              ],
                            ),
                            trailing: Icon(
                              Icons.account_circle,
                              size: 30,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          // SizedBox(width: ResponsiveWidth.getResponsiveWidth(context), child: const Divider(color: Colors.black54, thickness: 0.3)),
                        ],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                  ),
                ),
                SizedBox(width: ResponsiveWidth.getResponsiveWidth(context), child: const Divider(color: Colors.black54, thickness: 0.3)),
                buildRecordPageIndex(totalPosts),
              ],
            ),
          ),
        ),
      ),
      drawer: const BaseDrawer(),
      floatingActionButton: const NaviFloatingAction(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// ✅ **하단 페이지 번호 출력 위젯 (페이지네이션)**
  Widget buildRecordPageIndex(int totalItems) {
    int totalPages = max(1, (totalItems / itemsPerPage).ceil()); // 최소 1 페이지 유지
    int startPage = max(0, currentPage - 2); // 음수 방지
    int endPage = min(totalPages, startPage + 5); // 최대 페이지 범위 조정

    print("🔹 총 페이지: $totalPages, 현재 페이지: $currentPage");

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ◀️ 이전 페이지 버튼
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: currentPage > 0 // 첫 페이지에서는 비활성화
              ? () {
            setState(() {
              currentPage = max(0, currentPage - 1);
              print("⬅️ 이전 페이지 이동: $currentPage");
            });
          }
              : null,
        ),
        // 🔢 페이지 번호 버튼
        for (int i = startPage; i < endPage; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: SizedBox(
              width: ResponsiveWidth.getResponsiveWidth(context) * 0.1,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    currentPage = i.clamp(0, totalPages - 1);
                    print("🔢 페이지 선택: $currentPage");
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: currentPage == i ? Colors.blue.shade700 : Colors.black,
                  textStyle: TextStyle(
                    fontWeight: currentPage == i ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontWeight: currentPage == i ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        // ▶️ 다음 페이지 버튼
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: currentPage < totalPages - 1
              ? () {
            setState(() {
              currentPage = min(totalPages - 1, currentPage + 1);
              print("➡️ 다음 페이지 이동: $currentPage");
            });
          }
              : null,
        ),
      ],
    );
  }
}

//   /// 하단 페이지 번호 출력 위젯
//   Row buildRecordPageIndex(int startPage, int endPage) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: currentPage == 0
//               ? null
//               : () {
//                   setState(() {
//                     currentPage--;
//                   });
//                 },
//         ),
//         for (int i = startPage; i < endPage; i++)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 1.0),
//             child: SizedBox(
//               width: ResponsiveWidth.getResponsiveWidth(context) * 0.1,
//               child: TextButton(
//                 onPressed: () {
//                   setState(() {
//                     currentPage = i; // 클릭된 페이지로 이동
//                   });
//                 },
//                 style: TextButton.styleFrom(
//                   foregroundColor: currentPage == i ? Colors.blue.shade700 : Colors.black, // 현재 페이지 색상 강조
//                   textStyle: TextStyle(
//                     fontWeight: currentPage == i
//                         ? FontWeight.bold // 선택된 페이지 볼드체
//                         : FontWeight.normal, // 기본 텍스트
//                   ),
//                 ),
//                 child: Text(
//                   '${i + 1}', // 페이지 번호는 1부터 시작
//                   style: TextStyle(
//                     fontWeight: currentPage == i ? FontWeight.bold : FontWeight.normal,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         IconButton(
//           icon: const Icon(Icons.arrow_forward),
//           onPressed: currentPage == (totalItems / itemsPerPage).ceil() - 1
//               ? null
//               : () {
//                   setState(() {
//                     currentPage++;
//                   });
//                 },
//         ),
//       ],
//     );
//   }
// }













// import 'dart:convert';
// import 'dart:math';
// import 'dart:core';
//
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
//
// import '../../../../../model/BoardP.dart';
// import '../../../../../provider/list_provider.dart';
// import '../../../../../util/date_util.dart';
// import '../../../../../util/responsive_width.dart';
//
// import '../../../../widget/appbar.dart';
// import '../../../../widget/drawer.dart';
// import '../../../../widget/floating_action_widget.dart';
//
// /// 실험 기록 게시판 화면
// class RecordListScreen extends StatefulWidget {
//   const RecordListScreen({
//     required this.label,
//     required this.detailPath,
//     super.key,
//   });
//
//   final String label;
//   final String detailPath;
//
//   @override
//   State<StatefulWidget> createState() => RecordListScreenState();
// }
//
// class RecordListScreenState extends State<RecordListScreen> {
//   final scaffoldKey = GlobalKey<ScaffoldState>(); // Scaffold 키
//   Future<List<BoardP>>? _boardList; // 게시판 데이터 로드 Future
//   final int itemsPerPage = 15; // 한 페이지당 표시할 항목 수
//   int totalItems = 0; // 전체 항목 수
//   int currentPage = 0; // 현재 페이지 번호
//
//   @override
//   void initState() {
//     super.initState();
//     // _loadBoardData();
//     // 🔄 API에서 데이터를 가져옴
//     Future.microtask(() {
//       Provider.of<ViewCountProvider>(context, listen: false).fetchPostDataFromAPI();
//     });
//   }
//   //
//   // void _loadBoardData() {
//   //   setState(() {
//   //     _boardList = _getBoardList();
//   //   });
//   //
//   // //   // ✅ 페이지 들어오면 조회수 업데이트
//   // //   Future.delayed(const Duration(milliseconds: 10), () {
//   // //     Provider.of<ViewCountProvider>(context, listen: false).fetchViewCountsFromAPI();
//   // //   });
//   // }
//
//   final String url = "https://api.cosmosx.co.kr/record"; // 데이터 API URL
//
//   /// 게시판 데이터 로드 함수
//   Future<List<BoardP>> _getBoardList() async {
//     try {
//       final http.Response res = await http.get(Uri.parse(url));
//       if (res.statusCode == 200) {
//         final List<BoardP> result = jsonDecode(res.body).map<BoardP>((data) => BoardP.fromJson(data)).toList();
//         totalItems = result.length; // 전체 항목 수 저장
//         return result;
//       } else {
//         throw Exception('Failed to load boards');
//       }
//     } catch (e) {
//       print('Error: $e');
//       throw Exception('Network error: $e');
//     }
//   }
//
//   /// 게시판 새로고침 함수
//   Future<void> _refreshBoardList() async {
//     setState(() {
//       _boardList = _getBoardList();
//     });
//   }
//
//   /// 화면 빌드 함수
//   @override
//   Widget build(BuildContext context) {
//
//     final deviceWidth = ResponsiveWidth.getResponsiveWidth(context); // 화면 크기 계산
//     return Scaffold(
//       appBar: BaseAppBar(
//         title: widget.label,
//         appBar: AppBar(),
//       ),
//       body: Center(
//         child: RefreshIndicator(
//           onRefresh: _refreshBoardList, // 스와이프 시 데이터 새로고침
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
//             child: FutureBuilder<List<BoardP>>(
//               future: _boardList,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else if (snapshot.hasData && snapshot.data != null) {
//                   final RecordListData = snapshot.data!;
//
//                   totalItems = RecordListData.length;
//                   // 동적 페이지 번호 계산
//                   int startPage = max(0, currentPage - 2);
//                   int endPage = min(
//                     (totalItems / itemsPerPage).ceil(),
//                     startPage + 5, // 최대 5개 페이지 번호 표시
//                   );
//
//                   return Column(
//                     children: [
//                       const Text("끊임없는 도전과 기록 "),
//                       SizedBox(width: ResponsiveWidth.getResponsiveWidth(context), child: const Divider(color: Colors.black54, thickness: 0.3)),
//                       buildRecordExpanded(deviceWidth, RecordListData),
//                       SizedBox(width: ResponsiveWidth.getResponsiveWidth(context), child: const Divider(color: Colors.black54, thickness: 0.3)),
//                       buildRecordRow(startPage, endPage),
//                     ],
//                   );
//                 }
//                 return const Center(child: Text('No data available'));
//               },
//             ),
//           ),
//         ),
//       ),
//       drawer: const BaseDrawer(),
//       floatingActionButton: const NaviFloatingAction(),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }
//
//   /// 게시판 리스트 출력 위젯
//   Expanded buildRecordExpanded(double deviceWidth, List<BoardP> RecordListData) {
//     //Create a list that maps index to id
//     // final mappedIds = RecordListData
//     //     .asMap()
//     //     .entries
//     //     .map((entry) => entry.value.id)
//     //     .toList();
//     // ID 목록 생성
//     final mappedIds = RecordListData.map((e) => e.id).toList();
//     final viewCountProvider = Provider.of<ViewCountProvider>(context);
//
//     print('Mapped list: $mappedIds'); // Debugging: print mapped list
//
//     return Expanded(
//       child: SizedBox(
//         // width: MediaQuery.of(context).size.width <= 450 ? deviceWidth : deviceWidth *0.9,
//         width: ResponsiveWidth.getResponsiveWidth(context) * 0.99,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
//           child: ListView.separated(
//             primary: false,
//             scrollDirection: Axis.vertical,
//             shrinkWrap: true,
//             itemCount: min(
//               itemsPerPage,
//               RecordListData.length - currentPage * itemsPerPage,
//             ),
//             itemBuilder: (BuildContext context, int index) {
//               int itemIndex = (RecordListData.length - 1) - (currentPage * itemsPerPage + index); // 내림차순으로 항목 계산
//               int totalItemsCount = RecordListData.length; // 내림차순으로 Record로 검색된 항목 계산
//               int listOrderNumber = totalItemsCount - (currentPage * itemsPerPage + index);
//               final item = RecordListData[index];
//               // final viewCount = viewCountProvider.getViewCount(item.id) ?? item.views;
//               final sortedViewData = viewCountProvider.getSortedViewCounts();
//               // final postId = sortedViewData[index].key;
//               final viewCount = sortedViewData[index].value;
//
//
//               return ListTile(
//                 dense: true,
//                 visualDensity: VisualDensity.compact,
//                 // 내부 요소 간격 더욱 줄이기,
//                 contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
//                 // 더 타이트하게 설정
//                 minTileHeight: -3,
//                 minVerticalPadding: -3,
//                 minLeadingWidth: 0,
//                 hoverColor: const Color(0x66D8BFD8),
//                 selected: false,
//                 // 선택 여부
//                 selectedColor: Colors.teal,
//                 focusColor: const Color(0xffD8BFD8),
//                 enabled: true,
//                 onTap: () {
//                   final currentIndex = mappedIds.indexOf(item.id);
//                   final extraData = {
//                     'key': UniqueKey(),
//                     'currentIndex': currentIndex,
//                     'mappedIds': mappedIds,
//                   };
//                   // 상세 페이지 이동
//                   String newPath = '${widget.detailPath}${RecordListData[itemIndex].id}';
//                   context.go(
//                     newPath,
//                     extra: ValueKey(extraData),
//                   );
//                   print('Extra Type: ${extraData.runtimeType}');
//                   print('extraData : $extraData ');
//                   print('indexOf(item.id as Set<int>) : $currentIndex ');
//                   print('RecordListData[itemIndex].id : ${RecordListData[itemIndex].id}');
//                 },
//                 leading: SelectableText(
//                   '$listOrderNumber', // 항목 번호
//                   style: Theme.of(context).textTheme.titleSmall,
//                 ),
//                 title: Row(
//                   children: [
//                     Expanded(
//                         child: Text("${RecordListData[itemIndex].title} ",
//                             overflow: TextOverflow.ellipsis, maxLines: 1, softWrap: false,
//                             style: Theme.of(context).textTheme.titleMedium)),
//                     const SizedBox(width: 5), // 제목과 조회수 간격 조절
//                     SelectableText(
//                       '조회수: $viewCount',
//                       style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: const Color(0xff4C6EF5), fontSize: 12),
//                     ),
//                     SelectableText(
//                       (RecordListData[itemIndex].views ?? 0).toString(),
//                       style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: const Color(0xff4C6EF5), fontSize: 12),
//                     ),
//                   ],
//                 ),
//                 subtitle: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: <Widget>[
//                     SelectableText(
//                       RecordListData[itemIndex].nickname,
//                       style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.black54, fontSize: 10),
//                     ),
//                     SelectableText(
//                       '     ${DateUtil.formatDate(RecordListData[itemIndex].created_at)}',
//                       style: Theme.of(context).textTheme.titleSmall!.copyWith(
//                             color: Colors.black54,
//                           ),
//                     ),
//                     Spacer(),
//                     // Spacer(flex: 1,),
//                   ],
//                 ),
//                 trailing: Icon(
//                   Icons.account_circle,
//                   size: 30,
//                   color: Colors.grey.shade500,
//                 ),
//                 // CircleAvatar(backgroundImage: NetworkImage(url)),
//               );
//
//               // return Container(
//               //   padding: const EdgeInsets.all(1),
//               //   child: Column(
//               //     crossAxisAlignment: CrossAxisAlignment.start,
//               //     children: <Widget>[
//               //       Row(
//               //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //         children: <Widget>[
//               //           Row(
//               //             mainAxisAlignment: MainAxisAlignment.start,
//               //             children: <Widget>[
//               //               SelectableText(
//               //                 '$listOrderNumber', // 항목 번호
//               //                 style: Theme.of(context).textTheme.titleSmall,
//               //               ),
//               //               Padding(
//               //                 padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
//               //                 child: Column(
//               //                   crossAxisAlignment: CrossAxisAlignment.start,
//               //                   children: <Widget>[
//               //                     SizedBox(
//               //                       width: ResponsiveWidth.getResponsiveWidth(context) * 0.6,
//               //                       child: InkWell(
//               //                         onTap: () {
//               //                           final currentIndex = mappedIds.indexOf(item.id);
//               //                           final extraData = {
//               //                             'key': UniqueKey(),
//               //                             'currentIndex': currentIndex,
//               //                             'mappedIds': mappedIds,
//               //                           };
//               //                           // 상세 페이지 이동
//               //                           String newPath = '${widget.detailPath}${RecordListData[itemIndex].id}';
//               //                           context.go(newPath,extra: ValueKey(extraData),);
//               //                           print('Extra Type: ${extraData.runtimeType}');
//               //                           print('extraData : $extraData ');
//               //                           print('indexOf(item.id as Set<int>) : $currentIndex ');
//               //                           print('RecordListData[itemIndex].id : ${RecordListData[itemIndex].id}');
//               //
//               //                         },
//               //                         child: Align(
//               //                           alignment: Alignment.centerLeft,
//               //                           child: Text(
//               //                             "${RecordListData[itemIndex].title} ",
//               //                             overflow: TextOverflow.ellipsis,
//               //                             maxLines: 1,
//               //                             softWrap: false,
//               //                           ),
//               //                         ),
//               //                       ),
//               //                     ),
//               //                     SizedBox(
//               //                       width: ResponsiveWidth.getResponsiveWidth(context) * 0.5,
//               //                       child: Row(
//               //                         mainAxisAlignment:
//               //                         MainAxisAlignment.spaceBetween,
//               //                         children: <Widget>[
//               //                           SelectableText(
//               //                             DateUtil.formatDate(
//               //                                 RecordListData[itemIndex].created_at),
//               //                             style: Theme.of(context)
//               //                                 .textTheme
//               //                                 .labelSmall!
//               //                                 .copyWith(
//               //                               color: Colors.black54,
//               //                               fontSize: 10,
//               //                             ),
//               //                           ),
//               //                           SelectableText(
//               //                             RecordListData[itemIndex].nickname,
//               //                             style: Theme.of(context)
//               //                                 .textTheme
//               //                                 .labelSmall!
//               //                                 .copyWith(
//               //                               color: Colors.black54,
//               //                               fontSize: 10,
//               //                             ),
//               //                           ),
//               //                         ],
//               //                       ),
//               //                     ),
//               //                   ],
//               //                 ),
//               //               ),
//               //             ],
//               //           ),
//               //           Column(
//               //             children: <Widget>[
//               //               SizedBox(
//               //                 width: ResponsiveWidth.getResponsiveWidth(context) * 0.2,
//               //                 child: Text(
//               //                   "사진",
//               //                   style: Theme.of(context)
//               //                       .textTheme
//               //                       .labelSmall!
//               //                       .copyWith(color: Colors.black54),
//               //                 ),
//               //               ),
//               //             ],
//               //           ),
//               //         ],
//               //       ),
//               //     ],
//               //   ),
//               // );
//             },
//             separatorBuilder: (BuildContext context, int index) => const Divider(),
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// 하단 페이지 번호 출력 위젯
//   Row buildRecordRow(int startPage, int endPage) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: currentPage == 0
//               ? null
//               : () {
//                   setState(() {
//                     currentPage--;
//                   });
//                 },
//         ),
//         for (int i = startPage; i < endPage; i++)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 1.0),
//             child: SizedBox(
//               width: ResponsiveWidth.getResponsiveWidth(context) * 0.1,
//               child: TextButton(
//                 onPressed: () {
//                   setState(() {
//                     currentPage = i; // 클릭된 페이지로 이동
//                   });
//                 },
//                 style: TextButton.styleFrom(
//                   foregroundColor: currentPage == i ? Colors.blue.shade700 : Colors.black, // 현재 페이지 색상 강조
//                   textStyle: TextStyle(
//                     fontWeight: currentPage == i
//                         ? FontWeight.bold // 선택된 페이지 볼드체
//                         : FontWeight.normal, // 기본 텍스트
//                   ),
//                 ),
//                 child: Text(
//                   '${i + 1}', // 페이지 번호는 1부터 시작
//                   style: TextStyle(
//                     fontWeight: currentPage == i ? FontWeight.bold : FontWeight.normal,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         IconButton(
//           icon: const Icon(Icons.arrow_forward),
//           onPressed: currentPage == (totalItems / itemsPerPage).ceil() - 1
//               ? null
//               : () {
//                   setState(() {
//                     currentPage++;
//                   });
//                 },
//         ),
//       ],
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../../provider/list_provider.dart';
//
//
// class RecordListScreen extends StatefulWidget {
//   const RecordListScreen({super.key, required String label, required String detailPath});
//
//   @override
//   State<RecordListScreen> createState() => _RecordListScreenState();
// }
//
// class _RecordListScreenState extends State<RecordListScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // 🔄 API에서 데이터를 가져옴
//     Future.microtask(() {
//       Provider.of<ViewCountProvider>(context, listen: false).fetchPostDataFromAPI();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final viewCountProvider = Provider.of<ViewCountProvider>(context);
//     final sortedPostData = viewCountProvider.getSortedPostData();
//     final totalPosts = viewCountProvider.totalPosts;
//
//     // ✅ 리스트가 비어 있을 경우 대비
//     if (sortedPostData.isEmpty) {
//       return const Center(
//         child: CircularProgressIndicator(), // 🔄 로딩 중이면 인디케이터 표시
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: Text("실험 기록 게시판 (전체 글: $totalPosts)")), // 🔹 전체 글 수량 표시
//       body: ListView.builder(
//         itemCount: sortedPostData.length,
//         itemBuilder: (context, index) {
//           if (index >= sortedPostData.length) {
//             return const SizedBox(); // 🔄 인덱스 초과 에러 방지
//           }
//
//           final postId = sortedPostData[index].key;
//           final postData = sortedPostData[index].value;
//           final title = postData['title'];
//           final viewCount = postData['views'];
//           final date = postData['date'];
//
//           return ListTile(
//             title: Text("$title"),
//             subtitle: Text("ID: $postId  |  조회수: $viewCount  |  날짜: $date"),
//             onTap: () {
//               // 상세 페이지로 이동
//               Navigator.pushNamed(context, '/comm1/record/$postId');
//             },
//           );
//         },
//       ),
//     );
//   }
// }