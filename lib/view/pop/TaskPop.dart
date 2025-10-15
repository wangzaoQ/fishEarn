import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../task/TaskManager.dart';
import '../../utils/LocalCacheUtils.dart';

///
class TaskPop extends StatelessWidget {
  const TaskPop({super.key});

  @override
  Widget build(BuildContext context) {
    var taskList = TaskManager.instance.getCurrentSubTaskNames();
    var taskMap = TaskManager.instance.getCurrentSubTasks();
    var task1 = taskList[0];
    var task2 = taskList[1];
    var task1Current = LocalCacheUtils.getInt(task1);
    var task2Current = LocalCacheUtils.getInt(task2);
    var task1Config = taskMap[task1];
    var task2Config = taskMap[task2];
    var task1Need = getTaskContent(task1, task1Config);
    var task2Need = getTaskContent(task2, task2Config);

    return Center(
      child: Container(
        width: 286.w,
        decoration: BoxDecoration(
          color: const Color(0xFFE1EFF7),
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // ✅ 关键，让第一个元素贴顶
              children: [
                /// 关闭按钮（贴顶部右侧）
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: 0.h, right: 7.w),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero, // 去掉默认内边距
                      pressedOpacity: 0.7,
                      child: SizedBox(
                        width: 23.w,
                        height: 23.h,
                        child: Center(
                          child: Image.asset(
                            "assets/images/ic_close.webp",
                            width: 23.w,
                            height: 23.h,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, -1);
                      },
                    ),
                  ),
                ),

                /// 顶部标题
                Padding(
                  padding: EdgeInsets.only(left: 21.w, right: 21.w, top: 5.h),
                  child: Text(
                    "app_task2_title".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1,
                      fontSize: 18.sp,
                      fontFamily: "AHV",
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F0F0F),
                    ),
                  ),
                ),
                SizedBox(height: 9.h,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 13.w),
                  child: Text(
                    "app_task2_content".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: "AHV",
                      color: const Color(0xFF666666),
                    ),
                  ),
                ),

                SizedBox(height: 23.h),

                /// 中间任务容器
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9DDEB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    children: [
                      // 第一行任务
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40.w,
                              height: 40.h,
                              child: Image.asset(
                                getTaskImg(task1),
                                width: 40.w,
                                height: 40.h,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                task1Need,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: "AHV",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Text(
                              "${task1Current}/${task1Config}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: "AHV",
                                color: const Color(0xFFF54A0C),
                              ),
                            ),
                            SizedBox(width: 19.w),
                          ],
                        ),
                      ),

                      // 第二行任务
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40.w,
                              height: 40.h,
                              child: Image.asset(
                                getTaskImg(task2),
                                width: 40.w,
                                height: 40.h,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                task2Need,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: "AHV",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Text(
                              "${task2Current}/${task2Config}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: "AHV",
                                color: const Color(0xFFF54A0C),
                              ),
                            ),
                            SizedBox(width: 19.w),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                /// 确认按钮
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Container(
                    width: 179.w,
                    height: 45.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F6CFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        "app_complete".tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: "AHV",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, -1);
                  },
                ),

                SizedBox(height: 23.h),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getTaskContent(String taskName, int allCount) {
    String template = "";
    if (taskName == "defend") {
      template = "app_task_pop_defend".tr();
    } else if (taskName == "feed") {
      template = "app_task_pop_feed".tr();
    } else if (taskName == "bubbles") {
      template = "app_task_pop_bubbles".tr();
    } else if (taskName == "spins") {
      template = "app_task_pop_spins".tr();
    } else if (taskName == "login") {
      template = "app_task_pop_login".tr();
    }
    String result = template.replaceAll("{count}", "$allCount");
    return result;
  }

  String getTaskImg(String taskName) {
    String img = "assets/images/ic_task_defend.webp";
    if (taskName == "defend") {
      img = "assets/images/ic_task_defend.webp";
    } else if (taskName == "feed") {
      img = "assets/images/ic_task_food.webp";
    } else if (taskName == "bubbles") {
      img = "assets/images/ic_task_bubbles.webp";
    } else if (taskName == "spins") {
      img = "assets/images/ic_task_spins.webp";
    } else if (taskName == "login") {
      img = "assets/images/ic_task_login.webp";
    }
    return img;
  }
}
