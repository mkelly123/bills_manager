import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class AppLockScreen extends StatefulWidget {
  final Widget child;

  const AppLockScreen({super.key, required this.child});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _unlocked = false;
  // bool _authInProgress = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Unlock to access your bills',
        options: const AuthenticationOptions(biometricOnly: false),
      );

      if (didAuthenticate) {
        setState(() => _unlocked = true);
      } else {
        // If user cancels or fails, retry or show a button
        setState(() => _unlocked = false);
      }
    } catch (e) {
      debugPrint('Auth error: $e');
      setState(() => _unlocked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) {
      return widget.child;
    }

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _authenticate,
          child: const Text('Tap to unlock'),
        ),
      ),
    );
  }
}
