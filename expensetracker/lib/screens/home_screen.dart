import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../Models/auth_provider.dart';
import 'budget_screen.dart';
import 'addexpense_screen.dart';
import 'transactionhistory_screen.dart';
import 'navbar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFirstTime = true;
  double totalIncome = 0.0;
  double totalSaved = 0.0;
  double savingsProgress = 0.0;
  double todayExpenses = 0.0;
  double monthlyExpenses = 0.0;
  double juneExpenses = 0.0;
  double julyExpenses = 0.0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    String userId = Provider.of<AuthProvider>(context, listen: false).getCurrentUserId();

    setState(() {
      isFirstTime = true;
    });

    // Fetch the user's expenses
    CollectionReference expensesCollection = FirebaseFirestore.instance.collection('users').doc(userId).collection('expenses');
    QuerySnapshot expensesSnapshot = await expensesCollection.get();

    // Calculate today's date in the format "mm/dd/yyyy"
    String todayDate = DateFormat('MM/dd/yyyy').format(DateTime.now());

    // Calculate the first day and last day of the current month in the format "mm/dd/yyyy"
    DateTime currentDate = DateTime.now();
    DateTime firstDayOfTheMonth = DateTime(currentDate.year, currentDate.month, 1);
    DateTime lastDayOfTheMonth = DateTime(currentDate.year, currentDate.month + 1, 0);
    String firstDayOfTheMonthDate = DateFormat('MM/dd/yyyy').format(firstDayOfTheMonth);
    String lastDayOfTheMonthDate = DateFormat('MM/dd/yyyy').format(lastDayOfTheMonth);

    // Calculate the first day and last day of June in the format "mm/dd/yyyy"
    DateTime firstDayOfJune = DateTime(currentDate.year, 6, 1);
    DateTime lastDayOfJune = DateTime(currentDate.year, 7, 0);
    String firstDayOfJuneDate = DateFormat('MM/dd/yyyy').format(firstDayOfJune);
    String lastDayOfJuneDate = DateFormat('MM/dd/yyyy').format(lastDayOfJune);

    // Calculate the first day and last day of July in the format "mm/dd/yyyy"
    DateTime firstDayOfJuly = DateTime(currentDate.year, 7, 1);
    DateTime lastDayOfJuly = DateTime(currentDate.year, 8, 0);
    String firstDayOfJulyDate = DateFormat('MM/dd/yyyy').format(firstDayOfJuly);
    String lastDayOfJulyDate = DateFormat('MM/dd/yyyy').format(lastDayOfJuly);

    double todayExpensesSum = 0.0;
    double monthlyExpensesSum = 0.0;
    double juneExpensesSum = 0.0;
    double julyExpensesSum = 0.0;

    for (QueryDocumentSnapshot expenseDoc in expensesSnapshot.docs) {
      String dateString = expenseDoc['date']; // Replace 'date' with the actual field name in Firestore
      double amount = expenseDoc['amount'].toDouble(); // Replace 'amount' with the actual field name in Firestore

      // Check if the expense date matches today's date
      if (dateString == todayDate) {
        todayExpensesSum += amount;
      }

      // Check if the expense date is within the current month
      if (dateString.compareTo(firstDayOfTheMonthDate) >= 0 && dateString.compareTo(lastDayOfTheMonthDate) <= 0) {
        monthlyExpensesSum += amount;
      }

      // Check if the expense date is within June
      if (dateString.compareTo(firstDayOfJuneDate) >= 0 && dateString.compareTo(lastDayOfJuneDate) <= 0) {
        juneExpensesSum += amount;
      }

      // Check if the expense date is within July
      if (dateString.compareTo(firstDayOfJulyDate) >= 0 && dateString.compareTo(lastDayOfJulyDate) <= 0) {
        julyExpensesSum += amount;
      }
    }

    // Fetch today's income
    DocumentSnapshot incomeSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    double todayIncome = (incomeSnapshot['income'] as int).toDouble(); // Cast to double; // Replace 'income' with the actual field name in Firestore

    // Fetch the user's income from Firestore
    totalIncome = (incomeSnapshot['income'] as int).toDouble(); // Cast to double; // Replace 'income' with the actual field name in Firestore

    // Calculate total saved and savings progress
    totalSaved = totalIncome - monthlyExpensesSum;
    savingsProgress = (totalSaved / totalIncome) * 100;

    setState(() {
      todayExpenses = todayExpensesSum;
      monthlyExpenses = monthlyExpensesSum;
      juneExpenses = juneExpensesSum;
      julyExpenses = julyExpensesSum;
    });
  }

  void _showIncomeDialog() {
    // ... Your existing code for showing the income dialog
  }

  Future<void> saveIncomeToFirestore(String userId, double incomeAmount) async {
    // ... Your existing code for saving income to Firestore
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstTime) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _showIncomeDialog();
      });
    }
    return Scaffold(
      appBar: AppBar(
       title: Text('Home'),
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today\'s Expenses: \$${todayExpenses.toStringAsFixed(2)}'),
              SizedBox(height: 16),
              Text('Monthly Expenses: \$${monthlyExpenses.toStringAsFixed(2)}'),
              SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1,
                child: SpendingTrendsBarChart(
                  totalIncome: totalIncome,
                  totalSaved: totalSaved,
                  todayExpenses: todayExpenses,
                  monthlyExpenses: monthlyExpenses,
                  juneExpenses: juneExpenses,
                  julyExpenses: julyExpenses,
                ),
              ),
              SizedBox(height: 16),
              Text('Income: \$${totalIncome.toStringAsFixed(2)}'),
              SizedBox(height: 16),
              Text('Total Savings: \$${totalSaved.toStringAsFixed(2)}'),
              SizedBox(height: 16),
              Text('Savings Progress: ${savingsProgress.toStringAsFixed(1)}%'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Handle navigation when an item is tapped
          if (index == 1) {
            // Navigate to the home screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddExpenseScreen()),
            );
          } else if (index == 2) {
            // Navigate to the budget screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BudgetScreen()),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class SpendingTrendsBarChart extends StatelessWidget {
  final double totalIncome;
  final double totalSaved;
  final double todayExpenses;
  final double monthlyExpenses;
  final double juneExpenses;
  final double julyExpenses;

  SpendingTrendsBarChart({
    required this.totalIncome,
    required this.totalSaved,
    required this.todayExpenses,
    required this.monthlyExpenses,
    required this.juneExpenses,
    required this.julyExpenses,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: max(max(totalIncome, monthlyExpenses), max(juneExpenses, julyExpenses)) + 100,
            titlesData: FlTitlesData(
              leftTitles: SideTitles(
                interval: 1000,
                getTextStyles: (context, value) => const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                getTitles: (double value) {
                  if (value % 1000 == 0) {
                    return value.toInt().toString();
                  } else {
                    return '';
                  }
                },
                margin: 10,
              ),
              bottomTitles: SideTitles(
                showTitles: true,
                getTitles: (double value) {
                  switch (value.toInt()) {
                    case 0:
                      return 'Income';
                    case 1:
                      return 'Expenses';
                    case 2:
                      return 'June';
                    case 3:
                      return 'July';
                    default:
                      return '';
                  }
                },
              ),
            ),
            gridData: FlGridData(show: false),
            barGroups: buildBarGroups(),
            barTouchData: BarTouchData(enabled: false),
            borderData: FlBorderData(show: false),
            axisTitleData: FlAxisTitleData(leftTitle: AxisTitle(showTitle: true, titleText: 'Amount'), bottomTitle: AxisTitle(showTitle: true, titleText: 'Month')),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> buildBarGroups() {
    return [
      BarChartGroupData(x: 0, barRods: [buildIncomeBar()]),
      BarChartGroupData(x: 1, barRods: [buildExpensesBar()]),
      BarChartGroupData(x: 2, barRods: [buildJuneBar()]),
      BarChartGroupData(x: 3, barRods: [buildJulyBar()]),
    ];
  }

  BarChartRodData buildIncomeBar() {
    return BarChartRodData(y: totalIncome, colors: [Colors.blue], width: 16);
  }

  BarChartRodData buildExpensesBar() {
    return BarChartRodData(y: monthlyExpenses, colors: [Colors.red], width: 16);
  }

  BarChartRodData buildJuneBar() {
    return BarChartRodData(y: juneExpenses, colors: [Colors.red], width: 16);
  }

  BarChartRodData buildJulyBar() {
    return BarChartRodData(y: julyExpenses, colors: [Colors.red], width: 16);
  }
}
