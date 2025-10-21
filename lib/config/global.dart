import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';

final ValueNotifier<double> globalTimeListener = ValueNotifier(0);
final ValueNotifier<double> moneyListener = ValueNotifier(0);
final ValueNotifier<int> lifeNotifier = ValueNotifier(0);
final ValueNotifier<int> protectNotifier = ValueNotifier(0);
final ValueNotifier<double> propsNotifier = ValueNotifier(0);
ValueNotifier<Offset?> overlayNotifier = ValueNotifier<Offset?>(null);
ValueNotifier<Offset?> overlayNotifier2 = ValueNotifier<Offset?>(null);
final EventBus eventBus = EventBus();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final globalContext = navigatorKey.currentState?.overlay?.context;
var allowShowStart = true;

bool isForeground = true;

var allowTime = true;
var globalShowFood = false;
//危险气泡
var globalShowDanger1 = false;
//危险主ui 背景、新用户引导手势、文字提示
var globalShowDanger2 = false;
//鲨鱼攻击
var globalShowShark = false;
//防护气泡
var globalShowProtect = false;

bool adIsPlay = false;


var pUrl = "https://sites.google.com/view/fishearn-privacypolicy/home";
var hUrl = "https://sites.google.com/view/fishearn-useragreement/home";
