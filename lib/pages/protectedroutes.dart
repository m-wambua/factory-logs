import 'package:collector/pages/authorization.dart';
import 'package:collector/pages/users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProtectedNavigationButton extends StatelessWidget {
  final String text;
  final List<UserRole> allowedRoles;
  final VoidCallback onPressed;

  const ProtectedNavigationButton({
    super.key,
    required this.text,
    required this.allowedRoles,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, child) {
      final bool hasAccess = auth.hasPermission(allowedRoles);
      return TextButton(
        onPressed: hasAccess
            ? onPressed
            : () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text("You do not have permission to access this page"),
                  backgroundColor: Colors.red,
                ));
              },
        style: TextButton.styleFrom(
            foregroundColor: hasAccess ? null : Colors.grey),
        child: Text(text),
      );
    });
  }
}

class Protectedroutes extends StatelessWidget {
  final List<UserRole> allowedRoles;
  final Widget child;

  const Protectedroutes({
    super.key,
    required this.allowedRoles,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, child) {
      if (!auth.hasPermission(allowedRoles)) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Access Denied'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("You don\'t have permission to access this page"),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Go Back'),
                )
              ],
            ),
          ),
        );
      } else {
        return child!;
      }
    });
  }
}
