import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:split_app/models/simple_group.dart';
import 'package:split_app/models/expense.dart';
import 'package:split_app/models/debt.dart';
import 'package:split_app/resources/expenses_repository.dart';
import 'package:split_app/pages/add_expense_page.dart';
import 'package:split_app/widgets/debts/debts_list_widget.dart';
import 'package:split_app/widgets/expenses/expenses_list_widget.dart';

class GroupDetailPage extends StatefulWidget {
  final SimpleGroup group;

  const GroupDetailPage({super.key, required this.group});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  late Future<List<Expense>> _expensesFuture;
  late Future<List<Debt>> _debtsFuture;
  final _expensesRepository = ExpensesRepository();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadExpenses();
    _loadDebts();
  }

  Future<void> _loadUserId() async {
    final userId = await _secureStorage.read(key: 'userId');

    setState(() {
      currentUserId = int.parse(userId ?? '-1');
    });
  }

  void _loadExpenses() {
    setState(() {
      _expensesFuture = _expensesRepository.getExpensesForGroup(
        widget.group.id,
      );
    });
  }

  void _loadDebts() {
    setState(() {
      _debtsFuture = _expensesRepository.getDebtsForGroup(widget.group.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.groupName)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Balance at the top
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                Text(
                  widget.group.groupName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.group.balance >= 0
                      ? "You get ${widget.group.balance.abs().toStringAsFixed(2)}€"
                      : "You owe ${widget.group.balance.abs().toStringAsFixed(2)}€",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        widget.group.balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text("Debts", style: Theme.of(context).textTheme.titleLarge),
          ),

          DebtsListWidget(
            debtsFuture: _debtsFuture,
            currentUserId: currentUserId,
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Expenses",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          Expanded(
            child: ExpensesListWidget(
              expensesFuture: _expensesFuture,
              currentUserId: currentUserId,
              onRefresh: () async {
                _loadExpenses();
                _loadDebts();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AddExpensePage(
                    groupId: widget.group.id,
                    currentUserId: currentUserId ?? -1,
                  ),
            ),
          );

          if (result == true) {
            _loadExpenses();
            _loadDebts();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
