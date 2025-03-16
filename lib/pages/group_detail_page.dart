import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:split_app/models/simple_group.dart';
import 'package:split_app/models/expense.dart';
import 'package:split_app/models/debt.dart';
import 'package:split_app/resources/expenses_repository.dart';
import 'package:split_app/pages/add_expense_page.dart';
import 'package:split_app/widgets/debts/debts_list_widget.dart';
import 'package:split_app/widgets/expenses/expenses_list_widget.dart';
import 'package:split_app/resources/groups_repository.dart';
import 'package:split_app/widgets/shared/empty_state_widget.dart';

class GroupDetailPage extends StatefulWidget {
  final SimpleGroup group;

  const GroupDetailPage({super.key, required this.group});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  late Future<Map<String, dynamic>> _dataFuture;
  final _expensesRepository = ExpensesRepository();
  final _groupsRepository = GroupsRepository();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late ValueNotifier<SimpleGroup> _groupNotifier;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _groupNotifier = ValueNotifier(widget.group);
    _loadUserId();
    _loadData();
  }

  Future<void> _loadUserId() async {
    final userId = await _secureStorage.read(key: 'userId');
    setState(() {
      currentUserId = int.parse(userId ?? '-1');
    });
  }

  void _loadData() {
    setState(() {
      _dataFuture = Future.wait([
        _expensesRepository.getExpensesForGroup(_groupNotifier.value.id),
        _expensesRepository.getDebtsForGroup(_groupNotifier.value.id),
        _groupsRepository.getGroup(_groupNotifier.value.id),
      ]).then((results) {
        _groupNotifier.value = _groupNotifier.value.copyWith(
          balance: (results[2] as SimpleGroup).balance,
        );
        return {'expenses': results[0], 'debts': results[1]};
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<SimpleGroup>(
          valueListenable: _groupNotifier,
          builder:
              (context, group, _) => Text(
                group.groupName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
        ),
        elevation: 0, // Removes shadow for a cleaner look
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading group data',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          }

          final expenses = snapshot.data!['expenses'] as List<Expense>;
          final debts = snapshot.data!['debts'] as List<Debt>;

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: CustomScrollView(
              slivers: [
                // Group Header
                SliverToBoxAdapter(
                  child: ValueListenableBuilder<SimpleGroup>(
                    valueListenable: _groupNotifier,
                    builder:
                        (context, group, _) => Container(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.2),
                                child: Icon(
                                  Icons.group,
                                  size: 40,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                group.groupName,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              _buildBalanceCard(group),
                            ],
                          ),
                        ),
                  ),
                ),

                // Debts Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          "Active Debts",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                // Debts List
                SliverToBoxAdapter(
                  child:
                      debts.isEmpty
                          ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No active debts in this group.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          )
                          : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: DebtsListWidget(
                              debts: debts,
                              currentUserId: currentUserId,
                            ),
                          ),
                ),

                // Expenses Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          "Expenses",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                // Expenses List
                expenses.isEmpty
                    ? SliverFillRemaining(
                      child: EmptyStateWidget(
                        icon: Icons.receipt,
                        title: 'No Expenses Yet',
                        message:
                            'Add your first expense to start tracking group finances.',
                        actionButton: ElevatedButton.icon(
                          onPressed: () => _addNewExpense(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Expense'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    )
                    : SliverFillRemaining(
                      child: ExpensesListWidget(
                        expenses: expenses,
                        currentUserId: currentUserId,
                        onRefresh: () async => _loadData(),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Future<void> _addNewExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddExpensePage(
              groupId: _groupNotifier.value.id,
              currentUserId: currentUserId ?? -1,
            ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Widget _buildBalanceCard(SimpleGroup group) {
    final isPositive = group.balance >= 0;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            Text(
              'Your Balance',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  isPositive
                      ? "You get ${group.balance.abs().toStringAsFixed(2)}€"
                      : "You owe ${group.balance.abs().toStringAsFixed(2)}€",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _groupNotifier.dispose();
    super.dispose();
  }
}
