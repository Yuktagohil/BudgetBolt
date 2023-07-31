// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../Models/auth_provider.dart';
// import '../Models/user.dart'; // Import the User class from the correct location

// class SignupScreen extends StatefulWidget {
//   static const routeName = '/signup';

//   @override
//   _SignupScreenState createState() => _SignupScreenState();
// }

  
// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String _email = '';
//   String _password = '';

//   void _submitForm() async {
//       if (_formKey.currentState?.validate() ?? false) {
//         _formKey.currentState?.save();
//         AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
//         User? user = await authProvider.registerWithEmailAndPassword(_email, _password);
//         if (user != null) {
//           // Handle successful signup, navigate to the HomeScreen with Navbar and user icon.
//           Navigator.pushReplacementNamed(context, '/home');
//         } else {
//           // Handle unsuccessful signup.
//         }
//       }
//     }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Signup'),
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
//                 child: Text('Sign Up'),
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
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../Models/auth_provider.dart';
import '../Models/user.dart' as custom;
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup';

  final VoidCallback handleSigninModal;

  SignupScreen({required this.handleSigninModal});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        custom.User? user = await authProvider.signInWithEmailAndPassword(_email, _password);

        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign in successful!', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
            ),
          );
           Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()), 
                    );
        } else {
          throw fb.FirebaseAuthException(code: 'signin-failed');
        }
      } on fb.FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid credentials. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error during sign in. Please try again later.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during sign in. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Method to show the sign-in dialog box
  void _showSigninDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sign In'),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    // Add your validation logic here for the email field
                    validator: (value) {
                      if (value?.isEmpty ?? true || !(value?.contains('@') ?? false)) {
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
                    // Add your validation logic here for the password field
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password.';
                      } else if (value.length < 6) {
                        return 'Password should be at least 6 characters.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value ?? '';
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Add your sign-in logic here
                Navigator.of(context).pop();
              },
              child: Text('Sign In'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          // Update onPressed to navigate to /signin route
          
          ],
        );
      },
    );
  }
  void _navigateToSignin() {
            Navigator.pushNamed(context, '/signin');
          }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.924, // Specify a fixed height here
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1494859802809-d069c3b71a8a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1740&q=80'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
              ),
              child: Card(
                borderOnForeground: false,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Signup',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(hintText: 'Email'),
                          validator: (value) {
                            if (value?.isEmpty ?? true || !(value?.contains('@') ?? false)) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _email = value ?? '';
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(hintText: 'Password'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password.';
                            } else if (value.length < 6) {
                              return 'Password should be at least 6 characters.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _password = value ?? '';
                          },
                          obscureText: true,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: Text('Sign Up'),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: _navigateToSignin,
                          child: Text('Already have an account? Sign in'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
