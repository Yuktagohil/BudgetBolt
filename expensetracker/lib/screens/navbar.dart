import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int? notificationCount;
  final VoidCallback? onNotificationTap;

  NavBar({
    required this.currentIndex, 
    required this.onTap, 
    this.notificationCount = 0,  // Make this parameter optional and default to 0
    this.onNotificationTap,
  });

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    int? notificationCount = widget.notificationCount;  // Create a local variable
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.currentIndex,
      onTap: (index) {
        if (index == 3) {
    if (widget.onNotificationTap != null) {
      widget.onNotificationTap!();
    } else {
      // Default action if onNotificationTap is not provided
      Navigator.pushNamed(context, '/transaction_history');
    }
  } else {
    widget.onTap(index);
  }
      },
      backgroundColor: Colors.blue[600],
      selectedItemColor: Colors.grey[800],
      unselectedItemColor: Colors.white,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Add Expense',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pie_chart),
          label: 'Budget',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: <Widget>[
              Icon(Icons.notifications),
              if (notificationCount != null && notificationCount > 0)  // Use the local variable
                Positioned(
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '$notificationCount',  // Use the local variable
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Notifications',
        ),
      ],
    );
  }
}
