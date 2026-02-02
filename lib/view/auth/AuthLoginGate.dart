import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/view/auth/loginView.dart';
import 'package:user_side/widgets/customBgContainer.dart';

// yahan apni login screen import karlo
// import 'package:user_side/view/auth/loginView.dart';

class AuthGate extends StatelessWidget {
  final Widget child;
  final Widget? fallback; // e.g. LoginScreen()

  const AuthGate({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthSession>();

    if (!auth.initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!auth.isLoggedIn) {
      return fallback ??
          Scaffold(
            body: CustomBgContainer(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Login required"),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      child: const Text("Go to Login"),
                    ),
                  ],
                ),
              ),
            ),
          );
    }

    return child;
  }
}
