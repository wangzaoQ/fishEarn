import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // 用于判断是否为 release 模式
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../LogUtils.dart';
import 'NetParamsManager.dart';

class HttpManager {
  static const String url = "https://test-orbit.fishearnrewards.com/pulpit/astute/papal";
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: url, // <-- 替换为你的接口地址
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.addAll([
    if (!kReleaseMode) // 仅在 debug 或 profile 模式下开启日志
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 可选：添加 token
          // String? token = await getToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          options.headers['randall'] = NetParamsManager.instance.getDeviceModel();
          options.headers['leila'] = DateTime.now().timeZoneOffset.inHours;
          options.queryParameters.addAll({
            'deer': 'mcn',
            'booby': 'com.oceanearn.solitaire',
          });
          // 打印请求日志（可选）
          LogUtils.logI("net request: [${options.method}] ${options.uri}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 打印响应日志（可选）
          LogUtils.logI("net response: [${response.statusCode}] ${response.data}");

          return handler.next(response);
        },
        onError: (DioException e, handler){
          LogUtils.logI("net error: ${e.type} - ${e.message}");
          return handler.next(e);
        }
    ),
  ]);


}
