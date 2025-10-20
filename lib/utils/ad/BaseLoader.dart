
import '../../config/LocalConfig.dart';
import '../../data/ADRequestData.dart';
import '../../data/ADResultData.dart';
import 'ADEnum.dart';

abstract class BaseLoader {
  final ADRequestData requestBean;
  final ADEnum adEnum;

  // 构造函数
  BaseLoader(this.requestBean, this.adEnum);

  // 回调函数声明（可用 late 修饰）
  late void Function(String) failedCallBack;
  late void Function(ADResultData) successCallBack;

  void loadFailed(String msg, void Function(String) failed) {
    failed(msg);
  }

  void setSuccessCall(void Function(ADResultData) successCallBack) {
    this.successCallBack = successCallBack;
  }

  void setFailedCall(void Function(String) failedCallBack) {
    this.failedCallBack = failedCallBack;
  }

  void startLoadAD() {
    switch (requestBean.wdlwgunk) {
      case LocalConfig.reward:
        rewarded();
        break;
      case LocalConfig.int:
        intAD();
        break;
      default:
        // 可选：处理默认情况
        break;
    }
  }


  void intAD();
  void rewarded();

}
