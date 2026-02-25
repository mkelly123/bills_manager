import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
// import 'screens/add_edit_bill_screen.dart';
// import 'models/bill.dart';
import 'app_lock_screen.dart';
import 'theme/theme_notifier.dart';

final themeNotifier = ThemeNotifier();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://npruwlbwrmibbutjjvko.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5wcnV3bGJ3cm1pYmJ1dGpqdmtvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEyNDc3NzcsImV4cCI6MjA4NjgyMzc3N30.PtK8wopwvLnQu3Lb_6Sp7SiZ_3C8jqATl5JqCKQaCQc',
  );

  await themeNotifier.loadTheme();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeNotifier.themeMode,
          home: const AuthGate(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            // '/home': (context) => const AppLockScreen(child: HomeScreen()),
            '/home': (context) => const HomeScreen(),
            '/settings': (context) =>
                const AppLockScreen(child: SettingsScreen()),
            '/add-edit-bill': (context) {
              // final bill = ModalRoute.of(context)!.settings.arguments as Bill?;
              // return AppLockScreen(child: AddEditBillScreen(bill: bill));
              return const HomeScreen();
            },
          },
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      return const LoginScreen();
    }

    return const AppLockScreen(child: HomeScreen());
  }
}
