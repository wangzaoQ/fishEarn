import 'package:dio/dio.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/utils/GlobalDataManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:flutter/foundation.dart'; // 用于判断是否为 release 模式
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../LogUtils.dart';
import 'NetParamsManager.dart';

class HttpManager {
  static const String url = "https://orbit.fishearnrewards.com/giovanni/ensconce/mcnulty";
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
          options.headers.addAll({
            'criteria': await NetParamsManager.instance.getDeviceModel(),
            'tracery': 'widgeon',
          });
          options.queryParameters.addAll({
            'hostage': NetParamsManager.instance.getLocaleCode(),
            'booby': await NetParamsManager.instance.getDeviceManufacturer(),
          });
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler){
          return handler.next(e);
        }
    ),
  ]);


}
