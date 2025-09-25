import 'package:flutter/cupertino.dart';

final ValueNotifier<double> globalTimeListener = ValueNotifier(0);
final ValueNotifier<int> lifeNotifier = ValueNotifier(0);
var allowTime = true;