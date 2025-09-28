import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/utils/AudioUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/LocalCacheConfig.dart';
import '../../utils/LocalCacheUtils.dart';

class SettingPop extends StatefulWidget {
  @override
  State<SettingPop> createState() => _SettingPopState();
}

class _SettingPopState extends State<SettingPop> {
  @override
  Widget build(BuildContext context) {
    var allowBgm = LocalCacheUtils.getBool(
      LocalCacheConfig.allowBGMKey,
      defaultValue: true,
    );
    var allowTempAudioKey = LocalCacheUtils.getBool(
      LocalCacheConfig.allowTempAudioKey,
      defaultValue: true,
    );
    return Stack(
      children: [
        SizedBox(
          width: 352.w,
          height: 299.h,
          child: Stack(
            children: [
              Center(child:Image.asset(
                "assets/images/bg_setting.webp",
              )),
              Positioned(
                right: 0.w,
                top: 12.h,
                child: CupertinoButton(
                  child: Image.asset(
                    "assets/images/ic_setting_close.webp",
                    width: 32.w,
                    height: 32.h,
                    fit: BoxFit.fill,
                  ),
                  onPressed: () {
                    Navigator.pop(context, null);
                  },
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsetsGeometry.only(top: 0.h),
                  child: Image.asset(
                    "assets/images/ic_setting_img.webp",
                    width: 226.w,
                    height: 75.h,
                  ),
                ),
              ),
              Positioned(
                left: 44.w,
                right: 54.w,
                top: 83.h,
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/ic_music.webp",
                      width: 33.w,
                      height: 29.h,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 11.w),
                        // 左右各加 8.w
                        child: AutoSizeText(
                          "app_bgm".tr(),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 17.sp,
                            color: Color(0xFF264455),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      pressedOpacity: 0.7,
                      child: Image.asset(
                        allowBgm
                            ? "assets/images/ic_audio_on.webp"
                            : "assets/images/ic_audio_off.webp",
                        width: 57.w,
                        height: 30.h,
                      ),
                      onPressed: () {
                        setState(() {
                          updateBgm(allowBgm);
                        });
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 44.w,
                right: 54.w,
                top: 145.h,
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/ic_sound.webp",
                      width: 33.w,
                      height: 29.h,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 11.w),
                        // 左右各加 8.w
                        child: AutoSizeText(
                          "app_sound_effects".tr(),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 17.sp,
                            color: Color(0xFF264455),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      pressedOpacity: 0.7,
                      child: Image.asset(
                        allowBgm
                            ? "assets/images/ic_audio_on.webp"
                            : "assets/images/ic_audio_off.webp",
                        width: 57.w,
                        height: 30.h,
                      ),
                      onPressed: () {
                        setState(() {
                          updatePlayAudio(allowTempAudioKey);
                        });
                      },
                    ),
                  ],
                ),
              ),
              //联系我们
              Positioned(
                left: 29.w,
                bottom: 62.h,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  pressedOpacity: 0.7,
                  child: SizedBox(
                    width: 139.w,
                    height: 45.h,
                    child: Stack(
                      alignment: Alignment.center, // 让子元素默认居中
                      children: [
                        Image.asset("assets/images/bg_confirm.webp"),
                        Center(
                          child: AutoSizeText(
                            "app_contact_us".tr(),
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF185F11),
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, 1);
                  },
                ),
              ),
              Positioned(
                right: 29.w,
                bottom: 62.h,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  pressedOpacity: 0.7,
                  child: SizedBox(
                    width: 139.w,
                    height: 45.h,
                    child: Stack(
                      alignment: Alignment.center, // 让子元素默认居中
                      children: [
                        Image.asset("assets/images/bg_cancel.webp"),
                        Center(
                          child: AutoSizeText(
                            "app_privacy_policy".tr(),
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB84418),
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, 0);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void updatePlayAudio(bool cacheTempAudioKey) {
    cacheTempAudioKey = !cacheTempAudioKey;
    LocalCacheUtils.putBool(
      LocalCacheConfig.allowTempAudioKey,
      cacheTempAudioKey,
    );
  }

  void updateBgm(bool cacheBGMKey) {
    cacheBGMKey = !cacheBGMKey;
    if (cacheBGMKey) {
      AudioUtils().playBGM("audio/bg1.mp3");
    } else {
      AudioUtils().pauseBGM();
    }
    LocalCacheUtils.putBool(LocalCacheConfig.allowBGMKey, cacheBGMKey);
  }
}
