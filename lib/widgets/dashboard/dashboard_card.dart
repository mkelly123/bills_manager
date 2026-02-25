import 'package:flutter/material.dart';
import '../../models/bill.dart';

class DashboardCard extends StatelessWidget {
  final List<Bill> bills;
  final String currency;
  final bool showThisMonth;

  const DashboardCard({
    super.key,
    required this.bills,
    required this.currency,
    required this.showThisMonth,
  });

  double _monthlyTotal() {
    final now = DateTime.now();
    return bills
        .where(
          (b) =>
              b.renewalDate.month == now.month &&
              b.renewalDate.year == now.year,
        )
        .fold(0, (sum, b) => sum + b.amount);
  }

  int _monthlyCount() {
    final now = DateTime.now();
    return bills
        .where(
          (b) =>
              b.renewalDate.month == now.month &&
              b.renewalDate.year == now.year,
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final monthlyTotal = _monthlyTotal();
    final monthlyCount = _monthlyCount();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Total Bills: ${bills.length}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),

          // Text(
          //   'Total Monthly Cost: $currency${bills.fold<double>(0, (sum, b) => sum + b.amount).toStringAsFixed(2)}',
          //   style: theme.textTheme.bodyMedium?.copyWith(
          //     color: colorScheme.onSurface,
          //   ),
          // ),
          if (showThisMonth) ...[
            const SizedBox(height: 12),
            Text(
              'This Month',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Bills Due: $monthlyCount',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'Amount Due: $currency${monthlyTotal.toStringAsFixed(2)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
