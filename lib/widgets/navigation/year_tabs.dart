import 'package:flutter/material.dart';
import '../../models/bill.dart';
import '../bills/month_section.dart';
import '../bills/past_bills_section.dart';

class YearTabs extends StatelessWidget {
  final List<int> years;
  final Map<int, Map<int, List<Bill>>> groupedBills;
  final Map<String, Color> categoryColors;
  final bool Function(Bill bill) isOverdue;
  final void Function(Bill bill) onTapBill;

  const YearTabs({
    super.key,
    required this.years,
    required this.groupedBills,
    required this.categoryColors,
    required this.isOverdue,
    required this.onTapBill,
  });

  double _yearTotal(int year) {
    return groupedBills[year]!.values
        .expand((b) => b)
        .fold(0, (sum, b) => sum + b.amount);
  }

  int _yearCount(int year) {
    return groupedBills[year]!.values.expand((b) => b).length;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: years.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant,
            tabs: years.map((y) => Tab(text: y.toString())).toList(),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 800,
            child: TabBarView(
              children: years.map((year) {
                final monthsMap = groupedBills[year]!;
                final months = monthsMap.keys.toList()..sort();

                final pastBills = monthsMap.values
                    .expand((b) => b)
                    .where((b) => b.daysUntilRenewal < 0)
                    .toList();

                return ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [
                    // YEAR SUMMARY
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        '$year Summary — ${_yearCount(year)} bills • £${_yearTotal(year).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // MONTH SECTIONS
                    ...months.map((month) {
                      final monthBills = monthsMap[month]!
                          .where((b) => b.daysUntilRenewal >= 0)
                          .toList();

                      if (monthBills.isEmpty) return const SizedBox.shrink();

                      return MonthSection(
                        title: '${_monthName(month)} $year',
                        items: monthBills,
                        categoryColors: categoryColors,
                        isOverdue: isOverdue,
                      );
                    }),

                    // PAST BILLS SECTION
                    PastBillsSection(
                      pastBills: pastBills,
                      categoryColors: categoryColors,
                      isOverdue: isOverdue,
                      onTapBill: onTapBill,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month];
  }
}
