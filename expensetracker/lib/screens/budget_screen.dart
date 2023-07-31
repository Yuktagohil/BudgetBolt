import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transactionhistory_screen.dart';
import 'home_screen.dart';
import 'addexpense_screen.dart';
import 'navbar.dart';
import '../Models/auth_provider.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<Budget> budgets = [];
  String userId = ''; // To store the User ID
  String? selectedCurrency; // To store the selected currency
  bool _isMounted = false;
  CollectionReference budgetsRef = FirebaseFirestore.instance.collection('users/userid/budget');
  String category = ''; // Store the current category being processed
  double totalAmount = 0.0; // Store the total amount for the current category

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    // Get the current user ID when the widget initializes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (_isMounted && user != null) {
        setState(() {
          userId = user.uid;
        });
        // Load the user's budget data from Firestore
        _loadBudgetData();
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budgets Screen'),
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
      bottomNavigationBar: NavBar(
        currentIndex: 2,
        onTap: (index) {
          // Handle navigation when an item is tapped
          if (index == 0) {
            // Navigate to the home screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else if (index == 1) {
            // Navigate to the add expense screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddExpenseScreen()),
            );
          } else if (index == 3) {
            // Navigate to the transaction history screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationScreen()),
            );
          }
        },
      ),
      body: ListView.builder(
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final budget = budgets[index];
          double remaining = budget.budgetLimit - budget.spentAmount;
          if (remaining < 0) {
          remaining = 0.00;
        }

          return Card(
            child: ListTile(
              title: Text(budget.category),
              subtitle:
                  Text('Spent: \$${budget.spentAmount.toStringAsFixed(2)} Remaining: \$${remaining.toStringAsFixed(2)}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCategoryDialog(context); // Open the dialog box to add a new category
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
  String category = '';
  double budgetLimit = 0.0;
  String? selectedCurrency;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add Category and Budget Limit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                category = value;
              },
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                budgetLimit = double.tryParse(value) ?? 0.0;
              },
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Budget Limit'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCurrency,
              onChanged: (value) {
                setState(() {
                  selectedCurrency = value;
                });
              },
              items: [
                DropdownMenuItem(
                  value: 'Please select an option',
                  child: Text('Please select an option'),
                ),
                DropdownMenuItem(
                  value: 'Euro',
                  child: Text('Euro'),
                ),
                DropdownMenuItem(
                  value: 'Dollar',
                  child: Text('Dollar'),
                ),
                DropdownMenuItem(
                  value: 'Rupee',
                  child: Text('Rupee'),
                ),
              ],
              decoration: InputDecoration(labelText: 'Select Currency'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Add the budget category to the list and close the dialog
              setState(() {
                budgets.add(Budget(category, budgetLimit, 0.0, selectedCurrency));
              });
              
              // Save the budget data in Firestore
              await _saveBudgetData(category, budgetLimit);

              // Fetch and update the total spent amount for this budget category
              double spentAmount = await _fetchCategoryExpenseTotal(category);
              setState(() {
                // Update the spent amount for the budget category
                budgets.firstWhere((budget) => budget.category == category).spentAmount = spentAmount;
              });

              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      );
    },
  );
}

Future<void> _saveBudgetData(String category, double budgetLimit) async {
    try {
      // Construct the path to the user's budget data
      String budgetPath = 'users/$userId/budget';

      // Save the budget data in Firestore
      await FirebaseFirestore.instance.collection(budgetPath).doc(category).set({
        'category': category,
        'budgetLimit': budgetLimit,
      });
    } catch (e) {
      // Handle errors, if any
      print('Error saving budget data: $e');
    }
  }

  Future<void> _loadBudgetData() async {
  // try {
    // Construct the path to the user's budget data
    Set<String> uniqueCategories = {};

    // Fetch the user's budget data from Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).collection('budget').get();

    // Clear existing budgets list
    setState(() {
      budgets.clear();
    });

    // Add budget data from Firestore to the budgets list
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      Budget budget = Budget(data['category'], data['budgetLimit'], 0.0, data['currency']);
      budgets.add(budget);
      uniqueCategories.add(data['category']); // Add the category to the Set
    }

    // Convert the Set of unique categories back to a list
    List<String> uniqueCategoryList = uniqueCategories.toList();

    // Update the spent amount for each unique budget category
    for (var category in uniqueCategoryList) {
      double spentAmount = await _fetchCategoryExpenseTotal(category);
      setState(() {
        Budget budget = budgets.firstWhere((b) => b.category == category);
        budget.spentAmount = spentAmount;
      });
    }
  // } catch (e) {
  //   // Handle errors, if any
  //   print('Error loading budget data:');
  // }
// }
  }

Future<double> _fetchCategoryExpenseTotal(String category) async {
  double totalAmount = 0.0;

  // Assuming you have a Firestore collection named 'expense' with a field 'amount' for each expense entry
  String userId = FirebaseAuth.instance.currentUser!.uid;
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
       .doc(userId)
       .collection('expenses')
      .where('category', isEqualTo: category)
      .get();

  for (var doc in snapshot.docs) {
    totalAmount += doc['amount'] ?? 0.0;
  }
  

  return totalAmount;
  print("Fetching expenses for category: $category");

}

}

// No changes to the Budget class
class Budget {
  String category;
  double budgetLimit;
  double spentAmount;
  String? selectedCurrency;

  Budget(this.category, this.budgetLimit, this.spentAmount, this.selectedCurrency);
}
