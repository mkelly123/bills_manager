import 'package:flutter/material.dart';
import '../../models/bill.dart';
import 'bill_tile.dart';

class PastBillsSection extends StatelessWidget {
  final List<Bill> pastBills;
  final Map<String, Color> categoryColors;
  final bool Function(Bill bill) isOverdue;
  final void Function(Bill bill) onTapBill;

  const PastBillsSection({
    super.key,
    required this.pastBills,
    required this.categoryColors,
    required this.isOverdue,
    required this.onTapBill,
  });

  @override
  Widget build(BuildContext context) {
    if (pastBills.isEmpty) return const SizedBox.shrink();

    return ExpansionTile(
      title: Text(
        'Past Bills (${pastBills.length})',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      children: pastBills.map((bill) {
        return BillTile(
          bill: bill,
          color: categoryColors[bill.category] ?? Colors.grey,
          overdue: isOverdue(bill),
          onTap: () => onTapBill(bill),
        );
      }).toList(),
    );
  }
}
