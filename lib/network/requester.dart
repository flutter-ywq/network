import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'api.dart';
import 'response.dart';
import '../utils/logger.dart';

/// @description 网络请求器
///
/// @author 燕文强
///
/// @date 2019-09-02
class Request {
  /// dio实例对象，外部不可访问
  static Dio _dio;

  /// api配置，外部可访问，不可修改
  final Api api;

  /// 开始发出请求时的回调事件
  final Function(Api api) onStart;

  /// 网络响应成功，服务器处理业务成功
  final Function(ResponseData response) onSuccess;

  /// 网络响应成功，但服务器处理业务失败
  final Function(ResponseData response) onFail;

  /// 网络请求响应错误时候的回调事件
  final Function(dynamic error) onError;

  /// 当捕捉到错误时的回调事件
  final Function onCatchError;

  /// 网络请求完成后的回调事件
  final Function(Api api) onCompleted;

  /// 请求发出时的进度变化回调事件
  final Function(int progress, int total) onSendProgress;

  /// 接收数据时的进度变化回调事件
  final Function(int progress, int total) onReceiveProgress;

  /// 注册网络请求器，并注入拦截器
  static void register(List<Interceptor> interceptors) {
    if (_dio == null) {
      _dio = new Dio();
      if (interceptors == null) return;
      for (var item in interceptors) {
        _dio.interceptors.add(item);
      }
    }
  }

  /// 如果你想抓包，需要设置网络代理地址
  static void setProxyUrl(String proxyUrl) {
    if (!_checkDio()) {
      return;
    }
    if (proxyUrl?.isNotEmpty ?? false) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.findProxy = (uri) {
          return "PROXY $proxyUrl";
        };
      };
    }
  }

  /// 允许请求器的内部打印
  static void logEnable() => Net.logEnable();

  /// 禁止请求器的内部打印
  static void logDisable() => Net.logDisable();

  Request(
      {@required this.api,
      this.onStart,
      this.onSuccess,
      this.onFail,
      this.onError,
      this.onCatchError,
      this.onSendProgress,
      this.onReceiveProgress,
      this.onCompleted}) {
    if (api == null) {
      Net.logFormat('*** api must not null! ***');
      return;
    }
    if (_checkDio()) _request();
  }

  static bool _checkDio() {
    if (_dio == null) {
      Net.logFormat(
          '*** you must use Request.register(interceptors) static method initialization dio instance at first ***');
      return false;
    }
    return true;
  }

  /// 发出网络请求
  _request() async {
    String method = _method(api.method);
    if (onStart != null) {
      onStart(api);
    } else {
      Net.logFormat('*** start request ***');
    }

    // 实体转json
    Map<String, dynamic> _body = json.decode(json.encode(api.body));

    await _dio
        .request(
          api.requestUrl(),
          data: api.method == Method.GET ? null : _body,
          queryParameters: api.method == Method.GET ? _body : null,
          // 取消请求的标记
          cancelToken: api.cancelToken,
          options: Options(
              method: method,
              connectTimeout: api.connectTimeout,
              sendTimeout: api.sendTimeout,
              receiveTimeout: api.receiveTimeout,
              headers: api.header,
              // 响应数据类型设置为json
              responseType: ResponseType.json,
              // 以application/x-www-form-urlencoded格式发送数据
              contentType: api.contentType,
              // 当状态错误时是否接收数据
              receiveDataWhenStatusError: true,
              // 允许重定向
              followRedirects: true,
              maxRedirects: 10000),
          onSendProgress: onSendProgress ?? onSendProgress ?? (p, t) {},
          onReceiveProgress:
              onReceiveProgress ?? onReceiveProgress ?? (p, t) {},
        )
        .then((response) {
          if (api.dataConvert == null) {
            api.dataConvert = (data) {
              return data;
            };
          }
          dynamic data = api.dataConvert(response.data);
          if (api.state(response.data)) {
            if (onSuccess != null) {
              onSuccess(ResponseData(metadata: response, data: data));
            }
          } else {
            if (onFail != null) {
              onFail(ResponseData(metadata: response, data: data));
            }
          }
        },
            onError: onError ??
                onError ??
                (error) {
                  Net.logFormat('*** request error : $error ***');
                })
        .catchError(onCatchError ??
            onCatchError ??
            (error) {
              Net.logFormat('*** catch error : $error ***');
            })
        .whenComplete(() {
          if (onCompleted != null) {
            onCompleted(api);
          } else {
            Net.logFormat('*** request done! ***');
          }
        });
  }

  /// Method 类型转换成 String 类型
  String _method(Method method) {
    String result = 'POST';
    switch (method) {
      case Method.GET:
        result = 'GET';
        break;
      case Method.POST:
        result = 'POST';
        break;
      case Method.PUT:
        result = 'PUT';
        break;
      case Method.DELETE:
        result = 'DELETE';
        break;
      case Method.HEAD:
        result = 'HEAD';
        break;
      case Method.PATCH:
        result = 'PATCH';
        break;
      default:
        result = 'POST';
        break;
    }
    return result;
  }
}
