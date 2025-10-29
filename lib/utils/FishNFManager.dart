import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/EventConfig.dart';
import 'LogUtils.dart';
import 'net/EventManager.dart';

class FishNFManager{
  FishNFManager._();

  // 全局唯一实例
  static final FishNFManager instance = FishNFManager._();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  bool registerNF = false;

  bool initNF = false;

  init() async {
    if(initNF)return;
    initNF = true;
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher'); // 不加 .png

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        LogUtils.logD("nf click response:${response}");
        final String? payload = response.payload;
        EventManager.instance.postEvent(EventConfig.all_noti_c,params: {"push_type":payload??""});
        if(payload == null)return;
      },
    );
    checkNF();
  }

  Future<bool> requestNF() async{
    var nfPermission = await allowNF();
    if(nfPermission){
      LogUtils.logD("nf has permission");
      startNF();
      return true;
    }
    final status = await Permission.notification.request();
    if (status.isGranted) {
      LogUtils.logD("nf has permission");
      startNF();
      return true;
    }
    LogUtils.logD("nf no permission");
    return false;
  }

  Future<bool> allowNF() async {
    final status = await Permission.notification.status;
    if(status.isGranted){
      EventManager.instance.postEvent(EventConfig.noti_req_allow);
    }else{
      EventManager.instance.postEvent(EventConfig.noti_req_refuse);
    }
    return status.isGranted;
  }

  Future<void> _repeatNotification(int nfId,String nfTitle,String nfContent,String channel,Duration duration) async {
    //自定义通知ID
    final int id = nfId;
    final String title = nfTitle;
    final String body = nfContent;
    AndroidNotificationDetails details = AndroidNotificationDetails(
      channel,
      channel,
      styleInformation: BeautyStyleInformation(
        title,
        body,
        'nf_bg',
        'Claim',
        'ic_launcher',
      ),
      priority: Priority.high,
      importance: Importance.high,
      icon: 'ic_launcher',
      //“groupKey”：防止通知被系统折叠
      groupKey: "$id",
    );
    await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
        id,
        title,
        body,
        //间隔时长根据需求设置
        duration,
        notificationDetails: details,
        scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: channel
    );
  }

  Future<void> _subscribeFcmTopic() async {
    await AndroidFlutterLocalNotificationsPlugin().subscribeToTopic(
      'C116_us_data_fcm',
      const AndroidNotificationDetails(
          'fcm',
          'fcm_push',
          styleInformation: BeautyStyleInformation(
            '',
            '',
            'nf_bg',
            'Claim',
            'ic_launcher',
          ),
          priority: Priority.high,
          importance: Importance.high,
          icon: 'ic_launcher'
      ),
    );
  }

  Future<void> _showUnlockNotification(String title,String body) async {
    //自定义通知ID
    final int id = 940;
    await AndroidFlutterLocalNotificationsPlugin().showBroadcastNotification(
      id,
      title,
      body,
      //两次发送解锁通知的间隔，根据需求设置
      const Duration(minutes: 1),

      'android.intent.action.USER_PRESENT',
      AndroidNotificationDetails(
        'nf_unlock',
        'nf_unlock',
        priority: Priority.high,
        importance: Importance.high,
        icon: 'ic_launcher',
        styleInformation: BeautyStyleInformation(
          title,
          body,
          'nf_bg',
          'Claim',
          'ic_launcher',
        ),
        //“groupKey”：防止通知被系统折叠
        groupKey: "$id",
      ),
      'unlock',
    );
  }

  final plugin = AndroidFlutterLocalNotificationsPlugin();

  void checkNF() {
    Future(() async {
      await addPointT("nf_channel_0");
      await addPointT("nf_channel_1");
      await addPointT("nf_channel_2");
      await addPointT("fcm");
      await addPointT("unlock");
    });
  }

  Future<void> addPointT(String channel) async {
    //通知来源，通知详情中设置的“payload”参数，默认为【local】
    final count = await plugin.extractMessageReceivedNum(channel);
    for (int i = 0; i < count; i++) {
      EventManager.instance.postEvent(EventConfig.all_noti_t,params: {"type":channel});
      await Future.delayed(Duration(seconds: 1));
    }
  }

  void startNF() {
    if(registerNF)return;
    registerNF = true;
    _subscribeFcmTopic();
    var list_t1 = [
      "nf_t1_1".tr(),
      "nf_t1_2".tr(),
    ];
    var list_c1 = [
      "nf_c1_1".tr(),
      "nf_c1_2".tr(),
    ];
    var list_id1 = [
      89999,
      89998,
    ];
    startRepeat(list_t1,list_c1,list_id1,"noti1",1);
    var list_t2 = [
      "nf_t2_1".tr(),
      "nf_t2_2".tr(),
    ];
    var list_c2 = [
      "nf_c2_1".tr(),
      "nf_c2_2".tr(),
    ];
    var list_id2 = [
      88999,
      88998,
    ];
    startRepeat(list_t2,list_c2,list_id2,"noti2",1);
    var list_t3 = [
      "nf_t3_1".tr(),
      "nf_t3_2".tr(),
    ];
    var list_c3 = [
      "nf_c3_1".tr(),
      "nf_c3_2".tr(),
    ];
    var list_id3= [
      87999,
      87998,
    ];
    startRepeat(list_t3,list_c3,list_id3,"noti3",1);
    // startRepeat1(list_t1,list_c1,list_id1,"repeat2");
    var list_t4 = [
      "nf_t4_1".tr(),
      "nf_t4_2".tr(),
    ];
    var list_c4 = [
      "nf_c4_1".tr(),
      "nf_c4_2".tr(),
    ];
    var tagCount = LocalCacheUtils.getInt("unlock",defaultValue: 0);
    if(tagCount == 0){
      tagCount = 1;
    }else{
      tagCount = 0;
    }
    LocalCacheUtils.putInt("unlock", tagCount);
    _showUnlockNotification(list_t4[tagCount],list_c4[tagCount]);
  }

  void startRepeat(List<String> list_t, List<String> list_c, List<int> list_id, String tag,int minutes) {
    var tagCount = LocalCacheUtils.getInt(tag,defaultValue: 0);
    Duration duration = Duration(minutes: minutes);
    _repeatNotification(list_id[tagCount],list_t[tagCount],list_c[tagCount],"${tag}_$tagCount",duration);
    if(tagCount == 0){
      tagCount = 1;
    }else{
      tagCount = 0;
    }
    Duration duration2 = Duration(minutes: minutes*2);
    _repeatNotification(list_id[tagCount],list_t[tagCount],list_c[tagCount],"${tag}_$tagCount",duration2);
    LocalCacheUtils.putInt(tag, tagCount);
  }

}
