import 'package:flutter/material.dart';
import 'package:split_app/models/expense_dto.dart';
import 'package:split_app/models/group_member.dart';
import 'package:split_app/resources/expenses_repository.dart';
import 'package:split_app/widgets/expenses/participant_slider_widget.dart';

class AddExpensePage extends StatefulWidget {
  final int groupId;
  final int currentUserId;

  const AddExpensePage({
    super.key,
    required this.groupId,
    required this.currentUserId,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final _expensesRepository = ExpensesRepository();

  late Future<List<GroupMember>> _membersFuture;
  int? _paidById;
  final Map<int, double> _participantShares = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _paidById = widget.currentUserId;
    _loadGroupMembers();
  }

  void _loadGroupMembers() {
    _membersFuture = _expensesRepository.getGroupMembers(widget.groupId);
    _membersFuture.then((members) {
      if (members.isNotEmpty) {
        // Initialize with equal shares
        final equalShare = 1.0 / members.length;
        setState(() {
          for (var member in members) {
            _participantShares[member.id] = equalShare;
          }
        });
      }
    });
  }

  void _setEqualShares(List<GroupMember> members) {
    final equalShare = 1.0 / members.length;
    setState(() {
      for (var member in members) {
        _participantShares[member.id] = equalShare;
      }
    });
  }

  Future<void> _saveExpense() async {
    // Validate inputs
    if (_descriptionController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _paidById == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // Check if shares sum up to approximately 1.0 (allowing for floating point errors)
    final totalShare = _participantShares.values.fold(
      0.0,
      (sum, share) => sum + share,
    );
    if (totalShare < 0.99 || totalShare > 1.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The sum of all shares should be 100%')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create participant shares list
      final participantSharesList =
          _participantShares.entries
              .map(
                (entry) => ParticipantShareDto(
                  participantId: entry.key,
                  share: entry.value * amount,
                ),
              )
              .toList();

      // Create expense DTO
      final expenseDto = ExpenseDto(
        description: _descriptionController.text,
        amount: amount,
        paidById: _paidById!,
        participantShares: participantSharesList,
      );

      // Submit expense
      final success = await _expensesRepository.addExpense(
        widget.groupId,
        expenseDto,
      );

      if (!mounted) return;

      if (success) {
        // Return true to indicate successful addition
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to add expense')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveExpense,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<GroupMember>>(
                future: _membersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No group members found'));
                  }

                  final members = snapshot.data!;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description input
                        TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'e.g., Dinner, Movie tickets',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Amount input
                        TextField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount (€)',
                            hintText: '0.00',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.euro),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Paid by dropdown
                        Text(
                          'Paid by:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          value: _paidById,
                          items:
                              members.map((member) {
                                return DropdownMenuItem<int>(
                                  value: member.id,
                                  child: Text(member.username),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _paidById = value;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Split options
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Split:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.balance),
                              label: const Text('Equal Split'),
                              onPressed: () => _setEqualShares(members),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Split sliders
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children:
                                  members.map((member) {
                                    return ParticipantSliderWidget(
                                      member: member,
                                      share:
                                          _participantShares[member.id] ?? 0.0,
                                      onChanged: (value) {
                                        setState(() {
                                          _participantShares[member.id] = value;
                                        });
                                      },
                                      amount: double.tryParse(
                                        _amountController.text,
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
