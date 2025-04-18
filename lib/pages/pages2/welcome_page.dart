import 'package:collector/main.dart';
import 'package:collector/pages/authorization.dart';
import 'package:collector/pages/pages2/homepage.dart';
import 'package:collector/pages/pages2/login_page.dart';
import 'package:collector/pages/pages2/signuppage.dart';
import 'package:collector/pages/users.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  SignInMethod _method = SignInMethod.email;
  String get _identifierLabel {
    switch (_method) {
      case SignInMethod.username:
        return 'Username';
      case SignInMethod.email:
        return 'Email';
      case SignInMethod.phoneNumber:
        return 'Phone Number';
    }
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $_identifierLabel';
    }
    switch (_method) {
      case SignInMethod.email:
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        break;
      case SignInMethod.phoneNumber:
        final phoneRegex = RegExp(r'^\+?[\d\s-]+$');
        if (!phoneRegex.hasMatch(value)) {
          return 'Please enter a valid phone number';
        }
        break;
      case SignInMethod.username:
        if (value.length < 3) {
          return 'Username must be at least 3 characters long';
        }
        break;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign In'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SegmentedButton<SignInMethod>(
                    segments: const [
                      ButtonSegment(
                          value: SignInMethod.username,
                          label: Text("Username")),
                      ButtonSegment(
                          value: SignInMethod.email, label: Text("Email")),
                      ButtonSegment(
                          value: SignInMethod.phoneNumber,
                          label: Text("Phone Number")),
                    ],
                    selected: {_method},
                    onSelectionChanged: (Set<SignInMethod> selected) {
                      setState(() {
                        _method = selected.first;
                        _identifierController.clear();
                      });
                    },
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFormField(
                    controller: _identifierController,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: _identifierLabel,
                        hintText: 'Enter your $_identifierLabel'),
                    validator: _validateIdentifier,
                    keyboardType: _method == SignInMethod.phoneNumber
                        ? TextInputType.phone
                        : _method == SignInMethod.email
                            ? TextInputType.emailAddress
                            : TextInputType.text,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                        hintText: 'Enter your password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        /*
                        SharedPreferences.getInstance().then((prefs) => print(
                            'SharedPreferences content: ${prefs.getKeys().map((key) => '$key: ${prefs.get(key)}').toList()}'));
*/
                        if (_formKey.currentState!.validate()) {
                          final success = await context
                              .read<AuthProvider>()
                              .signIn(_identifierController.text,
                                  _passwordController.text, _method);
                          if (success) {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        LandingPage(username: '')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Invalid $_identifierLabel or password. Please try again'),
                              backgroundColor: Colors.red,
                            ));
                          }
                        }
                      },
                      child: const Text("Sign in")),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpPage()));
                      },
                      child: const Text("Don't have an account? Sign up")),
                  // Add this button somewhere in your WelcomePage widget
                ],
              ),
            )));
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sign In'),
            content: Column(
              children: <Widget>[
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Email/Usernmae'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Sign In'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}



// Exercie caution when using this!!


/*
ElevatedButton(
  onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('App data reset successfully. App will restart.')),
    );
    // Optional: Force app restart or navigation to initial setup
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AdminSetupPage()),
      (route) => false,
    );
  },
  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  child: const Text("RESET APP (Emergency Use Only)"),
)
*/