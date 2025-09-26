import 'package:flutter/cupertino.dart';

final ValueNotifier<double> globalTimeListener = ValueNotifier(0);
final ValueNotifier<int> lifeNotifier = ValueNotifier(0);
final ValueNotifier<int> protectNotifier = ValueNotifier(0);
ValueNotifier<Offset?> overlayNotifier = ValueNotifier<Offset?>(null);

var allowTime = true;
var showFood = false;
