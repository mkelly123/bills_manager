import 'package:flutter/material.dart';

class JumpToCurrentButton extends StatelessWidget {
  final VoidCallback onPressed;

  const JumpToCurrentButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: colorScheme.primary,
      label: const Text(
        'Jump to Today',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      icon: const Icon(Icons.calendar_today),
    );
  }
}
