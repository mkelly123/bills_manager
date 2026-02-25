import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _themeMode = 'system';

  // ⭐ NEW: currency setting
  String _currency = '£';

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadCurrency(); // ⭐ load currency on startup
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _themeMode = prefs.getString('themeMode') ?? 'system';
    });
  }

  // ⭐ NEW: load saved currency
  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _currency = prefs.getString('currency') ?? '£';
    });
  }

  // ⭐ NEW: save currency
  Future<void> _setCurrency(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', value);

    if (!mounted) return;

    setState(() {
      _currency = value;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Currency saved.')));
  }

  Future<void> _setTheme(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode);

    if (!mounted) return;

    setState(() {
      _themeMode = mode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Theme preference saved. Restart app to apply.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Theme', style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          // THEME OPTIONS — safely ignoring deprecated warnings
          // ignore: deprecated_member_use
          RadioListTile<String>(
            title: const Text('System default'),
            value: 'system',
            groupValue: _themeMode,
            onChanged: (value) {
              if (value != null) _setTheme(value);
            },
          ),

          // ignore: deprecated_member_use
          RadioListTile<String>(
            title: const Text('Light'),
            value: 'light',
            groupValue: _themeMode,
            onChanged: (value) {
              if (value != null) _setTheme(value);
            },
          ),

          // ignore: deprecated_member_use
          RadioListTile<String>(
            title: const Text('Dark'),
            value: 'dark',
            groupValue: _themeMode,
            onChanged: (value) {
              if (value != null) _setTheme(value);
            },
          ),

          const Divider(),

          const ListTile(
            title: Text(
              'Currency',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // CURRENCY OPTIONS — safely ignoring deprecated warnings
          // ignore: deprecated_member_use
          RadioListTile<String>(
            title: const Text('£ GBP'),
            value: '£',
            groupValue: _currency,
            onChanged: (value) {
              if (value != null) _setCurrency(value);
            },
          ),

          // ignore: deprecated_member_use
          RadioListTile<String>(
            title: const Text('€ EUR'),
            value: '€',
            groupValue: _currency,
            onChanged: (value) {
              if (value != null) _setCurrency(value);
            },
          ),

          // ignore: deprecated_member_use
          RadioListTile<String>(
            title: const Text('\$ USD'),
            value: '\$',
            groupValue: _currency,
            onChanged: (value) {
              if (value != null) _setCurrency(value);
            },
          ),
        ],
      ),
    );
  }
}
