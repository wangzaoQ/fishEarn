
import 'ADRequestData.dart';

class ADResultData{
  ADRequestData? adRequestData;
  int adCreateTime = DateTime.now().millisecondsSinceEpoch;
  dynamic adAny;
  int adRequestTime = 0;
  String adType= "";
}