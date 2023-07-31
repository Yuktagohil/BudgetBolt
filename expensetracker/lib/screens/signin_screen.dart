// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../Models/auth_provider.dart';
// import '../Models/user.dart'; // Import the User class from the correct location

// class SigninScreen extends StatefulWidget {
//   static const routeName = '/signin';

//   @override
//   _SigninScreenState createState() => _SigninScreenState();
// }

// class _SigninScreenState extends State<SigninScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String _email = '';
//   String _password = '';

//   void _submitForm() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       _formKey.currentState?.save();
//       AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
//       User? user = await authProvider.signInWithEmailAndPassword(_email, _password);
//       if (user != null) {
//         // Handle successful signin, navigate to the HomeScreen with Navbar and user icon.
//         Navigator.pushReplacementNamed(context, '/home');
//       } else {
//         // Handle unsuccessful signin.
//       }
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Signin'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TextFormField(
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(labelText: 'Email'),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true || !value!.contains('@')) {
//                     return 'Please enter a valid email address.';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) {
//                   _email = value ?? '';
//                 },
//               ),
//               TextFormField(
//                 obscureText: true,
//                 decoration: InputDecoration(labelText: 'Password'),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true || value!.length < 6) {
//                     return 'Password must be at least 6 characters long.';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) {
//                   _password = value ?? '';
//                 },
//               ),
//               SizedBox(height: 16),
//               ElevatedButton( // Replace RaisedButton with ElevatedButton
//                 child: Text('Sign In'),
//                 onPressed: _submitForm,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SigninScreen extends StatefulWidget {
  static const routeName = '/signin';

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _submitForm() async {
  if (_formKey.currentState?.validate() ?? false) {
    _formKey.currentState?.save();
    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      var result = await authProvider.signInWithEmailAndPassword(_email, _password);
      // TODO: Check the `result` to see if sign-in was successful. This will depend on the definition of your User class.
      // If successful, show success snackbar and navigate to the HomeScreen.
      // If unsuccessful, show error snackbar.

      // Assuming the sign-in was successful, navigate to the HomeScreen.
      if (result != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
          case 'wrong-password':
            errorMessage = 'Invalid credentials. Please try again.';
            break;
          default:
            errorMessage = 'Error during sign in. Please try again later.';
            break;
        }
      } else {
        errorMessage = 'Error during sign in. Please try again later.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red, // Highlighting the message with red background
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signin'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value?.isEmpty ?? true || !value!.contains('@')) {
                    return 'Please enter a valid email address.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value ?? '';
                },
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value?.isEmpty ?? true || value!.length < 6) {
                    return 'Password must be at least 6 characters long.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value ?? '';
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Sign In'),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

