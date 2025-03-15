import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:split_app/models/expense.dart';
import 'package:split_app/models/debt.dart';
import 'package:split_app/models/expense_dto.dart';
import 'package:split_app/models/group_member.dart';
import 'package:split_app/resources/api_provider.dart';

class ExpensesRepository {
  final ApiProvider _apiClient = ApiProvider();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<List<Expense>> getExpensesForGroup(int groupId) async {
    try {
      final username = await _secureStorage.read(key: 'username');
      final password = await _secureStorage.read(key: 'password');

      final response = await _apiClient.getRequest(
        endpoint: '/expenses/groups/$groupId/expenses',
        headers: {'username': username ?? '', 'password': password ?? ''},
      );

      log('Expenses response: $response');

      return (response.data as List<dynamic>)
          .map(
            (expenseJson) =>
                Expense.fromJson(expenseJson as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      log('Error getting expenses: $e');
      return [];
    }
  }

  Future<List<Debt>> getDebtsForGroup(int groupId) async {
    try {
      final username = await _secureStorage.read(key: 'username');
      final password = await _secureStorage.read(key: 'password');

      final response = await _apiClient.getRequest(
        endpoint: '/expenses/groups/$groupId/debts',
        headers: {'username': username ?? '', 'password': password ?? ''},
      );

      log('Debts response: $response');

      return (response.data as List<dynamic>)
          .map((debtJson) => Debt.fromJson(debtJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error getting debts: $e');
      return [];
    }
  }

  Future<bool> addExpense(int groupId, ExpenseDto expenseDto) async {
    try {
      final username = await _secureStorage.read(key: 'username');
      final password = await _secureStorage.read(key: 'password');

      var result = await _apiClient.postRequest(
        endpoint: '/expenses/groups/$groupId',
        data: expenseDto.toJson(),
        headers: {'username': username ?? '', 'password': password ?? ''},
      );

      log(result.data);

      return true;
    } catch (e) {
      log('Error adding expense: $e');
      return false;
    }
  }

  Future<List<GroupMember>> getGroupMembers(int groupId) async {
    try {
      final username = await _secureStorage.read(key: 'username');
      final password = await _secureStorage.read(key: 'password');

      final response = await _apiClient.getRequest(
        endpoint: '/groups/$groupId/members',
        headers: {'username': username ?? '', 'password': password ?? ''},
      );

      return (response.data as List<dynamic>)
          .map(
            (memberJson) =>
                GroupMember.fromJson(memberJson as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      log('Error getting group members: $e');
      return [];
    }
  }
}
