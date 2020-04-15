# network

flutter network

## 使用

### yaml
``` dart

  network:
    git: https://github.com/flutter-ywq/network.git
    
```

### 发送请求
``` dart

class AccountApi<R> extends ApplicationApi {
  /// 用户登录
  static Api login(LoginReq params) => AccountApi<LoginRespEntity>()
    ..path = 'api/login'
    ..body = params
    ..dataConvert = (data) => JsonConvert.fromJsonAsT<LoginRespEntity>(data);
}

class LoginModel extends LoginContractModel {
  @override
  Observable<AccountApi, LoginRespEntity> login(BuildContext context, String staffNo, String password) {
    LoginReq reqParam = LoginReq()
      ..account = staffNo
      ..password = password;
    return Observable<AccountApi, LoginRespEntity>(api: AccountApi.loginTab(reqParam), deliver: LearningUIDeliver(context));
  }
}

class LoginPresenter extends LoginContractPresenter {
  LoginPresenter(LoginContractView view, LoginContractModel model)
      : super(view, model);

  @override
  void login(String staffNo, String password) {
    model.login(view.getContext(), staffNo, password).subscribe(onSubscribe: () {
      // 弹出加载框
      Loading.show(view.getContext(), '账号登录中...');
    }, onData: (data) {
      // 保存用户信息并跳转页面
    }, onError: (error) {
      view.update(tag: 'loginFail', params: error.toString());
    }, onCompleted: () {
      // 取消加载框
      Loading.cancel(view.getContext());
    });
  }
}

```

## Packages

### network - 网络请求模块
- api - 描述一个请求的配置，如：url、parameters、header、timeout、method，响应数据的数据转换等
- requester - 发出api请求对象，提供了请求开始，进度变化、请求成功/失败，响应成功/失败的回调方法

### utils - 实用工具
- logger - NetWork的打印工具
- deliver - 数据交付者，applySuccess、applyFail、applyError、applyCatchError
- observable - 提供数据转换和数据交付
