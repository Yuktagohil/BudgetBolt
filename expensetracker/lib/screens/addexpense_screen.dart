import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transactionhistory_screen.dart';
import 'home_screen.dart';
import 'budget_screen.dart';
import 'navbar.dart';
import '../Models/auth_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();
  List<Map<String, dynamic>> _expenses = [];

  String _selectedCurrency = 'Euro'; // Default currency is Euro
  Map<String, String> _currencyIcons = {
    'Euro': '€',
    'Dollar': '\$',
    'Rupee': '₹',
  };

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<List<Map<String, dynamic>>> _fetchExpenses() async {
  try {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    var expensesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();

    return expensesSnapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    print('Error fetching expenses: $e');
    return []; // Return an empty list if there's an error to avoid null errors in the FutureBuilder
  }
}


  void _addExpense() async {
  final form = _formKey.currentState;
  if (form != null && form.validate()) {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String amountText = _amountController.text.replaceAll('\$', '');
      double amount = double.parse(amountText);

      await FirebaseFirestore.instance.collection('users').doc(userId).collection('expenses').add({
        'currency': _selectedCurrency,
        'amount': amount,
        'date': _dateController.text,
        'category': _categoryController.text,
        'notes': _notesController.text,
      });

      _amountController.clear();
      _dateController.clear();
      _categoryController.clear();
      _notesController.clear();

      Navigator.pop(context); // Close the dialog box after adding expense

      _fetchExpenses().then((expenses) {
        setState(() {
          _expenses = expenses; // Update the expenses list with the new expense
        });
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Expense Added'),
          content: Text('Expense has been successfully added.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error adding expense: $e');
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
        leading: IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () {
            // Handle the action when the user account icon is tapped.
            // You can navigate to the user's profile screen or any other screen as needed.
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Implement logout functionality here
              AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();

              // Navigate to the SignupScreen after signing out
              Navigator.pushReplacementNamed(context, '/signup');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
  future: _fetchExpenses(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (snapshot.hasError) {
      return Center(
        child: Text('Error fetching expenses'),
      );
    } else {
      List<Map<String, dynamic>> expenses = snapshot.data ?? [];
      return ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          var expense = expenses[index];
          String currency = expense['currency'] ?? ''; // Provide a default value if 'currency' is null
          String amount = expense['amount']?.toStringAsFixed(2) ?? ''; // Provide a default value if 'amount' is null
          String date = expense['date'] ?? ''; // Provide a default value if 'date' is null
          String category = expense['category'] ?? ''; // Provide a default value if 'category' is null
          String notes = expense['notes'] ?? ''; // Provide a default value if 'notes' is null

          String currencyIcon = _currencyIcons[currency] ?? '';
          return Card(
            child: ListTile(
              title: Text('Amount: $currencyIcon${expense['amount']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${expense['date']}'),
                  Text('Category: ${expense['category']}'),
                  Text('Notes: ${expense['notes']}'),
                ],
              ),
            ),
          );
        },
      );
    }
  },
),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Add Expense'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Amount'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the amount.';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedCurrency,
                        onChanged: (value) {
                          setState(() {
                            _selectedCurrency = value!;
                          });
                        },
                        items: _currencyIcons.keys
                            .map((currency) => DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(currency),
                                ))
                            .toList(),
                        decoration: InputDecoration(labelText: 'Currency'),
                      ),
                      TextFormField(
                        controller: _dateController,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(labelText: 'Date'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the date.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(labelText: 'Category'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the category.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: InputDecoration(labelText: 'Notes'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
                ElevatedButton(
                  onPressed: _addExpense,
                  child: Text('Add Expense'),
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 1,
        onTap: (index) {
          // Handle navigation when an item is tapped
          if (index == 0) {
            // Navigate to the home screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else if (index == 2) {
            // Navigate to the budget screen
            // Replace 'BudgetScreen()' with the actual widget for the budget screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BudgetScreen()),
            );
          } else if (index == 3) {
            // Navigate to the transaction history screen
            // Replace 'NotificationScreen()' with the actual widget for the transaction history screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationScreen()),
            );
          }
        },
      ),
    );
  }
}
