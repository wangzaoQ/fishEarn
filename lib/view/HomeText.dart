import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/view/GameText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeText extends StatefulWidget {
  final VoidCallback? onPrivacy;
  final VoidCallback? onTerms;

  const HomeText({super.key, this.onPrivacy, this.onTerms});

  @override
  _HomeTextState createState() => _HomeTextState();
}

class _HomeTextState extends State<HomeText> {
  @override
  Widget build(BuildContext context) {
    double fontSize = 16.sp;
    double strokeWidth = 3.w;
    var cachePrivacyKey = LocalCacheUtils.getBool(
      LocalCacheConfig.cachePrivacyKey,
      defaultValue: true,
    );
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      // 控制横向间距
      runSpacing: 8.h,
      // 控制换行时垂直间距
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero, // 去掉默认内边距
          pressedOpacity: 0.7,
          onPressed: () {
            setState(() {
              LocalCacheUtils.putBool(
                LocalCacheConfig.cachePrivacyKey,
                !cachePrivacyKey,
              );
            });
          },
          child: SizedBox(
            width: 24.w,
            height: 24.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset("assets/images/bg_start_selected.webp"),
                cachePrivacyKey
                    ? Image.asset("assets/images/ic_arrow.webp")
                    : SizedBox(),
              ],
            ),
          ),
        ),
        SizedBox(width: 7.w),
        CupertinoButton(
          padding: EdgeInsets.zero, // 去掉默认内边距
          pressedOpacity: 0.7,
          onPressed: () {
            widget.onPrivacy!();
          },
          child: GameText(
            showText: "app_privacy".tr(),
            fontSize: fontSize,
            strokeWidth: strokeWidth,
            strokeColor: Color(0xFF033B5F),
            fillColor: Color(0xFFE0E7E0),
          ),
        ),
        GameText(
          showText: "&",
          fontSize: fontSize,
          strokeWidth: strokeWidth,
          strokeColor: Color(0xFF033B5F),
          fillColor: Color(0xFFE0E7E0),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero, // 去掉默认内边距
          pressedOpacity: 0.7,
          onPressed: () {
            widget.onTerms!();
          },
          child: GameText(
            showText: "app_terms".tr(),
            fontSize: fontSize,
            strokeWidth: strokeWidth,
            strokeColor: Color(0xFF033B5F),
            fillColor: Color(0xFFE0E7E0),
          ),
        ),
      ],
    );
  }
}
