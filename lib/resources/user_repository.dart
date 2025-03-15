import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:split_app/models/simple_api_result.dart';
import 'package:split_app/models/simple_group.dart';
import 'package:split_app/models/user.dart';
import 'api_provider.dart';

class UserRepository {
  UserRepository._privateConstructor();

  static final UserRepository _instance = UserRepository._privateConstructor();

  factory UserRepository() {
    return _instance;
  }

  final _provider = ApiProvider();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<List<User>> getFriends() async {
    List<User> result;
    try {
      final username = await _secureStorage.read(key: 'username');
      final password = await _secureStorage.read(key: 'password');

      var response = await _provider.getRequest(
        endpoint: '/users/friends',
        headers: {'username': username ?? '', 'password': password ?? ''},
      );

      result =
          (response.data as List).map((item) => User.fromJson(item)).toList();
    } on Exception {
      result = [];
    }

    return result;
  }

  Future<SimpleApiResult> addFriend(String friendUsername) async {
    try {
      final username = await _secureStorage.read(key: 'username');
      final password = await _secureStorage.read(key: 'password');

      var response = await _provider.postRequest(
        endpoint: '/users/friends',
        data: {'username': friendUsername},
        headers: {'username': username ?? '', 'password': password ?? ''},
      );

      var apiResult = SimpleApiResult.fromJson(
        Map<String, dynamic>.from(response.data),
        (_) {},
      );

      return apiResult;
    } on Exception catch (e) {
      return SimpleApiResult(
        isSuccess: false,
        result: e.toString().substring(11),
      );
    }
  }

  Future<SimpleApiResult> removeFriend(int friendId) async {
    try {
      final username = await _secureStorage.read(key: 'username');
      final password = await _secureStorage.read(key: 'password');

      var response = await _provider.deleteRequest(
        endpoint: '/users/friends/$friendId',
        headers: {'username': username ?? '', 'password': password ?? ''},
      );

      var apiResult = SimpleApiResult.fromJson(
        Map<String, dynamic>.from(response.data),
        (_) {},
      );

      return apiResult;
    } on Exception catch (e) {
      return SimpleApiResult(
        isSuccess: false,
        errorMessage: e.toString().substring(11),
        result: null,
      );
    }
  }

  Future<List<SimpleGroup>> getGroups() async {
    List<SimpleGroup> result;
    try {
      final username = await _secureStorage.read(key: 'username');
      final password = await _secureStorage.read(key: 'password');

      var response = await _provider.getRequest(
        endpoint: '/users/groups',
        headers: {'username': username ?? '', 'password': password ?? ''},
      );

      result =
          (response.data as List)
              .map((item) => SimpleGroup.fromJson(item))
              .toList();
    } on Exception {
      result = [];
    }

    return result;
  }

  Future<SimpleApiResult> createGroup(
    String groupName,
    List<int> memberIds,
  ) async {
    try {
      final username = await _secureStorage.read(key: 'username');
      final password = await _secureStorage.read(key: 'password');

      var response = await _provider.postRequest(
        endpoint: '/users/groups',
        data: {'groupname': groupName, 'memberIds': memberIds},
        headers: {'username': username ?? '', 'password': password ?? ''},
      );

      var apiResult = SimpleApiResult.fromJson(
        Map<String, dynamic>.from(response.data),
        (_) {},
      );

      return apiResult;
    } on Exception catch (e) {
      return SimpleApiResult(
        isSuccess: false,
        errorMessage: e.toString().substring(11),
        result: null,
      );
    }
  }
}
