
import 'package:flutter/cupertino.dart';
import '../model/BoardP.dart';


class NewsProvider extends ChangeNotifier {
  BoardP boardP;

  NewsProvider(this.boardP);

  changeTitle() {
    boardP = BoardP(title: boardP.title,
        content: boardP.content,
        id: boardP.id,
        views: boardP.views,
        nickname: boardP.nickname,
        created_at: boardP.created_at,
        bname: boardP.bname);
    notifyListeners();
  }
}