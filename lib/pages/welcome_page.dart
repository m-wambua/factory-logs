import 'package:collector/pages/login_page.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Hello! Welcome to the CSL Data Logging Platform',
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                _showLoginDialog(context);
              },
              child: Text('Sign in'))
        ],
      )),
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext contex) {
          return AlertDialog(
            title: Text('Please Sign in'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                  ),
                  keyboardType: TextInputType.name,
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                )
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text('Ok'))
            ],
          );
        });
  }
}
