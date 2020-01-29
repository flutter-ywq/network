import 'dart:async';
import 'package:dio/dio.dart';
import 'network/response.dart';
export 'dart:async';

/// @description Deliver
///
/// @author 燕文强
///
/// @date 2019-12-30
abstract class Deliver {
  void applySuccess<T>(EventSink<T> sink, ResponseData data);

  void applyFail<T>(EventSink<T> sink, ResponseData data);

  void applyError<T>(EventSink<T> sink, dynamic error);

  void applyCatchError<T>(EventSink<T> sink, dynamic error);
}

class ApiDeliver implements Deliver {
  @override
  void applyCatchError<T>(EventSink<T> sink, error) {
    sink.addError('请求出错');
  }

  @override
  void applyError<T>(EventSink<T> sink, error) {
    DioError dioError = error;
    int statusCode = dioError.response.statusCode;
    if (statusCode == 404) {
      sink.addError('请求地址错误');
      return;
    }
    if (statusCode == 500) {
      sink.addError('服务器内部出错');
      return;
    }
    sink.addError('请求失败');
  }

  @override
  void applyFail<T>(EventSink<T> sink, ResponseData data) {
    sink.add(data.data as T);
  }

  @override
  void applySuccess<T>(EventSink<T> sink, ResponseData data) {
    sink.add(data.data as T);
  }
}
