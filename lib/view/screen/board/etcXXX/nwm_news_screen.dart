// import 'dart:convert';
// import 'dart:math';
// import 'dart:core';
// import 'package:universal_html/html.dart' as html;
//
//
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
//
// import '../../model/BoardP.dart';
// import '../../model/CommentP.dart';
// import '../../model/Model.dart';
// import '../../model/PostWithComments.dart';
// import '../../provider/user_provider.dart';
// import '../../util/date_util.dart';
// import '../../util/responsive_width.dart';
// import 'package:flutter_quill/flutter_quill.dart' as quill;
//
// import '../widget/appbar.dart';
// import '../widget/drawer.dart';
// import '../widget/floating_action_widget.dart';
//
// /// Widget for the root/initial pages in the bottom navigation bar.
// class NewsNoticeMain extends StatefulWidget {
//   const NewsNoticeMain({
//     required this.label,
//     required this.detailsPath,
//     super.key,
//   });
//
//   final String label;
//   final String detailsPath;
//
//   @override
//   State<NewsNoticeMain> createState() => NewsNoticeMainState();
// }
//
// class NewsNoticeMainState extends State<NewsNoticeMain> {
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//
//   /// 메인 페이지 내용
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: BaseAppBar(
//         title: "새소식",
//         appBar: AppBar(),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Text('Screen ${widget.label}',
//                 style: Theme.of(context).textTheme.titleLarge),
//             const Padding(padding: EdgeInsets.all(4)),
//             const Text('정해져있는 페이지로 자동 이동합니다'),
//           ],
//         ),
//       ),
//       drawer: const BaseDrawer(),
//     );
//   }
// }
//
// /// 공지사항 게시판
// class News extends StatefulWidget {
//   /// Constructs a [DetailsScreen].
//   const News({
//     required this.label,
//     required this.detailPath,
//     super.key,
//   });
//
//   /// The label to display in the center of the screen.
//   final String label;
//   final String detailPath;
//
//   @override
//   State<StatefulWidget> createState() => NewsState();
// }
//
// /// The state for DetailsScreen
// class NewsState extends State<News> {
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//   Future<List<BoardP>?>? _boardList;
//   final now = DateTime.now();
//   final int itemsPerPage = 20; // 페이지당 항목 수
//   int totalItems = 0; // 전체 항목 수
//   int currentPage = 0; // 현재 페이지 번호
//
//   @override
//   void initState() {
//     super.initState();
//     _boardList = _getBoardList();
//     print('initState initState');
//   }
//
//   final String url = "https://terraforming.info/news";
//
//   Future<List<BoardP>> _getBoardList() async {
//     try{
//     final http.Response res = await http.get(Uri.parse(url));
//     if (res.statusCode == 200) {
//       final List<BoardP> result = jsonDecode(res.body)
//           .map<BoardP>((data) => BoardP.fromJson(data))
//           .toList();
//       totalItems = result.length;
//       return result;
//     } else {
//       throw Exception('Failed to load boards');
//     }
//     } catch (e) {
//      print('Error: $e');
//      throw Exception('Network error: $e');
//    }
//   }
//
//   Future<void> _refreshBoardList() async {
//     setState(() {
//       _boardList = _getBoardList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final deviceWidth = ResponsiveWidth.getResponsiveWidth(context);
//     // print('width★★★★ : ${ResponsiveWidth.getResponsiveWidth(context)}');
//     int startPage = max(0, currentPage - 2);
//     int endPage = min((totalItems / itemsPerPage).ceil(), currentPage + 2);
//     return Scaffold(
//         appBar: BaseAppBar(
//           title: "새소식",
//           appBar: AppBar(),
//         ),
//         body: Center(
//           child: RefreshIndicator(
//             onRefresh: _refreshBoardList,
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: <Widget>[
//                   const Text("우주, 블록체인, 신기술 뉴스"),
//                   buildNewsExpanded(deviceWidth),
//                   buildNewsRow(startPage, endPage),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         drawer: const BaseDrawer(),
//         floatingActionButton: const NaviFloatingAction(),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }
//
//   //하단 작성글 보는 리스트
//   Expanded buildNewsExpanded(double deviceWidth) {
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
//         child: FutureBuilder(
//           future: _boardList,
//           builder: (context, snapshot) {
//             var newsData = snapshot.data;
//             if (snapshot.connectionState == ConnectionState.done) {
//               print('initState gggggggggggggggg');
//               if (snapshot.hasError) {
//                 return Center(
//                   child: SelectableText(
//                     '${snapshot.error} occurred nnnnnnnnnnnews',
//                     style: const TextStyle(fontSize: 18),
//                   ),
//                 ); // if we got our data
//               } else if (snapshot.hasData && snapshot.data != null) {
//                 print('FutureBuilder FutureBuilder');
//                 return SizedBox(
//                   width: MediaQuery.of(context).size.width <= 450 ? deviceWidth : deviceWidth *0.9,
//                   child: ListView.separated(
//                     primary: false,
//                     scrollDirection: Axis.vertical,
//                     shrinkWrap: true,
//                     itemCount: min(
//                       itemsPerPage,
//                       newsData!.length - currentPage * itemsPerPage,
//                     ),
//                     itemBuilder: (BuildContext context, int index) {
//                       int itemIndex = (newsData.length - 1) -
//                           (currentPage * itemsPerPage +
//                               index); // 내림차순으로 항목의 실제 인덱스 계산
//                       int totalItemsCount =
//                           newsData.length; // 내림차순으로 news로 검색된 인덱스 계산
//                       int listOrderNumber =
//                           totalItemsCount - (currentPage * itemsPerPage + index);
//
//                       return Container(
//                         padding: const EdgeInsets.all(1),
//
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: <Widget>[
//                                     SelectableText(
//                                       // "${NewsData![itemIndex].id} ",
//                                       '$listOrderNumber',
//                                       style: Theme.of(context).textTheme.titleSmall,
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: <Widget>[
//                                           SizedBox(
//                                             width: deviceWidth * 0.6,
//                                             child: InkWell(
//                                               onTap: () {
//                                                 String newPath =
//                                                     '${widget.detailPath}${newsData[itemIndex].id}';
//                                                 // '${widget.detailPath}?itemIndex=${newsData![itemIndex].id}';
//                                                 context.go(newPath);
//                                               },
//                                               child: Align(
//                                                 alignment: Alignment.centerLeft,
//                                                 child: Text(
//                                                   "${newsData[itemIndex].title} ",
//                                                   overflow: TextOverflow.ellipsis,
//                                                   maxLines: 1,
//                                                   softWrap: false,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             width: deviceWidth * 0.5,
//                                             child: Row(
//                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                               children: <Widget>[
//                                                 SelectableText(
//                                                   // "${snapshot.data![index].created_at}",
//                                                   DateUtil.formatDate(
//                                                       newsData[itemIndex]
//                                                           .created_at),
//                                                   style: Theme.of(context)
//                                                       .textTheme
//                                                       .labelSmall!
//                                                       .copyWith(color: Colors.black54,
//                                                       fontSize: 10),
//                                                 ),
//                                                 SelectableText(
//                                                   snapshot
//                                                       .data![itemIndex].nickname,
//                                                   style: Theme.of(context)
//                                                       .textTheme
//                                                       .labelSmall!
//                                                       .copyWith(color: Colors.black54,
//                                                                  fontSize: 10),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Column(
//                                   children: <Widget>[
//                                     SizedBox(
//                                       width: deviceWidth * 0.2,
//                                       child: Text(
//                                         "사진",
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .labelSmall!
//                                             .copyWith(color: Colors.black54),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                     separatorBuilder: (BuildContext context, int index) =>
//                     const Divider(),
//                   ),
//                 );
//               }
//             }
//             return const Center(
//               child: CircularProgressIndicator(
//                 strokeWidth: 10,
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   //하단 페이지 숫자
//   Row buildNewsRow(int startPage, int endPage) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Expanded(
//           flex: 8,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: currentPage == 0
//                     ? null
//                     : () {
//                         setState(() {
//                           currentPage--;
//                         });
//                       },
//               ),
//               for (int i = startPage; i < endPage; i++)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 1.0),
//                   child: TextButton(
//                     onPressed: () {
//                       setState(() {
//                         currentPage = i;
//                       });
//                     },
//                     style: ButtonStyle(
//                       foregroundColor: MaterialStateProperty.resolveWith<Color>(
//                             (Set<MaterialState> states) {
//                           if (states.contains(MaterialState.hovered)) {
//                             return Colors.blue;
//                           }
//                           return Colors.black;
//                         },
//                       ),
//                     ),
//                     child: Text(
//                       '$i',
//                       style: Theme.of(context)
//                           .textTheme
//                           .labelSmall!
//                           .copyWith(color: Colors.black87,fontSize: 20),
//                     ),
//                   ),
//                 ),
//               IconButton(
//                 icon: const Icon(Icons.arrow_forward),
//                 onPressed: currentPage == (totalItems / itemsPerPage).ceil() - 1
//                     ? null
//                     : () {
//                         setState(() {
//                           currentPage++;
//                         });
//                       },
//               ),
//             ],
//           ),
//         ),
//         Expanded(flex: 1, child: Container())
//       ],
//     );
//   }
// }
//
// class NewsDetailsScreen extends StatefulWidget {
//   final String label;
//   final String? itemIndex;
//
//   const NewsDetailsScreen({
//     super.key,
//     required this.label,
//     this.itemIndex, // 옵셔널로 변경
//   });
//
//   @override
//   State<StatefulWidget> createState() => NewsDetailsScreenState();
// }
//
// /// The state for DetailsScreen
// class NewsDetailsScreenState extends State<NewsDetailsScreen> {
//   bool _isFloatingActionButtonVisible = true;
//
//   void _updateFloatingActionButtonVisibility(bool isVisible) {
//     setState(() {
//       _isFloatingActionButtonVisible = isVisible;
//     });
//     print("After update, _isFloatingActionButtonVisible: $_isFloatingActionButtonVisible");
//   }
//
//   Future<PostWithComments>? _NewsPostComment;
//
//   String constructUrl() {
//     // `widget.itemIndex` 또는 쿼리 파라미터를 사용하여 URL 구성
//     final itemIndex = widget.itemIndex ?? Uri.base.queryParameters['itemIndex'];
//     print("애스커다ㅏ아아아앙");
//     print(widget.itemIndex);
//     print(itemIndex);
//     print("애스커다ㅏ아아아앙");
//
//     if (itemIndex == null) {
//       throw Exception('No item index provided');
//     }
//     return "https://terraforming.info/news/$itemIndex";
//   }
//
//   Future<PostWithComments> _getNewsData() async {
//     final url = constructUrl();
//     final http.Response res = await http.get(Uri.parse(url));
//
//     if (res.statusCode != 200) {
//       throw Exception('Failed to load data from $url');
//     }
//
//     final jsonData = jsonDecode(res.body) as Map<String, dynamic>;
//     final post = Model.fromJson(jsonData['post']);
//     final comments = (jsonData['comments'] as List)
//         .map<CommentP>((data) => CommentP.fromJson(data))
//         .toList();
//
//     return PostWithComments(post: post, comments: comments);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _NewsPostComment = _getNewsData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: BaseAppBar(title: "새소식", appBar: AppBar()),
//       body: FutureBuilder<PostWithComments>(
//           future: _NewsPostComment,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState != ConnectionState.done) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (snapshot.hasError) {
//               return Center(
//                 child: Column(
//                   children: [
//                     SelectableText(
//                       '${snapshot.error} occurred111',
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                   ],
//                 ),
//               );
//             }
//             if (!snapshot.hasData || snapshot.data == null) {
//               return const Center(child: Text('No data available'));
//             }
//             var NewsData = snapshot.data?.post;
//             var commentData = snapshot.data!.comments;
//             final quillController = quill.QuillController(
//               document: quill.Document.fromJson(jsonDecode(NewsData!.content)),
//               selection: const TextSelection.collapsed(offset: 0),
//             );
//
//             return Column(
//               children: <Widget>[
//                 Expanded(
//                   child: ListView(
//                     children: <Widget>[
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(8, 50, 8, 8),
//                         child: Column(
//                           children: [
//                             SelectableText(
//                               NewsData.title,
//                               style: Theme.of(context).textTheme.displayMedium,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Column(
//                                 children: [
//                                   Column(
//                                     children: [
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceEvenly,
//                                         children: [
//                                           Row(
//                                             children: [
//                                               const Padding(
//                                                 padding: EdgeInsets.fromLTRB(
//                                                     8, 10, 8, 10),
//                                                 child: Icon(
//                                                   // Icons.add_chart,
//                                                   Icons.import_contacts_sharp,
//                                                   color: Colors.grey,
//                                                 ),
//                                               ),
//                                               Text('NO: ${NewsData.id}',
//                                                   style: const TextStyle(
//                                                       color: Colors.grey)),
//                                             ],
//                                           ),
//                                           SelectableText(
//                                               NewsData.nickname ??
//                                                   'No nickname',
//                                               style: const TextStyle(
//                                                   color: Colors.grey)),
//                                           Text(
//                                               DateUtil.formatDate(
//                                                   NewsData.created_at),
//                                               style: const TextStyle(
//                                                   color: Colors.grey)),
//                                         ],
//                                       ),
//                                       SizedBox(
//                                           width: ResponsiveWidth
//                                               .getResponsiveWidth(context),
//                                           child: const Divider(
//                                               color: Colors.black54,
//                                               thickness: 0.3)),
//                                       SizedBox(
//                                         width:
//                                             ResponsiveWidth.getResponsiveWidth(
//                                                 context),
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child:quill.QuillEditor.basic(
//                                             configurations: quill.QuillEditorConfigurations(
//                                               controller: quillController,
//                                               scrollable: true,
//                                               autoFocus: false,
//                                               showCursor: false,
//                                               expands: false,
//                                               padding: EdgeInsets.zero,
//                                               sharedConfigurations: const quill.QuillSharedConfigurations(
//                                                 locale: Locale('ko'),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(
//                                           width: ResponsiveWidth
//                                               .getResponsiveWidth(context),
//                                           child: const Divider(
//                                               color: Colors.black54,
//                                               thickness: 0.3)),
//                                       SizedBox(
//                                         width:
//                                             ResponsiveWidth.getResponsiveWidth(
//                                                 context),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.end,
//                                           children: <Widget>[
//                                             // 구글 로그인 버튼
//                                             Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: ElevatedButton(
//                                                 onPressed: () {
//                                                   // 구글 로그인 처리
//                                                 },
//                                                 child: const Text('구글'),
//                                               ),
//                                             ),
//                                             // 네이버 로그인 버튼
//                                             Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: ElevatedButton(
//                                                 onPressed: () {
//                                                   // 네이버 로그인 처리
//                                                 },
//                                                 child: const Text('네이버'),
//                                               ),
//                                             ),
//                                             // 카카오톡 로그인 버튼
//                                             Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: OutlinedButton(
//                                                 onPressed: () {
//                                                   // 카카오톡 로그인 처리
//                                                 },
//                                                 child: const Text('카톡'),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: _newsbuildCommentListNews(
//                           commentData: commentData,
//                           itemIndex: widget.itemIndex,
//                           updateVisibility:
//                               _updateFloatingActionButtonVisibility,
//                         ),
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.only(bottom: 50),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           }),
//       drawer: const BaseDrawer(),
//       floatingActionButton:
//           _isFloatingActionButtonVisible ? const NaviFloatingAction() : null,
//       floatingActionButtonLocation: _isFloatingActionButtonVisible
//           ? FloatingActionButtonLocation.endFloat
//           : FloatingActionButtonLocation.endFloat, // Adjust as needed//
//     );
//   }
// }
//
// // ignore: camel_case_types
// class _newsbuildCommentListNews extends StatefulWidget {
//   final Function(bool) updateVisibility;
//   final List<CommentP> commentData;
//   final String? itemIndex;
//
//   const _newsbuildCommentListNews({
//     required this.commentData,
//     required this.itemIndex,
//     required this.updateVisibility,
//   });
//
//   @override
//   State<_newsbuildCommentListNews> createState() => _newsbuildCommentListNewsState();
// }
//
// class _newsbuildCommentListNewsState extends State<_newsbuildCommentListNews> {
//   final FocusNode _newscommentFocusNode = FocusNode();
//   final Map<int, FocusNode> _newsreplyFocusNodes = {};
//   final TextEditingController _newsnewCommentController =
//   TextEditingController(); // 새 댓글을 위한 컨트롤러
//   final Map<int, TextEditingController> _newsreplyControllers = {};
//   final Map<int, bool> _newsshowReplyField = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _newscommentFocusNode.addListener(_handleFocusChange);
//   }
//
//   @override
//   void dispose() {
//     _newscommentFocusNode.removeListener(_handleFocusChange);
//     _newscommentFocusNode.dispose();
//     _newsreplyFocusNodes.forEach((key, focusNode) {
//       focusNode.removeListener(_handleFocusChange);
//       focusNode.dispose();
//     });
//     super.dispose();
//   }
//
//   void _handleFocusChange() {
//     if (_newscommentFocusNode.hasFocus ||
//         _newsreplyFocusNodes.values.any((focusNode) => focusNode.hasFocus)) {
//       widget.updateVisibility(false);
//     } else {
//       widget.updateVisibility(true);
//     }
//   }
//
//   String constructUrl() {
//     final itemIndex = widget.itemIndex ?? Uri.base.queryParameters['itemIndex'];
//     if (itemIndex == null) {
//       throw Exception('No item index provided');
//     }
//     return "https://terraforming.info/news/$itemIndex";
//   }
//
//   Future<void> _sendComment(String content,
//       {int? parent_comment_id, int? parent_comment_order}) async {
//     final String url = constructUrl();
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     final accessToken = userProvider.accessToken;
//     int id = userProvider.id;
//
//     int calculateParentCommentOrder(int? parentCommentOrder) {
//       if (parentCommentOrder == null) {
//         return 0;
//       } else if (parentCommentOrder == 0) {
//         return 1;
//       } else if (parentCommentOrder == 1) {
//         return 2;
//       } else {
//         return parentCommentOrder > 2 ? 2 : parentCommentOrder;
//       }
//     }
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
//           'post_id': widget.itemIndex ?? Uri.base.queryParameters['itemIndex'],
//           'comment_content': content,
//           'parent_comment_id': parent_comment_id,
//           'parent_comment_order': calculateParentCommentOrder(parent_comment_order),
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         if (kIsWeb) {
//           html.window.location.reload();
//         } else {
//           Navigator.of(context).pushReplacement(MaterialPageRoute(
//             builder: (BuildContext context) => NewsDetailsScreen(
//               label: 'NewsSSSSSSSSS',
//               itemIndex: widget.itemIndex,
//             ),
//           ));
//         }
//       } else {
//         print('코멘트 응답 에러');
//       }
//     } catch (e) {
//       print('코멘트 에러 내용: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<CommentP> primaryComments = [];
//     Map<int, List<CommentP>> replyComments = {};
//
//     for (var comment in widget.commentData) {
//       if (comment.parent_comment_id == null) {
//         primaryComments.add(comment);
//         print('2aaaaaaaaaaaaaaaaa==============$comment');
//         replyComments[comment.comment_id] = [];
//       } else {
//         replyComments[comment.parent_comment_id]?.add(comment);
//       }
//     }
//
//     return Padding(
//       padding: const EdgeInsets.all(4.0),
//       child: SizedBox(
//         width: ResponsiveWidth.getResponsiveWidth(context),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(4.0),
//               child: Column(
//                 children: [
//                   SizedBox(
//                     width: ResponsiveWidth.getResponsiveWidth(context),
//                     child: TextFormField(
//                       focusNode: _newscommentFocusNode,
//                       controller: _newsnewCommentController,
//                       decoration: InputDecoration(
//                         isDense: true,
//                         hintText: '댓글을 작성하세요',
//                         border: const OutlineInputBorder(),
//                         suffixIcon: IconButton(
//                           icon: const Icon(Icons.add),
//                           onPressed: () {
//                             dynamic text = _newsnewCommentController.text.trim();
//                             if (text.isNotEmpty) {
//                               _sendComment(text);
//                               _newsnewCommentController.clear();
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                       content: Text('댓글을 입력해주세요.')));
//                             }
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ...primaryComments.map((comment) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   buildComment(comment),
//                   ...?replyComments[comment.comment_id]?.map(buildComment),
//                 ],
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildComment(CommentP comment) {
//     double paddingValue = ((comment.parent_comment_order ?? 0) + 1) * 19;
//     final deviceWidth = ResponsiveWidth.getResponsiveWidth(context);
//     _newsreplyFocusNodes[comment.comment_id] ??= FocusNode()..addListener(_handleFocusChange);
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(1, 0, 4, 5),
//       child: SizedBox(
//         width: ResponsiveWidth.getResponsiveWidth(context),
//         child: Padding(
//           padding: EdgeInsets.fromLTRB(
//             paddingValue < 20 ? 8.0 : (paddingValue > 38 ? 24.0 : 16.0),
//             paddingValue < 20 ? 16.0 : 0,
//             paddingValue < 20 ? 0 : 0,
//             paddingValue < 20 ? 0 : 0,
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border(
//                 left: BorderSide(
//                     color: const Color(0x8bd7d7d7),
//                     width: paddingValue < 20 ? 10.0 : 3.0),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   // padding: EdgeInsets.symmetric(horizontal: paddingValue * 0.3),
//                   padding: EdgeInsets.only(left: paddingValue * 0.3),
//                   child: Row(
//                     children: [
//                       buildIcon(paddingValue),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                         child: SelectableText(
//                             comment.comment_author_nickname ?? 'No nickname',
//                             style: const TextStyle(
//                                 color: Colors.grey, fontSize: 14)),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                         child: SelectableText(
//                             DateUtil.formatDate(comment.comment_created_at),
//                             style: const TextStyle(
//                                 color: Colors.grey, fontSize: 14)),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.subdirectory_arrow_left_outlined,
//                             color: Colors.grey, size: 10),
//                         visualDensity: const VisualDensity(horizontal: 0),
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         onPressed: () {
//                           setState(() {
//                             print('222323333333==============${comment.comment_id}');
//                             bool currentFieldState =
//                             !(_newsshowReplyField[comment.comment_id] ?? false);
//                             _newsshowReplyField.clear();
//                             _newsshowReplyField[comment.comment_id] = currentFieldState;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(bottom:0,left: paddingValue * 0.3),
//                   child: SelectableText(comment.comment_content,style: const TextStyle(fontSize: 14),),
//                 ),
//                 if (_newsshowReplyField[comment.comment_id] ?? false)
//                   Padding(
//                     padding: EdgeInsets.only(top: 8.0, left: paddingValue * 0.3),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: SizedBox(
//                         width: deviceWidth * 0.8,
//                         child: TextFormField(
//                           focusNode: _newsreplyFocusNodes[comment.comment_id],
//                           controller: _newsreplyControllers[comment.comment_id] ??=
//                               TextEditingController(
//                                   text: '@${comment.comment_author_nickname} '),
//                           decoration: InputDecoration(
//                             contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 1.0, horizontal: 5.0),
//                             isDense: true,
//                             hintText: '대댓글을 작성하세요',
//                             border: const OutlineInputBorder(),
//                             suffixIcon: IconButton(
//                               icon: const Icon(Icons.add),
//                               onPressed: () {
//                                 String text =
//                                     _newsreplyControllers[comment.comment_id]
//                                         ?.text
//                                         .trim() ??
//                                         '';
//                                 String actualText = text
//                                     .replaceAll('',
//                                     // '@${comment.comment_author_nickname}',
//                                     '')
//                                     .trim();
//
//                                 if (actualText.isNotEmpty) {
//                                   int? calculateParentCommentId;
//                                   if (comment.parent_comment_order == 0) {
//                                     calculateParentCommentId =
//                                         comment.comment_id;
//                                   } else {
//                                     calculateParentCommentId =
//                                         comment.parent_comment_id;
//                                   }
//                                   _sendComment(
//                                     text,
//                                     parent_comment_id: calculateParentCommentId,
//                                     parent_comment_order:
//                                     comment.parent_comment_order,
//                                   );
//                                   _newsreplyControllers[comment.comment_id]
//                                       ?.clear();
//                                 } else {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                           content: Text('대 댓글을 입력해주세요.')));
//                                 }
//                               },
//                             ),
//                           ),
//                           style: const TextStyle(fontSize: 13), // 폰트 크기 설정
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildIcon(double paddingValue) {
//     IconData iconData;
//     if (paddingValue < 20) {
//       iconData = Icons.account_circle;
//     } else {
//       iconData = Icons.arrow_upward;
//     }
//     return Icon(iconData, color: Colors.grey, size: 15);
//   }
// }
