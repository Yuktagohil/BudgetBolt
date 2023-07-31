import 'package:firebase_core/firebase_core.dart';

class FirebaseInitializer {
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: FirebaseOptions(
      apiKey: "AIzaSyAQoZqq9Sz3IKY25MHZZOgEN_W5BNR1bgo",
      authDomain: "expensetracker-8b234.firebaseapp.com",  // replace with your actual authDomain
      messagingSenderId: "611916817357",
      databaseURL: "https://expensetracker-8b234.firebaseio.com",  // replace with your actual databaseURL
      projectId: "expensetracker-8b234",  // replace with your actual projectId
      storageBucket: "expensetracker-8b234.appspot.com",  // replace with your actual storageBucket
      appId: "1:611916817357:android:6a6200966d523a6f725a84",  // replace with your actual appId
    ),
    );
  }
}
