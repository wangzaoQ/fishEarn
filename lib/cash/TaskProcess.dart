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
    return Column(
      children: [
        //task1
        Stack(
          children: [
            PropsProgress(
              progress: 0.5,
              // 进度 0~1
              progressColor: Color(0xFF86E659),
              backgroundColor: Color(0xFF126175),
              width: 306.w,
              height: 14.h,
              padding: 0,
            ),
          ],
        ),
      ],
    );
  }
}
