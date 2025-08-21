import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../util/date_util.dart';
import '../../util/responsive_width.dart';
import '../widget/appbar.dart';
import '../widget/drawer.dart';
import '../widget/floating_action_widget.dart';

/// 📝 **API에서 뉴스 데이터를 가져오는 함수**
Future<List<Map<String, dynamic>>> fetchNwnNewsList(int count) async {
  print("📢 [root_screen.dart] 뉴스 리스트 가져오는 중...");

  final response = await http.get(Uri.parse('https://api.cosmosx.co.kr/news')); // 실제 API URL로 변경
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    print("✅ [root_screen.dart] 뉴스 리스트 로드 완료 data: $data");

    // 데이터를 역순으로 정렬 (최신 뉴스가 앞에 오도록)
    final reversedData = data.reversed.toList();

    print("✅ [root_screen.dart] 뉴스 리스트 로드 완료 reversedData: $reversedData");

    final limitedCount = count < reversedData.length ? count : reversedData.length;

    // API 데이터 매핑 (각 글마다 index 포함)
    final newsList = List.generate(limitedCount, (index) => {
      'title': reversedData[index]['title'],
      'nickname': reversedData[index]['nickname'],
      'detailsPath': '/nwn/news/${reversedData[index]['id']}',
      // 'currentIndex': index,
      // 'mappedIds': data.map((item) => '/nwn/news/${item['id']}').toList(),
    });

    print("✅ [root_screen.dart] 뉴스 리스트 로드 완료: $newsList");
    return newsList;
  } else {
    print("❌ [root_screen.dart] 뉴스 데이터 가져오기 실패");
    return [];
  }
}

/// 📝 **API에서 자유게시판 데이터를 가져오는 함수**
Future<List<Map<String, dynamic>>> fetchCommFreeList(int count) async {
  print("💬 [root_screen.dart] 자유게시판 리스트 가져오는 중...");

  final response = await http.get(Uri.parse('https://api.cosmosx.co.kr/free')); // 실제 API URL로 변경
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);

    final limitedCount = count < data.length ? count : data.length;

    // API 데이터 매핑
    final commFreeList = List.generate(limitedCount, (index) => {
      'title': data[index]['title'],
      'nickname': data[index]['nickname'],
      'detailsPath': '/comm/free/${data[index]['id']}',
      'currentIndex': index,
      'mappedIds': data.map((item) => '/comm/free/${item['id']}').toList(),
    });

    print("✅ [root_screen.dart] 자유게시판 리스트 로드 완료: $commFreeList");
    return commFreeList;
  } else {
    print("❌ [root_screen.dart] 자유게시판 데이터 가져오기 실패");
    return [];
  }
}

/// 📝 **API에서 뉴스 데이터를 가져오는 함수**
Future<List<Map<String, dynamic>>> fetchNwnNoticeList(int count) async {
  print("📢 [root_screen.dart] 뉴스 리스트 가져오는 중...");

  final response = await http.get(Uri.parse('https://api.cosmosx.co.kr/notice')); // 실제 API URL로 변경
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    print("✅ [root_screen.dart] 뉴스 리스트 로드 완료 data: $data");

    // 데이터를 역순으로 정렬 (최신 뉴스가 앞에 오도록)
    final reversedData = data.reversed.toList();

    print("✅ [root_screen.dart] 뉴스 리스트 로드 완료 reversedData: $reversedData");

    final limitedCount = count < reversedData.length ? count : reversedData.length;

    // API 데이터 매핑 (각 글마다 index 포함)
    final newsList = List.generate(limitedCount, (index) => {
      'title': reversedData[index]['title'],
      'nickname': reversedData[index]['nickname'],
      'created_at': reversedData[index]['created_at'],
      'detailsPath': '/nwn1/notice/${reversedData[index]['id']}',
      // 'currentIndex': index,
      // 'mappedIds': data.map((item) => '/nwn/news/${item['id']}').toList(),
    });

    print("✅ [root_screen.dart] 뉴스 리스트 로드 완료: $newsList");
    return newsList;
  } else {
    print("❌ [root_screen.dart] 뉴스 데이터 가져오기 실패");
    return [];
  }
}

/// 📌 **메인 페이지**
class RootScreen extends StatefulWidget {
  const RootScreen({
    required this.label,
    required this.detailsPath,
    super.key,
  });

  final String label;
  final String detailsPath;

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  PageController? _pageController;
  Timer? _timer;

  @override
  void dispose() {
    _pageController?.dispose();
    _timer?.cancel();
    print("❌ [root_screen.dart] RootScreen 해제됨");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("🖥️ [root_screen.dart] RootScreen 빌드 실행됨");
    return Scaffold(
      appBar: BaseAppBar(
        title: "COSMOSX",
        appBar: AppBar(),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: ResponsiveWidth.getResponsiveWidth(context),
            child: Column(
              children: <Widget>[
                const Padding(padding: EdgeInsets.all(2)),
                SelectableText(
                  '반갑습니다',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Padding(padding: EdgeInsets.all(2)),
                // 이미지 슬라이더
                const PageViewSlider(), // ✅ 분리한 PageView 위젯 사용

                const SizedBox(height: 35),

                // 뉴스 리스트
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchNwnNewsList(5),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    print("📰 [root_screen.dart] snapshot: ${snapshot.data}");

                    // final reversedNewsList = snapshot.data!.reversed.toList();
                    // print("📰 [root_screen.dart] reversedNewsList: $reversedNewsList");

                    return Column(
                      children: [
                        Column(
                          children: [
                            SelectableText(
                              "📢 최신 뉴스",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Align(
                              alignment: Alignment.centerRight, // ✅ 아이콘을 오른쪽 끝으로 정렬
                              child: GestureDetector(
                                onTap: () {
                                  print("📢 최신 뉴스 아이콘 클릭됨!");
                                  context.go('/nwn/news'); // ✅ 이동할 경로 지정
                                },
                                child: Icon(
                                  Icons.list_alt,
                                  size: 20,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final newspost = snapshot.data![index]; // 역순으로 가져옴
                            // print("📰 [root_screen.dart] 뉴스 아이템 로드됨: ${newspost['title']} by ${newspost['nickname']}");
                            print("📰 [root_screen.dart] 뉴스 아이템 로드됨---: ${newspost}");

                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact, // 내부 요소 간격 더욱 줄이기,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0), // 더 타이트하게 설정
                              title: Text(newspost['title']!,overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,style: TextStyle(fontSize: 14),),
                              subtitle: Row(
                                children: [
                                  Icon(Icons.account_circle,size: 10,color: Colors.grey.shade500,),
                                  SelectableText(" ${newspost['nickname']}",style: TextStyle(fontSize: 10),),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue.shade200),
                              onTap: () {
                                print("📜 [root_screen.dart] 뉴스 클릭됨: ${newspost['title']}");
                                context.go(newspost['detailsPath']!, extra: {
                                  'currentIndex': newspost['currentIndex'],
                                  'mappedIds': newspost['mappedIds'],
                                });
                              },
                            );
                          },
                          separatorBuilder: (context, index) => Divider(color: Colors.grey.shade300, height: 1.0),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 35),

                // 자유게시판 리스트
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchCommFreeList(5),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    // 리스트를 역순으로 정렬
                    // final reversedFreeList = snapshot.data!.reversed.toList();

                    return Column(
                      children: [
                        Column(
                          children: [
                            SelectableText(
                              "💬 자유게시판",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Align(
                              alignment: Alignment.centerRight, // ✅ 아이콘을 오른쪽 끝으로 정렬
                              child: GestureDetector(
                                onTap: () {
                                  print("📢 자유게시판 아이콘 클릭됨!");
                                  context.go('/comm/free'); // ✅ 이동할 경로 지정
                                },
                                child: Icon(
                                  Icons.list_alt,
                                  size: 20,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Text("💬 자유게시판", style: Theme.of(context).textTheme.titleLarge),
                        // ),
                        const Divider(),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final freepost = snapshot.data![index]; // 역순으로 가져옴
                            print("💬 [root_screen.dart] 자유게시판 아이템 로드됨: ${freepost['title']} by ${freepost['nickname']}");
                            //ㅇㅇㅇㅇㅇㅇ

                            return ListTile(
                              // shape: Border(
                              //   top: BorderSide(color: Colors.grey.shade300, width: 0.5),  // 위쪽 선
                              //   bottom: BorderSide(color: Colors.grey.shade300, width: 0.5), // 아래쪽 선
                              // ),
                              dense: true,
                              visualDensity: VisualDensity.compact, // 내부 요소 간격 더욱 줄이기,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0), // 더 타이트하게 설정
                              title: Text(freepost['title']!,overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,),
                              subtitle: Row(
                                children: [
                                  Icon(Icons.account_circle,size: 10,color: Colors.grey.shade500,),
                                  SelectableText(" ${freepost['nickname']}",style: TextStyle(fontSize: 10),),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue.shade200),
                              onTap: () {
                                print("💬 [root_screen.dart] 자유게시판 글 클릭됨: ${freepost['title']}");
                                context.go(freepost['detailsPath']!, extra: {
                                  'currentIndex': freepost['currentIndex'],
                                  'mappedIds': freepost['mappedIds'],
                                });
                              },
                            );
                          },
                          separatorBuilder: (context, index) => Divider(color: Colors.grey.shade300, height: 1.0),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 35),

                // 공지 리스트
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchNwnNoticeList(5),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    print("📰 [root_screen.dart] snapshot: ${snapshot.data}");

                    // final reversedNewsList = snapshot.data!.reversed.toList();
                    // print("📰 [root_screen.dart] reversedNewsList: $reversedNewsList");

                    return Column(
                      children: [
                        Column(
                          children: [
                            SelectableText(
                              "📜 공지사항",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Align(
                              alignment: Alignment.centerRight, // ✅ 아이콘을 오른쪽 끝으로 정렬
                              child: GestureDetector(
                                onTap: () {
                                  print("📢 공지사항 아이콘 클릭됨!");
                                  context.go('/nwn1/notice'); // ✅ 이동할 경로 지정
                                },
                                child: Icon(
                                  Icons.list_alt,
                                  size: 20,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final noticepost = snapshot.data![index]; // 역순으로 가져옴
                            // print("📰 [root_screen.dart] 뉴스 아이템 로드됨: ${noticepost['title']} by ${noticepost['nickname']}");
                            print("📰 [root_screen.dart] 공지사항 아이템 로드됨---: ${noticepost}");

                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact, // 내부 요소 간격 더욱 줄이기,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0), // 더 타이트하게 설정
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(noticepost['title']!,overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,style: TextStyle(fontSize: 14),),
                                  SelectableText(DateUtil.formatDate(noticepost['created_at']), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                ],
                              ),
                              // subtitle: Row(
                              //   children: [
                              //     Icon(Icons.account_circle,size: 10,color: Colors.grey.shade500,),
                              //     Text(" ${noticepost['nickname']}",style: TextStyle(fontSize: 10),),
                              //   ],
                              // ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue.shade200),
                              onTap: () {
                                print("📜 [root_screen.dart] 공지사항 클릭됨: ${noticepost['title']}");
                                print("📜 [root_screen.dart] 공지사항 게시글 클릭됨 detailsPath111: ${noticepost['detailsPath']}");
                                context.go(noticepost['detailsPath']!, extra: {
                                  'currentIndex': noticepost['currentIndex'],
                                  'mappedIds': noticepost['mappedIds'],
                                });
                              },
                            );
                          },
                          separatorBuilder: (context, index) => Divider(color: Colors.grey.shade300, height: 1.0),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
                Container(
                  // color: Colors.grey.shade200, // ✅ 배경색 추가 (연한 회색)
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 5), // 기존 패딩 유지
                  child: Column(
                    children: [
                      SelectableText(
                        "Copyright © 2024 COSMOSX Co. Ltd. All rights reserved",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Padding(padding: EdgeInsets.all(3)),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SelectableText(
                              "사이트 이용약관  ",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SelectableText(
                              "  개인정보처리방침",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: const BaseDrawer(),
      floatingActionButton: const NaviFloatingAction(),
    );
  }
}

/// ✅ **PageView 전용 위젯**
class PageViewSlider extends StatefulWidget {
  const PageViewSlider({super.key});

  @override
  _PageViewSliderState createState() => _PageViewSliderState();
}

class _PageViewSliderState extends State<PageViewSlider> {
  PageController? _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);

    //✅ 5초마다 페이지 변경 (PageView만 다시 로딩됨)
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      _currentPage = (_currentPage + 1) % 5;
      _pageController?.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      print("📸 [PageViewSlider] 이미지 슬라이드 변경: $_currentPage");
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: PageView(
        controller: _pageController,
        children: [
          Image.asset('poke/pics/etc/5.jpeg', fit: BoxFit.cover),
          Image.asset('poke/pics/etc/2.jpg', fit: BoxFit.cover),
          Image.asset('poke/pics/etc/1.png', fit: BoxFit.cover),
          Image.asset('poke/pics/etc/1234.jpg', fit: BoxFit.cover),
          Image.asset('poke/pics/etc/2.webp', fit: BoxFit.cover),
        ],
      ),
    );
  }
}





// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
// import '../widget/appbar.dart';
// import '../widget/drawer.dart';
//
// /// Widget for the root/initial pages in the bottom navigation bar.
// class RootScreen extends StatefulWidget {
//   /// Creates a RootScreen
//   const RootScreen({
//     required this.label,
//     required this.detailsPath,
//     super.key,
//   });
//
//   /// The label
//   final String label;
//   final String detailsPath;
//
//   @override
//   State<RootScreen> createState() => _RootScreenState();
// }
//
// class _RootScreenState extends State<RootScreen> {
//   late PageController _pageController;
//   late Timer _timer;
//   int _currentPage = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: _currentPage);
//
//     // 2초마다 페이지 넘기기 위한 타이머 설정
//     _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
//       if (_currentPage < 5) {
//         _currentPage++;
//       } else {
//         _currentPage = 0;
//       }
//
//       // _pageController.animateToPage(
//       //   _currentPage,
//       //   duration: const Duration(milliseconds: 300),
//       //   curve: Curves.easeInOut,
//       // );
//     });
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     _timer.cancel();
//     super.dispose();
//   }
//
//   /// 메인 페이지 내용
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: BaseAppBar(
//         title: "COSMOSX",
//         appBar: AppBar(),
//         // preferredHeight: 80.0,
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Text('250128_1 ${widget.label}',
//                   style: Theme.of(context).textTheme.titleLarge),
//               const Padding(padding: EdgeInsets.all(4)),
//
//               // New PageView added here
//               SizedBox(
//                 height: 100, // You can adjust the height as needed
//                 child: PageView(
//                   controller: _pageController,
//                   children: <Widget>[
//                     ClipRect(
//                       child: Align(
//                         alignment: Alignment.topCenter,
//                         heightFactor: 0.5,
//                         widthFactor: 1.0,
//                         child: Transform.translate(
//                           offset: const Offset(0.0, 0.1),
//                           child: Image.asset(
//                             'assets/pics/etc/5.jpeg',
//                             width: 1000,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Image.asset('assets/pics/etc/2.jpg', fit: BoxFit.cover),
//                     Image.asset('assets/pics/etc/1.png', fit: BoxFit.cover),
//                     Image.asset('assets/pics/etc/1234.jpg', fit: BoxFit.cover),
//                     Image.asset('assets/pics/etc/2.webp', fit: BoxFit.cover),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16), // Spacer between the PageView and other content
//
//               Center(
//                 child: Column(
//                   children: [
//                     ClipRect(
//                       child: Align(
//                         alignment: Alignment.topCenter,
//                         heightFactor: 0.4,
//                         widthFactor: 1.0,
//                         child: Transform.translate(
//                           offset: Offset(0.0, -0.5 * MediaQuery.of(context).size.height),
//                           child: Image.asset(
//                             'assets/pics/etc/3.jpg',
//                             width: 500,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Image.asset('assets/pics/etc/1234.jpg', fit: BoxFit.cover),
//                     Image.asset('assets/pics/etc/1.png', fit: BoxFit.cover),
//                     Image.asset('assets/pics/etc/2.webp', fit: BoxFit.cover),
//                     Image.asset('assets/pics/etc/5.jpeg', fit: BoxFit.cover),
//                   ],
//                 ),
//               ),
//
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   context.go(widget.detailsPath);
//                 },
//                 child: Text(
//                   'View details',
//                   style: Theme.of(context).textTheme.titleSmall,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       drawer: const BaseDrawer(),
//     );
//   }
// }
//
// /// The details screen for either the A or B screen.
// class DetailsScreen extends StatefulWidget {
//   /// Constructs a [DetailsScreen].
//   const DetailsScreen({
//     required this.label,
//     super.key,
//   });
//
//   /// The label to display in the center of the screen.
//   final String label;
//
//   @override
//   State<StatefulWidget> createState() => DetailsScreenState();
// }
//
// /// The state for DetailsScreen
// class DetailsScreenState extends State<DetailsScreen> {
//   int _counter = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Details Screen - ${widget.label}'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Text('Details for ${widget.label} - Counter: $_counter',
//                 style: Theme
//                     .of(context)
//                     .textTheme
//                     .titleLarge),
//             const Padding(padding: EdgeInsets.all(4)),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _counter++;
//                 });
//               },
//               child: const Text('Increment counter'),
//             ),
//           ],
//         ),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             const DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//               ),
//               child: Text('Drawer Header'),
//             ),
//             ListTile(
//               title: const Text('Item 11111'),
//               onTap: () => context.go('/a'),
//               // onTap: () {
//               //   Navigator.pop(context);
//               // },
//             ),
//             ListTile(
//               title: const Text('Item 2'),
//               onTap: () => context.go('/E'),
//               // onTap: () {
//               //   Navigator.pop(context);
//               // },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
