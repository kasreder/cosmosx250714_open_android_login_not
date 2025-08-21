// // 📌 lib/util/post_sub_menu.dart
// import 'package:flutter/material.dart';
//
// /// 📌 서브메뉴 데이터 정의
// final List<List<String>> subMenus1 = [
//   ["새소식", "nwn", ""],
//   ["뉴스", "news", "1"],
// ];
//
// final List<List<String>> subMenus2 = [
//   ["공지/제휴", "nwn1", ""],
//   ["공지사항", "notice", "2"],
// ];
//
// final List<List<String>> subMenus3 = [
//   ["커뮤니티", "comm", ""],
//   ["자유게시판", "free", "4"],
// ];
//
// final List<List<String>> subMenus4 = [
//   ["정보자료", "comm1", ""],
//   ["기록/일지", "record", "5"],
// ];
//
// /// 📌 모든 서브메뉴 리스트를 모은 리스트
// final List<List<List<String>>> subMenusList = [
//   subMenus1,
//   subMenus2,
//   subMenus3,
//   subMenus4,
// ];
//
// /// ✅ 상위 메뉴 옵션 리스트 반환
// List<String> getMenuOptions() {
//   List<String> menuOptions = [];
//   for (var subMenus in subMenusList) {
//     menuOptions.add(subMenus[0][0]);
//   }
//   return menuOptions;
// }
//
// /// ✅ 특정 상위 메뉴의 서브메뉴 리스트 반환
// List<String> getSubMenus(String selectedMenu) {
//   for (var subMenus in subMenusList) {
//     if (subMenus[0][0] == selectedMenu) {
//       return subMenus.skip(1).map((item) => item[0]).toList();
//     }
//   }
//   return [];
// }
//
// /// ✅ 서브메뉴 표시 이름을 받아 해당 코드 반환
// String getSubMenuCode(String subMenuDisplayName) {
//   for (var subMenus in subMenusList) {
//     for (var item in subMenus) {
//       if (item[0] == subMenuDisplayName) {
//         return item[1];
//       }
//     }
//   }
//   return '';
// }
//
// /// ✅ 서브메뉴 코드로 board_id 반환
// String getBoardIdFromSubMenuCode(String subMenuCode) {
//   for (var subMenus in subMenusList) {
//     for (var item in subMenus) {
//       if (item[1] == subMenuCode) {
//         return item[2];
//       }
//     }
//   }
//   return '';
// }
//
// /// ✅ 서브메뉴 코드로 상위 메뉴 반환
// Map<String, String> getHigherMenuFromSubMenuCode(String subMenuCode) {
//   for (var subMenus in subMenusList) {
//     for (var item in subMenus) {
//       if (item[1] == subMenuCode) {
//         return {
//           'menuDisplayName': subMenus[0][0],
//           'menuCode': subMenus[0][1],
//         };
//       }
//     }
//   }
//   return {};
// }
//
// /// ✅ 서브메뉴 코드로 표시 이름 반환
// String getSubMenuDisplayName(String subMenuCode) {
//   for (var subMenus in subMenusList) {
//     for (var item in subMenus) {
//       if (item[1] == subMenuCode) {
//         return item[0];
//       }
//     }
//   }
//   return '';
// }
