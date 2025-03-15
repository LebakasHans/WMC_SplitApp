import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:split_app/models/simple_api_result.dart';
import 'package:split_app/models/simple_group.dart';
import 'package:split_app/models/create_group_request.dart';
import 'package:split_app/models/user.dart';
import 'api_provider.dart';

class GroupsRepository {
  GroupsRepository._privateConstructor();

  static final GroupsRepository _instance =
      GroupsRepository._privateConstructor();

  factory GroupsRepository() {
    return _instance;
  }

  final _provider = ApiProvider();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<List<SimpleGroup>> getGroups() async {
    List<SimpleGroup> result;
    try {
      final username = await _secureStorage.read(key: 'username');
      final password = await _secureStorage.read(key: 'password');

      var response = await _provider.getRequest(
        endpoint: '/groups',
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

      final request = CreateGroupRequest(
        groupname: groupName,
        memberIds: memberIds,
      );

      var response = await _provider.postRequest(
        endpoint: '/groups',
        data: request.toJson(),
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

  Future<List<User>> getMembers(int groupId) async {
    try {
      final username = await _secureStorage.read(key: 'username');
      final password = await _secureStorage.read(key: 'password');

      var response = await _provider.getRequest(
        endpoint: '/groups/$groupId/members',
        headers: {'username': username ?? '', 'password': password ?? ''},
      );

      return (response.data as List)
          .map((item) => User.fromJson(item))
          .toList();
    } on Exception {
      return [];
    }
  }
}
