import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

///URL에서 중간 메뉴 값(예: "News", "Free")을 추출하는 함수
String? extractMiddleMenu(String? url) {
  if (url == null || url.isEmpty) return null; // URL이 없으면 null 반환

  final parts = url.split('/'); // '/' 기준으로 URL을 분리
  if (parts.length < 4) return null; // 최소한 4개 요소가 있어야 중간 메뉴 값이 존재

  //마지막 값 확인
  final String lastSegment = parts.last;
  final bool isUpdate = lastSegment == "update"; // 마지막 값이 "update"인지 확인
  final bool isNumber = int.tryParse(lastSegment) != null; // 마지막 값이 숫자인지 확인

  //"update"이면 /를 2번 이동, 숫자면 1번 이동
  final int postMenuIndex = parts.length - (isUpdate ? 3 : (isNumber ? 2 : 1));

  return (postMenuIndex >= 0 && postMenuIndex < parts.length) ? parts[postMenuIndex] : null;
}

///서버에서 데이터를 가져오는 공통 함수
Future<Map<String, dynamic>> extractMenuMapData1(String? splitUrl, String itemIndex) async {
  if (splitUrl == null || splitUrl.isEmpty) {
    print('2222222222222 fullUrl: $splitUrl');
    throw Exception("fullUrl 값이 비어있습니다.");
  }

  final String? middleMenu = extractMiddleMenu(splitUrl);
  if (middleMenu == null) {
    throw Exception("중간 메뉴 값을 추출할 수 없습니다.");
  }

  final String url = "https://api.cosmosx.co.kr/$middleMenu";
  print('📡 Fetching data from: $middleMenu');

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);

    //id 값들을 추출하여 오름차순 정렬
    final List<int> mappedIds = jsonData.map<int>((e) => e['id'] as int).toList();
    print('Sorted mappedIds: $mappedIds');

    //itemIndex가 mappedIds에 존재하는지 체크
    final int? parsedItemIndex = int.tryParse(itemIndex);
    if (parsedItemIndex == null || !mappedIds.contains(parsedItemIndex)) {
      throw Exception("itemIndex 값이 리스트에 존재하지 않습니다: $itemIndex");
    }

    //itemIndex 값이 mappedIds에서 뒤에서 몇 번째인지 계산
    final int currentIndex = (mappedIds.length - 1) - mappedIds.indexOf(parsedItemIndex);

    //결과 데이터를 반환 (extraData 형태)
    final extraData = {
      'key': UniqueKey(), // 고유 키 생성
      'currentIndex': currentIndex,
      'mappedIds': mappedIds,
    };

    print('라우트 반환값 (Sorted mappedIds extraData): $extraData');
    return extraData;
  } else {
    throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
  }
}
