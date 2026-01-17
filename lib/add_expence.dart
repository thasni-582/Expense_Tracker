import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expence_tracker_app/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String type = 'expense';
  String category = 'Food';
  DateTime selectedDate = DateTime.now();

  final List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Salary',
    'Other',
  ];

  // 🔹 CATEGORY ICON
  IconData getCategoryIcon() {
    switch (category) {
      case 'Food':
        return Icons.fastfood;
      case 'Transport':
        return Icons.directions_bus;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills':
        return Icons.receipt_long;
      case 'Entertainment':
        return Icons.movie;
      case 'Health':
        return Icons.local_hospital;
      default:
        return Icons.category;
    }
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<void> saveTransaction() async {
    final title = titleController.text.trim();
    final amountText = amountController.text.trim();

    if (title.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter valid amount')));
      return;
    }

    try {
      await firestore.collection('transaction').add({
        'title': title,
        'amount': amount,
        'type': type, // income / expense
        'category': category,
        'date': Timestamp.fromDate(selectedDate),
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction saved successfully')),
      );

      // Clear fields
      titleController.clear();
      amountController.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      ); // back to home
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 💰 AMOUNT
            _card(
              child: Row(
                children: [
                  _iconBox(Icons.currency_rupee),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 📝 TITLE
            _card(
              child: Row(
                children: [
                  _iconBox(Icons.title),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 📂 CATEGORY (FIXED ICON + DROPDOWN)
            _card(
              child: Row(
                children: [
                  _iconBox(getCategoryIcon()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: category,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() => category = v!);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 📅 DATE
            InkWell(
              onTap: _pickDate,
              child: _card(
                child: Row(
                  children: [
                    _iconBox(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd MMM yyyy').format(selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🔄 TYPE TOGGLE
            _card(
              child: Row(
                children: [
                  _typeButton(
                    value: 'expense',
                    icon: Icons.arrow_upward,
                    text: 'EXPENSE',
                    color: Colors.red,
                  ),
                  const SizedBox(width: 12),
                  _typeButton(
                    value: 'income',
                    icon: Icons.arrow_downward,
                    text: 'INCOME',
                    color: Colors.green,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 💾 SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text(
                  'Save Transaction',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: saveTransaction,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 ICON BOX
  Widget _iconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.black54),
    );
  }

  // 🔹 TYPE BUTTON
  Widget _typeButton({
    required String value,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    final selected = type == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => type = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? color : Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? color : Colors.grey),
              const SizedBox(height: 6),
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 DATE PICKER
  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // 🔹 CARD
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: child,
    );
  }
}
