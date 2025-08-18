import 'package:flutter/cupertino.dart';

class GameViewModel  extends ChangeNotifier {
  void updateGame() {
    notifyListeners();
  }
}
