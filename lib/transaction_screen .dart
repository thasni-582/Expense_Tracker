import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expence_tracker_app/transaction_model.dart';
import 'package:flutter/material.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String selectedType = 'all'; // all | income | expense
  String searchText = '';
  final TextEditingController searchController = TextEditingController();

  Stream<QuerySnapshot> get transactionStream => firestore
      .collection('transaction')
      .orderBy('date', descending: true)
      .snapshots();

  // 🔹 Filter Button
  Widget filterButton(String title, String type) {
    final isSelected = selectedType == type;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      onPressed: () {
        setState(() {
          selectedType = type;
        });
      },
      child: Text(title),
    );
  }

  // 🔹 Transaction Tile
  Widget transactionTile(TransactionModel t) {
    final isExpense = t.type == 'expense';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExpense ? Colors.red : Colors.green,
          child: Icon(
            isExpense ? Icons.arrow_upward : Icons.arrow_downward,
            color: Colors.white,
          ),
        ),
        title: Text(t.title),
        subtitle: Text(t.category),
        trailing: Text(
          '${isExpense ? '-' : '+'}₹${t.amount}',
          style: TextStyle(
            color: isExpense ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'All Transaction',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ),
            // 🔍 SEARCH
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: searchController,
                onChanged: (v) {
                  setState(() => searchText = v.toLowerCase());
                },
                decoration: InputDecoration(
                  hintText: 'Search by title or category',
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
                  ),
                ),
              ),
            ),

            // 🔘 FILTER BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  filterButton('All', 'all'),
                  filterButton('Income', 'income'),
                  filterButton('Expense', 'expense'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 🔹 TRANSACTION LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: transactionStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allTransactions = snapshot.data!.docs
                      .map((e) => TransactionModel.fromFirestore(e))
                      .toList();

                  // 🔥 FILTER LOGIC
                  final filteredByType = selectedType == 'all'
                      ? allTransactions
                      : allTransactions
                            .where((t) => t.type == selectedType)
                            .toList();

                  final finalList = filteredByType.where((t) {
                    return t.title.toLowerCase().contains(searchText) ||
                        t.category.toLowerCase().contains(searchText);
                  }).toList();

                  if (finalList.isEmpty) {
                    return const Center(child: Text('No transactions found'));
                  }

                  return ListView.builder(
                    itemCount: finalList.length,
                    itemBuilder: (context, index) {
                      return transactionTile(finalList[index]);
                    },
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
