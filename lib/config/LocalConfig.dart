import 'package:flutter/cupertino.dart';

class LocalConfig{
  static final maxKey = "1";
  static final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final globalContext = navigatorKey.currentState?.overlay?.context;
  static const int = "interstitial";
  static const reward = "reward";

  static const facebookId = "";
  static const facebookToken = "";
  static const facebookName = "";
  static const adjustToken = "4qedga65udq8";
  static const h5Url = "https://tinyurl.com/3kc7zb68";

}