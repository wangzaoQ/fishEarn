import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:fish_earn/utils/net/HttpManager.dart';
import 'package:fish_earn/utils/net/NetParamsManager.dart';
import 'package:flutter_tba_info/flutter_tba_info.dart';

import '../LogUtils.dart';

class EventManager{
  // 私有构造函数
  EventManager._();

  // 全局唯一实例
  static final EventManager instance = EventManager._();

  // 公共访问点
  factory EventManager() {
    return instance;
  }

  void session(){
    LogUtils.logD("postEvent key: session");
    Future(() async{
      var map = await NetParamsManager.instance.getCommonJson();
      map["pagoda"]={};
      HttpManager.dio.post("",data: map).catchError((e){
        LogUtils.logE("error:${e}");
      });
    });
  }

  void install(ReferrerDetails referrerDetails){
    LogUtils.logD("postEvent key: install");
    Future(() async{
      var commonJson = await NetParamsManager.instance.getCommonJson();
      var map={};
      map["mukluk"]= await NetParamsManager.instance.getBuildId();
      map["werther"]= referrerDetails.installReferrer??"";
      map["sideshow"]= await NetParamsManager.instance.getWebViewUserAgent();
      map["infra"]= "millard";
      map["softball"]= referrerDetails.referrerClickTimestampSeconds;
      map["smelt"]= referrerDetails.installBeginTimestampSeconds;
      map["lampoon"]= referrerDetails.referrerClickTimestampServerSeconds;
      map["kept"]= referrerDetails.installBeginTimestampServerSeconds;
      var mapRefer = await FlutterTbaInfo().getReferrerMap();
      map["accent"]= mapRefer["install_first_seconds"];
      map["line"]= mapRefer["last_update_seconds"];
      commonJson["sight"]=map;
      HttpManager.dio.post("",data: map).catchError((e){
        LogUtils.logE("error:${e}");
      });
    });
  }


  void postEvent(String key,{Map<String, dynamic>? params,void Function(dynamic data)? onResult}){
    LogUtils.logD("postEvent key:${key} params:${params}");
    Future(() async {
      var map = await NetParamsManager.instance.getCommonJson();
      var json = {};
      json["ak"]=key;
      json["bater"]=map;
      HttpManager.dio.post("",data: json).catchError((e){
        LogUtils.logE("error:$e");
      });
      if(onResult!=null){

      }
    });
    // FirebaseManager.instance.analytics?.logEvent(
    //   name: key,
    //   parameters: params?.cast<String, Object>(),
    // ).catchError((e){
    //   LogUtils.logE("error:$e");
    // });
  }


}