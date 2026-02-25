import 'package:flutter/material.dart';

import '../../models/bill.dart';
import '../../screens/add_edit_bill_screen.dart';
import 'bill_tile.dart';

class MonthSection extends StatelessWidget {
  final String title;
  final List<Bill> items;
  final Map<String, Color> categoryColors;
  final bool Function(Bill) isOverdue;

  const MonthSection({
    super.key,
    required this.title,
    required this.items,
    required this.categoryColors,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...items.map((bill) {
          return Dismissible(
            key: ValueKey('${title}_${bill.id}'),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Bill'),
                  content: Text(
                    'Are you sure you want to delete "${bill.name}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              // hook up real delete later
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: BillTile(
              bill: bill,
              color: categoryColors[bill.category] ?? Colors.grey,
              overdue: isOverdue(bill),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditBillScreen(bill: bill),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
