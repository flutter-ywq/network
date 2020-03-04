import 'dart:async';
import 'package:network/deliver.dart';
import 'package:network/utils/logger.dart';
import 'network/api.dart';
import 'network/requester.dart';

/// @description Observable
///
/// @author 燕文强
///
/// @date 2019-12-30
class Observable<S extends Api, T> {
  final StreamController<S> streamController = StreamController<S>();
  StreamTransformer<S, T> _transformer;
  final S api;
  Deliver deliver;
  Function() _onSubscribe;
  Function() _onCompleted;

  Observable({this.api, this.deliver}) {
    _transformer = StreamTransformer<S, T>.fromHandlers(handleData: (value, sink) {
      Request(
          api: value,
          onStart: (api) {
            if (_onSubscribe != null) {
              _onSubscribe();
            }
          },
          onSuccess: (response) {
            _callOnCompleted();
            deliver.applySuccess<T>(sink, response);
          },
          onFail: (response) {
            _callOnCompleted();
            deliver.applyFail<T>(sink, response);
          },
          onError: (error) {
            _callOnCompleted();
            deliver.applyError<T>(sink, error);
          },
          onCatchError: (error) {
            _callOnCompleted();
            deliver.applyCatchError<T>(sink, error);
          });
    });
  }

  void _callOnCompleted() {
    if (_onCompleted != null) {
      _onCompleted();
    }
  }

  void compose(StreamTransformer<S, T> transformer) {
    streamController.stream.transform(transformer);
  }

  void subscribe(
      {void Function() onSubscribe,
      void Function(T data) onData,
      void Function(dynamic error) onError,
      void Function() onCompleted}) {
    if (_transformer == null) {
      Net.logFormat('_transformer cannot be empty');
      return;
    }
    if (deliver == null) {
      deliver = ApiDeliver();
    }
    _onSubscribe = onSubscribe;
    _onCompleted = onCompleted;
    streamController.stream.transform(_transformer).listen(onData, onError: onError, onDone: () => dispose());
    streamController.add(api);
  }

  void dispose() {
    streamController.close();
  }
}
