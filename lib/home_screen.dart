import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expence_tracker_app/add_expence.dart';
import 'package:expence_tracker_app/profile_screen.dart';
import 'package:expence_tracker_app/transaction_model.dart';
import 'package:expence_tracker_app/transaction_screen%20.dart';

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/* =======================
   MAIN HOME WITH BOTTOM NAV
   ======================= */
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    HomeBody(),
    AddExpenseScreen(),
    TransactionScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        iconSize: 45,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.blueAccent),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet, color: Colors.blueAccent),
            label: 'AddExpence',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart, color: Colors.blueAccent),
            label: 'Transaction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.blueAccent),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/* =======================
   HOME BODY (OLD UI MOVED)
   ======================= */
class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  String searchText = '';
  final TextEditingController searchController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> get transactionStream => firestore
      .collection('transaction')
      .orderBy('date', descending: true)
      .snapshots();

  // 🔹 Income
  double calculateIncome(List<TransactionModel> list) {
    double total = 0;
    for (var t in list) {
      if (t.type == 'income') total += t.amount;
    }
    return total;
  }

  // 🔹 Expense
  double calculateExpense(List<TransactionModel> list) {
    double total = 0;
    for (var t in list) {
      if (t.type == 'expense') total += t.amount;
    }
    return total;
  }

  // 🔹 Info Card
  Widget infoCard({
    required String title,
    required double amount,
    required String image,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 40),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Transaction Tile
  Widget _transactionTile(TransactionModel t) {
    final isExpense = t.type == 'expense';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExpense ? Colors.red : Colors.green,
          child: Image.asset(
            isExpense ? 'assets/images3.png' : 'assets/image2.png',
            height: 22,
          ),
        ),
        title: Text(t.title),
        subtitle: Text(t.category),
        trailing: Wrap(
          spacing: 6,
          children: [
            Text(
              '${isExpense ? '-' : '+'}₹${t.amount}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isExpense ? Colors.red : Colors.green,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddExpenseScreen()),
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await firestore.collection('transaction').doc(t.id).delete();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/image1.jpg', height: 70),
                  const Icon(Icons.person, color: Colors.white, size: 30),
                ],
              ),
            ),

            // 🔹 BODY
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: transactionStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  final transactions = snapshot.data!.docs
                      .map((e) => TransactionModel.fromFirestore(e))
                      .toList();

                  final filtered = transactions.where((t) {
                    return t.title.toLowerCase().contains(searchText) ||
                        t.category.toLowerCase().contains(searchText);
                  }).toList();

                  final income = calculateIncome(transactions);
                  final expense = calculateExpense(transactions);
                  final balance = income - expense;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // 🔹 BALANCE
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              const Text('Total Balance'),
                              const SizedBox(height: 6),
                              Text(
                                '₹${balance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 🔹 INCOME / EXPENSE
                        Row(
                          children: [
                            infoCard(
                              title: 'Income',
                              amount: income,
                              image: 'assets/image2.png',
                              color: Colors.green,
                            ),
                            const SizedBox(width: 12),
                            infoCard(
                              title: 'Expense',
                              amount: expense,
                              image: 'assets/images3.png',
                              color: Colors.red,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 🔹 SEARCH
                        TextField(
                          controller: searchController,
                          onChanged: (v) {
                            setState(() => searchText = v.toLowerCase());
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Search transactions...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: searchText.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      searchController.clear();
                                      setState(() => searchText = '');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 🔹 TRANSACTIONS
                        filtered.isEmpty
                            ? const Text(
                                'No transactions found',
                                style: TextStyle(color: Colors.white),
                              )
                            : Column(
                                children: filtered
                                    .map(_transactionTile)
                                    .toList(),
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
