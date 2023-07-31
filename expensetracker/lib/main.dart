import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import the Firebase Core package
import 'package:provider/provider.dart';
import 'screens/navbar.dart';
import 'screens/signup_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/addexpense_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/transactionhistory_screen.dart';
import 'firebase.dart';
import 'Models/auth_provider.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initializeFirebase();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  void _onNavBarItemTapped(int index) {
    if (index == 1) {
      // If the 'Add Expense' icon is tapped, navigate to the AddExpenseScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddExpenseScreen()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: AuthProvider()),
      ],
      child: MaterialApp(
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: SignupScreen.routeName,
      routes: {
         SignupScreen.routeName: (ctx) => SignupScreen(
                handleSigninModal: () {
                  showDialog(
                    context: ctx,
                    builder: (_) => Dialog(
                      child: SigninScreen(),
                    ),
                  );
                },
              ),
        SigninScreen.routeName: (ctx) => SigninScreen(),
        '/home': (ctx) => HomeScreen(), // Add the HomeScreen route
        '/add_expense': (ctx) => AddExpenseScreen(),
        '/budget': (ctx) => BudgetScreen(),
        '/transaction_history': (ctx) => NotificationScreen(),
        // Add more routes if needed.
      },
      ),
    );
  }

  Widget _buildContent() {
    // Use the _currentIndex to display the appropriate content on each screen
    switch (_currentIndex) {
      case 0:
        // Display the Home Screen content here
        return Container(
          color: Colors.white, // Replace with the actual background color for the Home Screen
          child: Center(
            child: Text('Home Screen'),
          ),
        );
      case 1:
        // Display the Add Expense Screen content here
        return Container(
          color: Colors.white, // Replace with the actual background color for the Add Expense Screen
          child: Center(
            child: Text('Add Expense Screen'),
          ),
        );
      case 2:
        // Display the Budget Screen content here
        return Container(
          color: Colors.white, // Replace with the actual background color for the Budget Screen
          child: Center(
            child: Text('Budget Screen'),
          ),
        );
      case 3:
        // Display the Transaction History Screen content here
        return Container(
          color: Colors.white, // Replace with the actual background color for the Transaction History Screen
          child: Center(
            child: Text('Transaction History Screen'),
          ),
        );
      default:
        return Container();
    }
  }
}
