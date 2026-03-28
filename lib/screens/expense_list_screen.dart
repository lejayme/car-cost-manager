import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../widgets/expense_form.dart';

/// 开销记录列表页面
class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    return Stack(
      children: [
        provider.expenses.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('暂无记录', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),
                    const Text('点击右下角按钮添加开销记录'),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: provider.expenses.length,
                itemBuilder: (context, index) {
                  final expense = provider.expenses[index];
                  return _ExpenseTile(
                    expense: expense,
                    onDelete: () => _deleteExpense(context, expense),
                    onEdit: () => _showEditDialog(context, expense),
                  );
                },
              ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _showAddDialog(context),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ExpenseForm(
          onSave: (expense) {
            context.read<ExpenseProvider>().addExpense(expense);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ExpenseForm(
          expense: expense,
          onSave: (updated) {
            context.read<ExpenseProvider>().updateExpense(updated);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _deleteExpense(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 ${expense.type} 的记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<ExpenseProvider>().deleteExpense(expense.id!);
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 开销记录列表项
class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ExpenseTile({
    required this.expense,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getTypeColor(expense.type).withValues(alpha: 0.2),
          child: Text(
            expense.type.substring(0, 1),
            style: TextStyle(color: getTypeColor(expense.type)),
          ),
        ),
        title: Text(expense.type),
        subtitle: Text(
          '${expense.date} | ${expense.mileage} km',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¥${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('编辑')),
                const PopupMenuItem(value: 'delete', child: Text('删除')),
              ],
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}