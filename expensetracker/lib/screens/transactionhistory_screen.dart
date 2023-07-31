import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'budget_screen.dart';
import 'home_screen.dart';
import 'addexpense_screen.dart';
import 'navbar.dart';
import '../Models/auth_provider.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Stream<QuerySnapshot>? _budgetStream;
  List<DocumentSnapshot> _exceededBudgetDocs = [];
  List<String> _notifications = [];
  List<String> _notificationIds = [];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _budgetStream = FirebaseFirestore.instance
          .collection('users/${user.uid}/budget')
          .snapshots();
      _fetchNotifications();
    } else {
      // Handle the case where the user is not signed in.
    }
  }

  void _fetchNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case where the user is not signed in.
      return;
    }

    try {
      final budgetSnapshot = await FirebaseFirestore.instance
          .collection('users/${user.uid}/budget')
          .get();

      final expensesSnapshot = await FirebaseFirestore.instance
          .collection('users/${user.uid}/expenses')
          .get();

      final notificationSnapshot = await FirebaseFirestore.instance
          .collection('users/${user.uid}/notifications')
          .get();

      final List<String> notifications = [];
      final List<String> notificationIds = [];
      for (var notificationDoc in notificationSnapshot.docs) {
        final notificationData = notificationDoc.data() as Map<String, dynamic>;
        final message = notificationData['message'] as String?;
        if (message != null) {
          notifications.add(message);
          notificationIds.add(notificationDoc.id);
        }
      }

      for (var budgetDoc in budgetSnapshot.docs) {
        final budgetData = budgetDoc.data() as Map<String, dynamic>;
        final category = budgetData['category'] as String?;
        final budgetLimit = (budgetData['budgetLimit'] as num?)?.toDouble();

        if (category != null && budgetLimit != null) {
          double totalExpenses = 0.0;
          for (var expenseDoc in expensesSnapshot.docs) {
            final expenseData = expenseDoc.data() as Map<String, dynamic>;
            if (expenseData['category'] == category) {
              final amount = (expenseData['amount'] as num?)?.toDouble();
              if (amount != null) {
                totalExpenses += amount;
              }
            }
          }

          final remaining = budgetLimit - totalExpenses;
          if (remaining <= 0.0) {
            final message = 'Your budget is exceeded by \$${remaining.abs()} for $category.';
            notifications.add(message);
          }
        }
      }

      setState(() {
        _notifications = notifications;
        _notificationIds = notificationIds;
      });

      // Store notifications in the database
      for (var notification in notifications) {
        await FirebaseFirestore.instance
            .collection('users/${user.uid}/notifications')
            .add({'message': notification});
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Notification Screen'),
      leading: IconButton(
        icon: Icon(Icons.account_circle),
        onPressed: () {
          // Handle the action when the user account icon is tapped.
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () async {
            // Implement logout functionality here
            AuthProvider authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            await authProvider.signOut();

            // Navigate to the SignupScreen after signing out
            Navigator.pushReplacementNamed(context, '/signup');
          },
        ),
      ],
    ),
    bottomNavigationBar: NavBar(
      currentIndex: 3,
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
          // Show the notifications dialog
          _showNotificationsDialog();
        }
      },
      notificationCount: _notifications.length,  // Pass notificationCount here
      onNotificationTap: _showNotificationsDialog,  // Pass the function here
    ),
    body: Center(
      child: Text('Notification Screen Content Here'), // Add your content here
    ),

  );
}

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_notifications.isEmpty)
              Text('No notifications to display.'),
            for (var notification in _notifications)
              Card(
                child: ListTile(
                  title: Text(notification),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _clearNotifications();
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearNotifications() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    // Handle the case where the user is not signed in.
    return;
  }

  WriteBatch batch = FirebaseFirestore.instance.batch();

  // Get the collection reference
  final collectionRef = FirebaseFirestore.instance.collection('users/${user.uid}/notifications');

  // Get the documents in the collection
  final querySnapshot = await collectionRef.get();

  // Add each document to the batch to be deleted
  querySnapshot.docs.forEach((doc) {
    batch.delete(doc.reference);
  });

  // Commit the batch
  await batch.commit();

  // Clear local copies
  setState(() {
    _notifications.clear();
    _notificationIds.clear();
  });
}
}
void main() => runApp(MaterialApp(home: NotificationScreen()));
