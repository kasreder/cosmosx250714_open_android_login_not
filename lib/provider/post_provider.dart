import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


class ItemIndexProvider with ChangeNotifier {
  int? _itemIndex;

  int? get itemIndex => _itemIndex;

  void setItemIndex(int newIndex) {
    _itemIndex = newIndex;
    notifyListeners();
  }
}

