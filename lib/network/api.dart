import 'dart:io';
import 'package:dio/dio.dart';

/// @description Api基类约束
///
/// @author 燕文强
///
/// @date 2019-09-02
abstract class Api<R> {
  /// 域名Url
  String baseUrl = '';

  /// 后半路径
  String path = '';

  /// 请求头
  Map<String, dynamic> header;

  /// 请求体
  dynamic body;

  /// 请求方式
  Method method = Method.POST;

  /// 以application/x-www-form-urlencoded格式发送数据
  ContentType contentType =
      ContentType.parse("application/x-www-form-urlencoded");

//  ContentType contentType = ContentType.json;

  /// 连接超时时间
  int connectTimeout = 5000;

  /// 发送超时时间
  int sendTimeout = 5000;

  /// 接收超时时间
  int receiveTimeout = 5000;

  /// 取消请求的标记,每个请求对应一个
  final CancelToken cancelToken = CancelToken();

  /// 取消请求
  void cancel() => cancelToken.cancel('cancel');

  /// 获取请求的完整地址 '$baseUrl$path'
  String requestUrl() => '$baseUrl$path';

  /// 定义什么是业务处理成功状态
  bool state(dynamic obj);

  /// 数据转换
  R Function(dynamic data) dataConvert;

  @override
  String toString() {
    String reqUrl = requestUrl();
    return 'Api{requestUrl: $reqUrl, body: $body, method: $method}';
  }
}

/// 网络请求方式枚举
enum Method { GET, POST, PUT, DELETE, HEAD, PATCH }
