import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/task/TaskManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../view/PropsProgress.dart';

class TaskProcess extends StatefulWidget {
  const TaskProcess({super.key});

  @override
  State<TaskProcess> createState() => _TaskProcessState();
}

class _TaskProcessState extends State<TaskProcess> {
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
    var task1Complete = false;
    var task2Complete = false;
    if (task1Current >= task1Config) {
      task1Complete = true;
    }
    if (task2Current >= task2Config) {
      task1Complete = true;
    }
    var content1 = getTaskContent(task1,task1Current,task1Config);
    var content2 = getTaskContent(task2,task2Current,task2Config);

    return Column(
      children: [
        //task1
        Stack(
          clipBehavior: Clip.none, // 防止溢出被裁剪
          children: [
            PropsProgress(
              progress: (task1Current/task1Config).toDouble(),
              // 进度 0~1
              backgroundColor: Color(task1Complete?0xFF86E659:0xFFC0C0C0),
              width: 306.w,
              height: 14.h,
              padding: 0,
            ),
            Positioned(
              top: -2.h, // 根据需要微调
              left: 7.w,
              // child: Text(content1,style: TextStyle(
              //   fontSize: 12.sp,
              //   fontWeight: FontWeight.bold,
              //   color: Color(0xFF10160C),
              //   fontFamily: "AHV"
              // ),)
              child: buildRichText(content1),
            ),

            // 奖励图标（右上角）
            Positioned(
              top: -8.h, // 根据需要微调
              right: -10.w,
              child: Image.asset(
                task1Complete?"assets/images/ic_award_selected.webp":"assets/images/ic_award_selected2.webp",
                width: 24.w,
                height: 24.h,
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.5.h,),
        Stack(
          clipBehavior: Clip.none, // 防止溢出被裁剪
          children: [
            PropsProgress(
              progress: (task2Current/task2Config).toDouble(),
              // 进度 0~1
              backgroundColor: Color(task2Complete?0xFF86E659:0xFFC0C0C0),
              width: 306.w,
              height: 14.h,
              padding: 0,
            ),
            Positioned(
              top: -2.h, // 根据需要微调
              left: 7.w,
              child: buildRichText(content2),
            ),

            // 奖励图标（右上角）
            Positioned(
              top: -8.h, // 根据需要微调
              right: -10.w,
              child: Image.asset(
                task2Complete?"assets/images/ic_award_selected.webp":"assets/images/ic_award_selected2.webp",
                width: 24.w,
                height: 24.h,
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ],
    );
  }


  RichText buildRichText(String text) {
    // 匹配单个数字或者数字/数字
    final RegExp regex = RegExp(r'\d+(?:/\d+)?');

    final List<TextSpan> spans = [];
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(color: Color(0xFF10160C), fontSize: 12.sp,fontFamily: "AHV",fontWeight: FontWeight.bold),
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: TextStyle(color: Color(0xFFDC4734), fontSize: 12.sp,fontFamily: "AHV",fontWeight: FontWeight.bold),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(color: Color(0xFF10160C), fontSize: 12.sp,fontFamily: "AHV",fontWeight: FontWeight.bold),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  String getTaskContent(String taskName,int currentTaskCount,int allCount) {
    String template = "";
    if(taskName == "defend"){
      template = "app_task_defend".tr();
    }else if(taskName == "feed"){
      template = "app_task_feed".tr();
    }else if(taskName == "bubbles"){
      template = "app_task_bubbles".tr();
    }else if(taskName == "spins"){
      template = "app_task_spins".tr();
    }else if(taskName == "login"){
      template = "app_task_login".tr();
    }
    String result = template
        .replaceAll("{currentCount}", "$currentTaskCount")
        .replaceAll("{count}", "$allCount");
    return result;
  }
}
