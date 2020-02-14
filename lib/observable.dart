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
    _transformer =
    StreamTransformer<S, T>.fromHandlers(handleData: (value, sink) {
      Request(
          api: value,
          onStart: (api) {
            _onSubscribe();
          },
          onSuccess: (response) {
            _onCompleted();
            deliver.applySuccess<T>(sink, response);
          },
          onFail: (response) {
            _onCompleted();
            deliver.applyFail<T>(sink, response);
          },
          onError: (error) {
            _onCompleted();
            deliver.applyError<T>(sink, error);
          },
          onCatchError: (error) {
            _onCompleted();
            deliver.applyCatchError<T>(sink, error);
          });
    });
  }

  void compose(StreamTransformer<S, T> transformer) {
    streamController.stream.transform(transformer);
  }

  void subscribe({void Function(T data) onData,
    void Function(dynamic error) onError,
    void Function(Observable observable) onDone,
    void Function() onSubscribe,
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
    streamController.stream
        .transform(_transformer)
        .listen(onData, onError: onError, onDone: () => onDone(this));
    streamController.add(api);
  }

  void subscribeSingle(
      {void Function(T data) onData, void Function(dynamic error) onError}) {
    subscribe(
        onData: onData, onError: onError, onDone: (observable) => dispose());
  }

  void dispose() {
    streamController.close();
  }
}
