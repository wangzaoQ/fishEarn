import 'package:flutter/cupertino.dart';

final ValueNotifier<double> globalTimeListener = ValueNotifier(0);
final ValueNotifier<int> lifeNotifier = ValueNotifier(0);
final ValueNotifier<int> protectNotifier = ValueNotifier(0);
final ValueNotifier<double> propsNotifier = ValueNotifier(0);
ValueNotifier<Offset?> overlayNotifier = ValueNotifier<Offset?>(null);
ValueNotifier<Offset?> overlayNotifier2 = ValueNotifier<Offset?>(null);

var allowTime = true;
var globalShowFood = false;
var globalShowDanger = false;
var globalShowShark = false;
var globalShowProtect = false;
