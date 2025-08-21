import 'package:flutter/material.dart';
import '../model/Model.dart';

// class NoticeProvider with ChangeNotifier {
//   NoticeModel _currentNotice = NoticeModel(title: '');
//
//   NoticeModel get currentNotice => _currentNotice;
//
//   void updateCurrentNotice(String title) {
//     _currentNotice = NoticeModel(title: title);
//     notifyListeners();
//   }
// }

class NoticeProvider with ChangeNotifier {
  NoticeData? _noticeData;

  NoticeData? get noticeData => _noticeData;

  void setNoticeData(NoticeData newData) {
    _noticeData = newData;
    notifyListeners();
  }
}