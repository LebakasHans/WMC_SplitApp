import 'package:split_app/models/simple_group.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_provider.dart';

class GroupRepository {
  GroupRepository._privateConstructor();

  static final GroupRepository _instance =
      GroupRepository._privateConstructor();

  factory GroupRepository() {
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
}
