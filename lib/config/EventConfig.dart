class EventConfig{
  // 新用户流程
  static const new3 = "new3";
  static const new4 = "new4";
  static const toCash = "toCash";

  /**
   * "ad_code_id:广告位ID；
      ad_format：广告位类型，rv/int；
      ad_platform：广告平台，admob、max、topon、tradplus、other"
   */
  static const ad_request = "ad_request";

  /**
   * "ad_code_id:广告位ID；
      ad_format：广告位类型，rv/int；
      ad_platform：广告平台，admob、max、topon、tradplus、other"
   */
  static const fixrn_ad_return = "fixrn_ad_return";
  static const fixrn_ad_chance = "fixrn_ad_chance";
  static const fixrn_ad_impression_fail = "fixrn_ad_impression_fail";
  //AD 开屏
  static const fixrn_launch = "fixrn_launch";
  //升级
  static const fixrn_grow_rv = "fixrn_grow_rv";
  //看激励广告复活饿死的鱼
  static const fixrn_starve_rv = "fixrn_starve_rv";
  //看激励广告复活被攻击死的鱼
  static const fixrn_attack_rv = "fixrn_attack_rv";
  //点击防御看激励广告增加1分钟防御保护
  static const fixrn_shield_rv = "fixrn_shield_rv";
  static const fixrn_shield_int = "fixrn_shield_int";
  //转盘奖励弹窗点击claimx2观看激励广告
  static const fixrn_wheel_rv = "fixrn_wheel_rv";
  //转盘奖励弹窗点击claim弹出插屏广告
  static const fixrn_wheel_int = "fixrn_wheel_int";
  //点击现金气泡看激励广告
  static const fixrn_pop_rv = "fixrn_pop_rv";
  //漂流瓶奖励弹窗点击「claim all」观看激励广告
  static const fixrn_bottle_rv = "fixrn_bottle_rv";
  //漂流瓶奖励弹窗点击Only xxx弹出插屏广告
  static const fixrn_bottle_int = "fixrn_bottle_int";
  //排队
  static const fixrn_skipwait_rv = "fixrn_skipwait_rv";
  //离线奖励弹窗点击Claim 200%观看激励广告
  static const fixrn_offline_rv = "fixrn_offline_rv";
  //离线奖励弹窗点击Only xx弹出插屏广告
  static const fixrn_offline_int = "fixrn_offline_int";


  //事件 安装（自定义）
  static const session_custom = "session_custom";
  //判断为异常用户
  static const risk_chance = "risk_chance";
  //广告展示次数过多明日再来弹窗
  static const see_you_tommorow = "see_you_tommorow";
  //启动页展示
  static const launch_page = "launch_page";
  //启动页start点击
  static const launch_start = "launch_start";
  //首页（主页面）展示
  static const home_page = "home_page";

  /**
   * 新用户蒙层引导
   * "pop_step
      pop1：喂食
      pop2：现金泡泡
      pop3：现金获得弹窗
      pop4：成长栏
      pop5：鱼升级
      pop6：攻击提示
      pop7：漂流瓶
      pop8：提现平台
      pop9：提现金额"
   */
  static const new_guide = "new_guide";
  static const new_guide_c = "new_guide_c";
  //首页成长点击
  static const home_growing_c = "home_growing_c";
  //升级广告弹窗展示
  static const growing_ad_pop = "growing_ad_pop";
  //首页提现进度栏展示
  static const home_withdraw = "home_withdraw";
  //home_withdraw_c
  static const home_withdraw_c = "home_withdraw_c";
  //转盘页展示
  static const pearl_wheel = "pearl_wheel";
  static const pearl_wheel_c = "pearl_wheel_c";
  //转盘现金弹窗展示
  static const pearl_wheel_pop = "pearl_wheel_pop";
  //转盘现金弹窗点击claim
  static const pearl_wheel_2x = "pearl_wheel_2x";
  //转盘现金弹窗点击1倍和关闭同时上报
  static const pearl_wheel_1x = "pearl_wheel_1x";
  //漂流瓶页面展示
  static const drift_bottle = "drift_bottle";
  //漂流瓶全选按钮点击
  static const drift_bottle_all = "drift_bottle_all";
  //鲨鱼预警触发
  static const shark_attack = "shark_attack";
  //鲨鱼攻击触发
  static const shark_attack_c = "shark_attack_c";
  //防御点击
  static const defense_c = "defense_c";
  static const defense_pop = "defense_pop";
  static const defense_pop_c = "defense_pop_c";
  //鱼死亡弹窗
  static const fish_die = "fish_die";
  //复活按钮
  static const fish_die_re = "fish_die_re";
  //重生按钮
  static const fish_die_rebirth = "fish_die_rebirth";
  //通知权限允许
  static const noti_req_allow = "noti_req_allow";
  //通知权限拒绝
  static const noti_req_refuse = "noti_req_refuse";
  //提现页曝光
  static const cash_page = "cash_page";
  //提现任务弹窗
  static const cash_task_pop = "cash_task_pop";
  //提现不足弹窗
  static const cash_not_pop = "cash_not_pop";
  //提现不足弹窗点击
  static const cash_not_pop_c = "cash_not_pop_c";
  //cash_queue
  static const cash_queue = "cash_queue";
  //提现排队弹窗展示
  static const cash_queue_pop = "cash_queue_pop";
  //排队跳过点击
  static const queue_skipwait = "queue_skipwait";
  //通知点击
  static const all_noti_c = "all_noti_c";
  //通知出发点
  static const all_noti_t = "all_noti_t";
  //广告获取失败弹窗
  static const ad_fail = "ad_fail";
  //广告获取失败弹窗 重试按钮点击
  static const ad_fail_c = "ad_fail_c";
  //到达提现额度弹窗
  static const meet_withdraw = "meet_withdraw";
  //终生累计广告数到达参数的时候，就打一次
  static const pv_dall = "pv_dall";
  //老用户离线奖励弹窗展示
  static const old_users_award = "old_users_award";
  static const old_users_award_1x = "old_users_award_1x";
  static const old_users_award_2x = "old_users_award_1x";

}