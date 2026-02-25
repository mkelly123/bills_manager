import 'package:flutter/material.dart';

class StickyTodayMarker extends StatefulWidget {
  final ScrollController scrollController;

  const StickyTodayMarker({super.key, required this.scrollController});

  @override
  State<StickyTodayMarker> createState() => _StickyTodayMarkerState();
}

class _StickyTodayMarkerState extends State<StickyTodayMarker> {
  bool showMarker = false;

  @override
  void initState() {
    super.initState();

    widget.scrollController.addListener(() {
      if (widget.scrollController.offset > 180 && !showMarker) {
        setState(() => showMarker = true);
      } else if (widget.scrollController.offset <= 180 && showMarker) {
        setState(() => showMarker = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!showMarker) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          '— TODAY —',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
