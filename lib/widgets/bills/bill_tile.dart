import 'package:flutter/material.dart';
import '../../models/bill.dart';

class BillTile extends StatelessWidget {
  final Bill bill;
  final Color color;
  final bool overdue;
  final VoidCallback onTap;

  const BillTile({
    super.key,
    required this.bill,
    required this.color,
    required this.overdue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = bill.nextRenewalDate.toLocal().toString().split(' ')[0];

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: const Icon(Icons.receipt_long, color: Colors.white),
            ),
            const Positioned(
              right: -2,
              bottom: -2,
              child: Icon(Icons.pie_chart, size: 16, color: Colors.white70),
            ),
          ],
        ),
        title: Text(bill.name),
        subtitle: Text(
          '${bill.category} • ${bill.repeatInterval}\nNext: $dateStr',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '£${bill.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (overdue)
              const Text(
                'Overdue',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
