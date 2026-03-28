import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

/// 开销记录表单组件
class ExpenseForm extends StatefulWidget {
  final Expense? expense; // 编辑时传入现有记录
  final Function(Expense) onSave;

  const ExpenseForm({
    super.key,
    this.expense,
    required this.onSave,
  });

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  String _selectedType = defaultExpenseTypes.first;
  double _amount = 0;
  double _mileage = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.expense != null
        ? DateTime.parse(widget.expense!.date)
        : DateTime.now();
    _selectedType = widget.expense?.type ?? defaultExpenseTypes.first;
    _amount = widget.expense?.amount ?? 0;
    _mileage = widget.expense?.mileage ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.expense != null ? '编辑记录' : '添加记录',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // 日期选择
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '日期',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
              ),
            ),
            const SizedBox(height: 12),

            // 类型选择
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(labelText: '费用类型'),
              items: defaultExpenseTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedType = value!);
              },
            ),
            const SizedBox(height: 12),

            // 金额输入
            TextFormField(
              initialValue: widget.expense?.amount.toString() ?? '',
              decoration: const InputDecoration(
                labelText: '金额（元）',
                prefixText: '¥',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return '请输入金额';
                if (double.tryParse(value) == null) return '请输入有效数字';
                return null;
              },
              onSaved: (value) => _amount = double.parse(value!),
            ),
            const SizedBox(height: 12),

            // 里程输入
            TextFormField(
              initialValue: widget.expense?.mileage.toString() ?? '',
              decoration: const InputDecoration(
                labelText: '新增里程（公里）',
                suffixText: 'km',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return '请输入里程';
                if (double.tryParse(value) == null) return '请输入有效数字';
                return null;
              },
              onSaved: (value) => _mileage = double.parse(value!),
            ),
            const SizedBox(height: 24),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final expense = Expense(
        id: widget.expense?.id,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        type: _selectedType,
        amount: _amount,
        mileage: _mileage,
      );

      widget.onSave(expense);
    }
  }
}