import 'dart:convert';
import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../../../../model/BoardP.dart';
import '../../../../../util/date_util.dart';
import '../../../../../util/responsive_width.dart';

import '../../../../widget/appbar.dart';
import '../../../../widget/drawer.dart';
import '../../../../widget/floating_action_widget.dart';

/// 공지 게시판 화면
class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({
    required this.label,
    required this.detailPath,
    super.key,
  });

  final String label;
  final String detailPath;

  @override
  State<StatefulWidget> createState() => NoticeListScreenState();
}

class NoticeListScreenState extends State<NoticeListScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>(); // Scaffold 키
  Future<List<BoardP>>? _boardList; // 게시판 데이터 로드 Future
  final int itemsPerPage = 15; // 한 페이지당 표시할 항목 수
  int totalItems = 0; // 전체 항목 수
  int currentPage = 0; // 현재 페이지 번호

  @override
  void initState() {
    super.initState();
    _boardList = _getBoardList(); // 초기 게시판 데이터 로드
  }

  final String url = "https://api.cosmosx.co.kr/notice"; // 데이터 API URL

  /// 게시판 데이터 로드 함수
  Future<List<BoardP>> _getBoardList() async {
    try {
      final http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final List<BoardP> result = jsonDecode(res.body).map<BoardP>((data) => BoardP.fromJson(data)).toList();
        totalItems = result.length; // 전체 항목 수 저장
        return result;
      } else {
        throw Exception('Failed to load boards');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// 게시판 새로고침 함수
  Future<void> _refreshBoardList() async {
    setState(() {
      _boardList = _getBoardList();
    });
  }

  /// 화면 빌드 함수
  @override
  Widget build(BuildContext context) {
    final deviceWidth = ResponsiveWidth.getResponsiveWidth(context); // 화면 크기 계산
    return Scaffold(
      appBar: BaseAppBar(
        title: widget.label,
        appBar: AppBar(),
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: _refreshBoardList, // 스와이프 시 데이터 새로고침
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
            child: FutureBuilder<List<BoardP>>(
              future: _boardList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data != null) {
                  final NoticeListData = snapshot.data!;

                  totalItems = NoticeListData.length;
                  // 동적 페이지 번호 계산
                  int startPage = max(0, currentPage - 2);
                  int endPage = min(
                    (totalItems / itemsPerPage).ceil(),
                    startPage + 5, // 최대 5개 페이지 번호 표시
                  );

                  return Column(
                    children: [
                      const Text("공지/제휴 문의"),
                      SizedBox(width: ResponsiveWidth.getResponsiveWidth(context), child: const Divider(color: Colors.black54, thickness: 0.3)),
                      buildNoticeExpanded(deviceWidth, NoticeListData),
                      SizedBox(width: ResponsiveWidth.getResponsiveWidth(context), child: const Divider(color: Colors.black54, thickness: 0.3)),
                      buildNoticeRow(startPage, endPage),
                    ],
                  );
                }
                return const Center(child: Text('No data available'));
              },
            ),
          ),
        ),
      ),
      drawer: const BaseDrawer(),
      floatingActionButton: const NaviFloatingAction(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// 게시판 리스트 출력 위젯
  Expanded buildNoticeExpanded(double deviceWidth, List<BoardP> NoticeListData) {
    //Create a list that maps index to id
    // final mappedIds = NoticeListData
    //     .asMap()
    //     .entries
    //     .map((entry) => entry.value.id)
    //     .toList();
    // ID 목록 생성
    final mappedIds = NoticeListData.map((e) => e.id).toList();

    print('Mapped list: $mappedIds'); // Debugging: print mapped list

    return Expanded(
      child: SizedBox(
        // width: MediaQuery.of(context).size.width <= 450 ? deviceWidth : deviceWidth *0.9,
        width: ResponsiveWidth.getResponsiveWidth(context) * 0.99,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          child: ListView.separated(
            primary: false,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: min(
              itemsPerPage,
              NoticeListData.length - currentPage * itemsPerPage,
            ),
            itemBuilder: (BuildContext context, int index) {
              int itemIndex = (NoticeListData.length - 1) - (currentPage * itemsPerPage + index); // 내림차순으로 항목 계산
              int totalItemsCount = NoticeListData.length; // 내림차순으로 Notice로 검색된 항목 계산
              int listOrderNumber = totalItemsCount - (currentPage * itemsPerPage + index);
              final item = NoticeListData[index];

              return ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                // 내부 요소 간격 더욱 줄이기,
                contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                // 더 타이트하게 설정
                minTileHeight: -1,
                minVerticalPadding: -1,
                minLeadingWidth: 0,
                hoverColor: const Color(0x66D8BFD8),
                selected: false,
                // 선택 여부
                selectedColor: Colors.teal,
                focusColor: const Color(0xffD8BFD8),
                enabled: true,
                onTap: () {
                  final currentIndex = mappedIds.indexOf(item.id);
                  final extraData = {
                    'key': UniqueKey(),
                    'currentIndex': currentIndex,
                    'mappedIds': mappedIds,
                  };
                  // 상세 페이지 이동
                  String newPath = '${widget.detailPath}${NoticeListData[itemIndex].id}';
                  context.go(
                    newPath,
                    extra: ValueKey(extraData),
                  );
                  print('Extra Type: ${extraData.runtimeType}');
                  print('extraData : $extraData ');
                  print('indexOf(item.id as Set<int>) : $currentIndex ');
                  print('NoticeListData[itemIndex].id : ${NoticeListData[itemIndex].id}');
                },
                leading: SelectableText(
                  '$listOrderNumber', // 항목 번호
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${NoticeListData[itemIndex].title} ", overflow: TextOverflow.ellipsis, maxLines: 1, softWrap: false, style: Theme.of(context).textTheme.titleMedium),
                    DateUtil.formatDateCommentIcon(NoticeListData[itemIndex].created_at, iconSize: 10, textSize: 10, textColor: Colors.grey),
                  ],
                ),
                // subtitle: Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: <Widget>[
                    // SelectableText(
                    //   NoticeListData[itemIndex].nickname,
                    //   style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    //       color: Colors.black54,
                    //       fontSize: 10
                    //   ),
                    // ),
                    // Spacer(),
                    // Spacer(flex: 1,),
                //   ],
                // ),
                // trailing: Icon(
                //   Icons.account_circle,
                //   size: 30,
                //   color: Colors.grey.shade500,
                // ),
                // CircleAvatar(backgroundImage: NetworkImage(url)),
              );

              // return Container(
              //   padding: const EdgeInsets.all(1),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: <Widget>[
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: <Widget>[
              //           Row(
              //             mainAxisAlignment: MainAxisAlignment.start,
              //             children: <Widget>[
              //               SelectableText(
              //                 '$listOrderNumber', // 항목 번호
              //                 style: Theme.of(context).textTheme.titleSmall,
              //               ),
              //               Padding(
              //                 padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
              //                 child: Column(
              //                   crossAxisAlignment: CrossAxisAlignment.start,
              //                   children: <Widget>[
              //                     SizedBox(
              //                       width: ResponsiveWidth.getResponsiveWidth(context) * 0.6,
              //                       child: InkWell(
              //                         onTap: () {
              //                           final currentIndex = mappedIds.indexOf(item.id);
              //                           final extraData = {
              //                             'key': UniqueKey(),
              //                             'currentIndex': currentIndex,
              //                             'mappedIds': mappedIds,
              //                           };
              //                           // 상세 페이지 이동
              //                           String newPath = '${widget.detailPath}${NoticeListData[itemIndex].id}';
              //                           context.go(newPath,extra: ValueKey(extraData),);
              //                           print('Extra Type: ${extraData.runtimeType}');
              //                           print('extraData : $extraData ');
              //                           print('indexOf(item.id as Set<int>) : $currentIndex ');
              //                           print('NoticeListData[itemIndex].id : ${NoticeListData[itemIndex].id}');
              //
              //                         },
              //                         child: Align(
              //                           alignment: Alignment.centerLeft,
              //                           child: Text(
              //                             "${NoticeListData[itemIndex].title} ",
              //                             overflow: TextOverflow.ellipsis,
              //                             maxLines: 1,
              //                             softWrap: false,
              //                           ),
              //                         ),
              //                       ),
              //                     ),
              //                     SizedBox(
              //                       width: ResponsiveWidth.getResponsiveWidth(context) * 0.5,
              //                       child: Row(
              //                         mainAxisAlignment:
              //                         MainAxisAlignment.spaceBetween,
              //                         children: <Widget>[
              //                           SelectableText(
              //                             DateUtil.formatDate(
              //                                 NoticeListData[itemIndex].created_at),
              //                             style: Theme.of(context)
              //                                 .textTheme
              //                                 .labelSmall!
              //                                 .copyWith(
              //                               color: Colors.black54,
              //                               fontSize: 10,
              //                             ),
              //                           ),
              //                           SelectableText(
              //                             NoticeListData[itemIndex].nickname,
              //                             style: Theme.of(context)
              //                                 .textTheme
              //                                 .labelSmall!
              //                                 .copyWith(
              //                               color: Colors.black54,
              //                               fontSize: 10,
              //                             ),
              //                           ),
              //                         ],
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //             ],
              //           ),
              //           Column(
              //             children: <Widget>[
              //               SizedBox(
              //                 width: ResponsiveWidth.getResponsiveWidth(context) * 0.2,
              //                 child: Text(
              //                   "사진",
              //                   style: Theme.of(context)
              //                       .textTheme
              //                       .labelSmall!
              //                       .copyWith(color: Colors.black54),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // );
            },
            separatorBuilder: (BuildContext context, int index) => const Divider(),
          ),
        ),
      ),
    );
  }

  /// 하단 페이지 번호 출력 위젯
  Row buildNoticeRow(int startPage, int endPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: currentPage == 0
              ? null
              : () {
            setState(() {
              currentPage--;
            });
          },
        ),
        for (int i = startPage; i < endPage; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: SizedBox(
              width: ResponsiveWidth.getResponsiveWidth(context) * 0.1,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    currentPage = i; // 클릭된 페이지로 이동
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: currentPage == i ? Colors.blue.shade700 : Colors.black, // 현재 페이지 색상 강조
                  textStyle: TextStyle(
                    fontWeight: currentPage == i
                        ? FontWeight.bold // 선택된 페이지 볼드체
                        : FontWeight.normal, // 기본 텍스트
                  ),
                ),
                child: Text(
                  '${i + 1}', // 페이지 번호는 1부터 시작
                  style: TextStyle(
                    fontWeight: currentPage == i ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: currentPage == (totalItems / itemsPerPage).ceil() - 1
              ? null
              : () {
            setState(() {
              currentPage++;
            });
          },
        ),
      ],
    );
  }
}
