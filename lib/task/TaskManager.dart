import 'dart:convert';

import 'package:fish_earn/config/CashConfig.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/config/LocalConfig.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:fish_earn/utils/LogUtils.dart';

import '../view/pop/CashProcessPop.dart';
import '../view/pop/PopManger.dart';

/// 任务管理器：
///
/// 支持功能：
/// 1. 管理任务配置（旧任务 + 新配置合并）
/// 2. 保留正在进行的任务内容
/// 3. 支持任务完成、自动切换下一个任务
/// 4. 可序列化存储到本地
class TaskManager {

  TaskManager._();

  // 全局唯一实例
  static final TaskManager instance = TaskManager._();

  var TAG = "TaskManager";

  /// 当前正在进行的任务名，如 "task1"
  String? _currentTask;

  /// 所有任务配置
  Map<String, dynamic> tasks = {};

  void init(Map<String, dynamic>? initialTasks) async{
    try{
      if (initialTasks != null) {
        tasks = Map<String, dynamic>.from(initialTasks);
      }
    }catch (e){
      LogUtils.logE("$TAG init error $e");
    }
    if(tasks.isEmpty){
      tasks = Map<String, dynamic>.from(CashConfig.defaultTask);
    }
  }

  /// 从服务器下发的新配置中更新任务
  ///
  /// - 保留当前任务；
  /// - 未开始任务用新配置替换；
  /// - 新增任务自动追加；
  void updateConfig(Map<String, dynamic> newConfig) {
    final Map<String, dynamic> merged = {};

    newConfig.forEach((key, value) {
      if (key == _currentTask && tasks.containsKey(key)) {
        merged[key] = tasks[key]; // 保留正在进行的任务
      } else {
        merged[key] = value; // 其他任务替换成新配置
      }
    });

    // 旧任务但新配置中没有的，也保留
    tasks.forEach((key, value) {
      if (!merged.containsKey(key)) {
        merged[key] = value;
      }
    });

    tasks = merged;
  }

  /// 获取当前任务内容
  Map<String, dynamic>? getCurrentTask() {
    _currentTask= LocalCacheUtils.getString(LocalCacheConfig.taskCurrentKey, defaultValue: "");
    if (_currentTask == null || _currentTask!.isEmpty) return null;
    return {
      _currentTask!: tasks[_currentTask],
    };
  }

  String getCurrentTaskName(){
    final current = getCurrentTask();
    if (current == null || current.isEmpty) return "";
    // 当前任务的任务名，例如 "task1"
    return current.keys.first;
  }

  /// 获取当前任务的所有子任务名（如 defend、feed 等）
  List<String> getCurrentSubTaskNames() {
    final current = getCurrentTask();
    if (current == null || current.isEmpty) return [];

    // 当前任务的任务名，例如 "task1"
    final taskName = current.keys.first;
    // 任务对应的数据，例如 [ { "defend": 5, "feed": 5 } ]
    final taskData = current[taskName];

    if (taskData is List && taskData.isNotEmpty && taskData.first is Map<String, dynamic>) {
      return (taskData.first as Map<String, dynamic>).keys.toList();
    }
    return [];
  }

  Map<String, dynamic> getCurrentSubTasks() {
    final current = getCurrentTask();
    if (current == null || current.isEmpty) return {};

    // 当前任务名，比如 "task1"
    final taskName = current.keys.first;
    final taskData = current[taskName];

    // 假设任务数据结构是类似 [{"defend":5, "feed":5}]
    if (taskData is List && taskData.isNotEmpty && taskData.first is Map<String, dynamic>) {
      return Map<String, dynamic>.from(taskData.first as Map<String, dynamic>);
    }

    // 如果本身就是 Map，则直接返回
    if (taskData is Map<String, dynamic>) {
      return Map<String, dynamic>.from(taskData);
    }

    return {};
  }



  /// 标记当前任务完成，自动切换到下一个任务
  ///
  /// - 若还有下一任务则切换；
  /// - 若没有则 currentTask = null；
  void markTaskDone() {
    if (_currentTask == null) return;

    final keys = tasks.keys.toList();
    final currentIndex = keys.indexOf(_currentTask!);

    if (currentIndex >= 0 && currentIndex < keys.length - 1) {
      _currentTask = keys[currentIndex + 1];
    } else {
      _currentTask = null; // 所有任务完成
    }
  }

  /// 手动设置当前任务（用于恢复或跳转）
  void setCurrentTask(String taskName) {
    if (tasks.containsKey(taskName)) {
      _currentTask = taskName;
    }
  }

  /// 将任务序列化为 JSON（便于存储）
  String toJsonString() {
    return jsonEncode({
      "currentTask": _currentTask,
      "tasks": tasks,
    });
  }


  /// 打印任务列表（调试用）
  void debugPrintTasks() {
    LogUtils.logD("${TAG} currentTask : $_currentTask");
    tasks.forEach((k, v) => print("$k: $v"));
  }

  /**
   * defend 防御
   * feed 食物
   * bubbles 气泡
   * spins 转盘
   * login 连续登录
   */
  void addTask(String task) {
    LogUtils.logD("$TAG: addTask:$task");
    var taskName = TaskManager.instance.getCurrentTaskName();
    if(taskName.isNotEmpty){
      var taskList = TaskManager.instance.getCurrentSubTaskNames();
      var task1 = taskList[0];
      var task2 = taskList[1];
      LogUtils.logD("$TAG: currentTask:$taskName task1:$task1 task2:$task2");
      var task1Count = LocalCacheUtils.getInt(task1);
      var task2Count = LocalCacheUtils.getInt(task2);
      if(task1 == task){
        LogUtils.logD("$TAG: task1 == $task");
        task1Count+=1;
        LocalCacheUtils.putInt(task1,task1Count);
      }
      if(task2 == task){
        LogUtils.logD("$TAG: task2 == $task");
        task2Count+=1;
        LocalCacheUtils.putInt(task2,task2Count);
      }
      nextTask(task1, task2, task1Count, task2Count, taskName);
    }
  }

  void nextTask(String task1, String task2, int task1Count, int task2Count, String taskName) {
    var taskMap = TaskManager.instance.getCurrentSubTasks();
    var task1Config = taskMap[task1];
    var task2Config = taskMap[task2];
    if(task1Count>=task1Config && task2Count>=task2Config){
      var nextTask = "";
      if(taskName == "task1"){
        nextTask = "task2";
      }else if(taskName == "task2"){
        nextTask = "task3";
      }else if(taskName == "task3"){
        nextTask = "task4";
      }else if(taskName == "task4"){
        nextTask = "task5";
      } else if(taskName == "task5"){
        nextTask = "task6";
      }
      LogUtils.logD("$TAG: task next currentTask:$taskName nextTask:$nextTask ");
      LocalCacheUtils.putString(LocalCacheConfig.taskCurrentKey,nextTask);
      LocalCacheUtils.putInt(task1,0);
      LocalCacheUtils.putInt(task2,0);
      if(nextTask == "task6"){
        LocalCacheUtils.putInt(
          LocalCacheConfig.cacheKeyCash,-1
        );
        var type = LocalCacheUtils.getInt(LocalCacheConfig.cashMoneyType,defaultValue: 1);
        //1 500 2 800 3 1000
        var money = 500;
        if(type == 1){
          money = 500;
        }else if(type == 2){
          money = 800;
        }else if(type == 3){
          money = 1000;
        }
        if(LocalConfig.globalContext!=null){
          PopManager().show(context: LocalConfig.globalContext!,
              child: CashProcessPop(money: money,));
        }
      }
    }
  }

  void addLogin(int lastDay, int currentDay) {
    LogUtils.logD("$TAG: addLogin:");
    var taskName = TaskManager.instance.getCurrentTaskName();
    if(taskName.isNotEmpty){
      var taskList = TaskManager.instance.getCurrentSubTaskNames();
      var task1 = taskList[0];
      var task2 = taskList[1];
      LogUtils.logD("$TAG: currentTask:$taskName task1:$task1 task2:$task2");
      var task1Count = LocalCacheUtils.getInt(task1);
      var task2Count = LocalCacheUtils.getInt(task2);
      if(task1 == "login"){
        LogUtils.logD("$TAG: task1 == login");
        task1Count+=1;
        LocalCacheUtils.putInt(task1,task1Count);
      }
      if(task2 == "login"){
        LogUtils.logD("$TAG: task2 == login");
        task2Count+=1;
        LocalCacheUtils.putInt(task2,task2Count);
      }
      nextTask(task1, task2, task1Count, task2Count, taskName);
    }
  }

}

