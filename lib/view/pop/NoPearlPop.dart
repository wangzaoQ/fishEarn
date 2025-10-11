import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/AudioUtils.dart';
import '../GameText.dart';

class NoPearlPop extends StatefulWidget {
  const NoPearlPop({super.key});

  @override
  State<NoPearlPop> createState() => _NoPearlPopState();
}

class _NoPearlPopState extends State<NoPearlPop> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsetsGeometry.only(top: 255.h),
          child: GameText(showText: "app_no_pearls".tr()),
        ),
      ),
      Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsetsGeometry.only(top: 330.h),
          child: Image.asset("assets/images/ic_no_pearls.webp",width: 94.w,height: 94.h,),
        ),
      ),
      Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsetsGeometry.only(top: 471.h),
          child: GameText(showText: "app_fish_to_exchange".tr(),fontSize: 16.sp,strokeWidth: 1.w,strokeColor: Color(0xFFFF0066),),
        ),
      ),
      Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsetsGeometry.only(top: 535.h),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            pressedOpacity: 0.7,
            child: SizedBox(
              width: 172.w,
              height: 50.h,
              child:Stack(
                alignment: Alignment.center, // 让子元素默认居中
                children: [
                  Image.asset(
                    "assets/images/bg_confirm.webp",
                    fit: BoxFit.fill,
                  ),
                  AutoSizeText(
                    "app_play".tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF185F11),
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            onPressed: () {
              AudioUtils().playClickAudio();
              Navigator.pop(context, 1);
            },
          ),
        ),
      ),

    ],);
  }
}
