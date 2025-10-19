import 'package:flutter/cupertino.dart';

class LocalConfig{
  static final maxKey = "1";
  static final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final globalContext = navigatorKey.currentState?.overlay?.context;
  static const int = "interstitial";
  static const reward = "reward";
}