import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewCountProvider with ChangeNotifier {
  final Map<int, Map<String, dynamic>> _postData = {}; // 🔹 게시글 정보 저장
  int _totalPosts = 0; // 🔹 전체 글 수량 저장

  /// 🔄 특정 게시글의 조회수 가져오기
  int getViewCount(int postId) => _postData[postId]?['views'] ?? 0;

  /// 🔄 특정 게시글의 제목 가져오기
  String getTitle(int postId) => _postData[postId]?['title'] ?? '제목 없음';

  /// 🔄 특정 게시글의 닉네임 가져오기
  String getNickname(int postId) => _postData[postId]?['nickname'] ?? '별칭잇음';

  /// 🔄 특정 게시글의 날짜 가져오기
  String getDate(int postId) => _postData[postId]?['date'] ?? '날짜 없음';

  /// 🔄 전체 글 수량 가져오기
  int get totalPosts => _totalPosts;

  /// 🔄 특정 게시글 정보 업데이트
  void updatePostData(int postId, Map<String, dynamic> newData) {
    if (_postData[postId] != newData) {
      _postData[postId] = newData;
      notifyListeners(); // 🔄 UI 갱신
    }
  }

  /// 🔄 API에서 전체 게시글 정보 가져오기 (리스트 페이지 진입 시 실행)
  Future<void> fetchPostDataFromAPI(String boardName) async {
    try {
      final response = await http.get(Uri.parse("https://api.cosmosx.co.kr/$boardName/"));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as List<dynamic>;
        final reversedData = jsonData.reversed.toList(); // 🔄 역순 정렬

        _postData.clear(); // 기존 데이터 초기화
        for (var item in reversedData) {
          _postData[item['id']] = {
            // 'id': item['id'], // 아아디
            'title': item['title'], // 제목
            'views': item['views'], // 조회수
            'nickname': item['nickname'], // 조회수
            'date': item['created_at'], // 생성 날짜
          };
        }

        _totalPosts = jsonData.length; // 🔄 전체 글 수량 업데이트
        notifyListeners(); // 🔄 UI 업데이트
      }
    } catch (e) {
      print('게시글 정보 업데이트 실패: $e');
    }
  }

  /// 🔄 ID 기준으로 정렬된 데이터 반환 (내림차순)
  List<MapEntry<int, Map<String, dynamic>>> getSortedPostData() {
    return _postData.entries.toList()..sort((a, b) => b.key.compareTo(a.key));
  }

  /// ✅ 글 작성 시 데이터 추가
  void addPost(int postId, String title,String nickname, int views, String date) {
    _postData[postId] = {
      'title': title,
      'nickname': nickname,
      'views': views,
      'date': date,
    };
    _totalPosts++; // 🔄 전체 글 수량 증가
    notifyListeners();
  }

  /// ✅ 글 삭제 시 데이터 제거
  void removePost(int postId) {
    if (_postData.containsKey(postId)) {
      _postData.remove(postId);
      _totalPosts--; // 🔄 전체 글 수량 감소
      notifyListeners();
    }
  }
}
