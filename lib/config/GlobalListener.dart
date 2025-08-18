
import 'package:fish_earn/model/GameViewModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class GlobalListener extends StatefulWidget {
  final Widget child;

  const GlobalListener({super.key, required this.child});

  @override
  State<GlobalListener> createState() => GlobalUserListenerState();
}

class GlobalUserListenerState extends State<GlobalListener> {
  bool _dialogShown = false;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameViewModel>(
      builder: (context, userViewModel, child) {
        // WidgetsBinding.instance.addPostFrameCallback((_) async {
        //   if (!_initialized) {
        //     _initialized = true; // 第一次进来跳过弹窗
        //     return;
        //   }
        //   // 轮询等待条件满足
        //   while (isOtherRunning) {
        //     await Future.delayed(Duration(milliseconds: 1000));
        //   }
        //   if (_dialogShown) return;
        //   var user = CacheManager.getUser();
        //   if (user.allowWithdraw() && user.process == 0) {
        //     _dialogShown = true;
        //     Future.delayed(Duration(seconds: 1), () {
        //       BasePopQueue().show(
        //         context: context,
        //         child: CashTipsPop(),
        //         backResult: (result) {
        //           _dialogShown = false;
        //         },
        //       );
        //     });
        //   }
        // });
        return widget.child;
      },
    );
  }
}
