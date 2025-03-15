import 'package:split_app/models/simple_api_result.dart';
import 'package:split_app/models/user.dart';

import 'api_provider.dart';

class AuthRepository {
  AuthRepository._privateConstructor();

  static final AuthRepository _instance = AuthRepository._privateConstructor();

  factory AuthRepository() {
    return _instance;
  }

  final _provider = ApiProvider();

  Future<SimpleApiResult<User>> login(String username, String password) async {
    final loginData = {'username': username, 'password': password};

    SimpleApiResult<User> result;
    try {
      var response = await _provider.postRequest(
        endpoint: '/auth/login',
        data: loginData,
      );

      result = SimpleApiResult.fromJson<User>(
        Map<String, dynamic>.from(response.data),
        (x) => User.fromMap(x),
      );
    } on Exception catch (e) {
      result = SimpleApiResult.error(e.toString().substring(11));
    }

    return result;
  }

  Future<SimpleApiResult<User>> register(
    String username,
    String password,
  ) async {
    final registerData = {'username': username, 'password': password};

    SimpleApiResult<User> result;
    try {
      var response = await _provider.postRequest(
        endpoint: '/auth/register',
        data: registerData,
      );

      result = SimpleApiResult.fromJson<User>(
        Map<String, dynamic>.from(response.data),
        (x) => User.fromMap(x),
      );
    } on Exception catch (e) {
      result = SimpleApiResult.error(e.toString().substring(11));
    }

    return result;
  }
}
