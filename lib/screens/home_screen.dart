import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bill.dart';
import 'add_edit_bill_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum SortOption { soonest, amountHigh, nameAZ, categoryAZ }

class _HomeScreenState extends State<HomeScreen> {
  List<Bill> allBills = [];
  List<Bill> filteredBills = [];
  bool loading = true;

  String searchQuery = '';
  SortOption currentSort = SortOption.soonest;

  // Filters
  String? selectedCategoryFilter;
  String? selectedIntervalFilter;
  bool showOverdueOnly = false;
  bool showUpcomingOnly = false;

  @override
  void initState() {
    super.initState();
    loadBills();
  }

  Future<void> loadBills() async {
    setState(() => loading = true);

    final userId = Supabase.instance.client.auth.currentUser!.id;

    final response = await Supabase.instance.client
        .from('bills')
        .select()
        .eq('user_id', userId)
        .order('next_renewal_date', ascending: true);

    allBills = (response as List).map((data) => Bill.fromMap(data)).toList();

    applyFiltersAndSorting();

    setState(() => loading = false);
  }

  Future<void> deleteBill(int id) async {
    await Supabase.instance.client.from('bills').delete().eq('id', id);
    await loadBills();
  }

  Future<void> markAsPaid(Bill bill) async {
    DateTime calculateNextRenewal(DateTime current, String interval) {
      switch (interval) {
        case 'Weekly':
          return current.add(const Duration(days: 7));
        case 'Monthly':
          return DateTime(current.year, current.month + 1, current.day);
        case 'Quarterly':
          return DateTime(current.year, current.month + 3, current.day);
        case 'Annually':
          return DateTime(current.year + 1, current.month, current.day);
        default:
          return current;
      }
    }

    final newNext = calculateNextRenewal(
      bill.nextRenewalDate,
      bill.repeatInterval,
    );

    await Supabase.instance.client
        .from('bills')
        .update({'next_renewal_date': newNext.toIso8601String()})
        .eq('id', bill.id);

    await loadBills();
  }

  bool isOverdue(Bill bill) {
    final today = DateTime.now();
    final date = DateTime(today.year, today.month, today.day);
    return bill.nextRenewalDate.isBefore(date);
  }

  bool isUpcoming(Bill bill) {
    final diff = bill.nextRenewalDate.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 14;
  }

  final categoryColors = {
    'Utilities': Colors.blue,
    'Entertainment': Colors.purple,
    'Insurance': Colors.orange,
    'Subscriptions': Colors.green,
    'Shopping': Colors.teal,
    'Other': Colors.grey,
  };

  void applyFiltersAndSorting() {
    List<Bill> list = List.from(allBills);

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((b) {
        return b.name.toLowerCase().contains(q) ||
            b.category.toLowerCase().contains(q) ||
            b.notes.toLowerCase().contains(q);
      }).toList();
    }

    if (selectedCategoryFilter != null) {
      list = list.where((b) => b.category == selectedCategoryFilter).toList();
    }

    if (selectedIntervalFilter != null) {
      list = list
          .where((b) => b.repeatInterval == selectedIntervalFilter)
          .toList();
    }

    if (showOverdueOnly) {
      list = list.where(isOverdue).toList();
    }

    if (showUpcomingOnly) {
      list = list.where(isUpcoming).toList();
    }

    list.sort((a, b) {
      switch (currentSort) {
        case SortOption.soonest:
          return a.nextRenewalDate.compareTo(b.nextRenewalDate);
        case SortOption.amountHigh:
          return b.amount.compareTo(a.amount);
        case SortOption.nameAZ:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case SortOption.categoryAZ:
          return a.category.toLowerCase().compareTo(b.category.toLowerCase());
      }
    });

    filteredBills = list;
  }

  double getMonthlyEquivalent(Bill bill) {
    switch (bill.repeatInterval) {
      case 'Weekly':
        return bill.amount * 52 / 12;
      case 'Monthly':
        return bill.amount;
      case 'Quarterly':
        return bill.amount / 3;
      case 'Annually':
        return bill.amount / 12;
      default:
        return bill.amount;
    }
  }

  double get totalMonthlyCost {
    return allBills.fold(0.0, (sum, b) => sum + getMonthlyEquivalent(b));
  }

  double get totalAnnualCost {
    return totalMonthlyCost * 12;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final upcoming = filteredBills.where(isUpcoming).toList();
    final overdue = filteredBills.where(isOverdue).toList();

    final weekly = filteredBills
        .where((b) => b.repeatInterval == 'Weekly')
        .toList();
    final monthly = filteredBills
        .where((b) => b.repeatInterval == 'Monthly')
        .toList();
    final quarterly = filteredBills
        .where((b) => b.repeatInterval == 'Quarterly')
        .toList();
    final annually = filteredBills
        .where((b) => b.repeatInterval == 'Annually')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Subscriptions"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _openFilterSheet(context),
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                currentSort = value;
                applyFiltersAndSorting();
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: SortOption.soonest,
                child: Text("Soonest renewal"),
              ),
              PopupMenuItem(
                value: SortOption.amountHigh,
                child: Text("Highest amount"),
              ),
              PopupMenuItem(value: SortOption.nameAZ, child: Text("Name A–Z")),
              PopupMenuItem(
                value: SortOption.categoryAZ,
                child: Text("Category A–Z"),
              ),
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadBills),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditBillScreen()),
          );
          await loadBills();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchBar(),
          _buildTotalsCard(context),
          const SizedBox(height: 16),

          if (upcoming.isNotEmpty)
            buildSection("Upcoming (next 14 days)", upcoming),

          if (overdue.isNotEmpty)
            buildSection("Overdue", overdue, overdue: true),

          if (weekly.isNotEmpty) buildSection("Weekly", weekly),

          if (monthly.isNotEmpty) buildSection("Monthly", monthly),

          if (quarterly.isNotEmpty) buildSection("Quarterly", quarterly),

          if (annually.isNotEmpty) buildSection("Annually", annually),
        ],
      ),
    );
  }

  Widget buildSection(String title, List<Bill> items, {bool overdue = false}) {
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
        ...items.map(
          (bill) => Dismissible(
            key: ValueKey('section_${title}_${bill.id}_${bill.hashCode}'),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
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
                  );
                },
              );
            },
            onDismissed: (direction) async {
              await deleteBill(bill.id);
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
              overdue: overdue || isOverdue(bill),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditBillScreen(bill: bill),
                  ),
                );
                await loadBills();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search by name, category, notes...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
            applyFiltersAndSorting();
          });
        },
      ),
    );
  }

  Widget _buildTotalsCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.pie_chart, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Estimated Cost",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Monthly: £${totalMonthlyCost.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      "Annual: £${totalAnnualCost.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    final categories = <String>{...allBills.map((b) => b.category)}.toList()
      ..sort();

    final intervals = <String>{
      ...allBills.map((b) => b.repeatInterval),
    }.toList()..sort();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void update(void Function() fn) {
              setModalState(fn);
              setState(() {
                applyFiltersAndSorting();
              });
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Filters",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Category"),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text("All"),
                          selected: selectedCategoryFilter == null,
                          onSelected: (_) =>
                              update(() => selectedCategoryFilter = null),
                        ),
                        ...categories.map(
                          (cat) => ChoiceChip(
                            label: Text(cat),
                            selected: selectedCategoryFilter == cat,
                            onSelected: (_) =>
                                update(() => selectedCategoryFilter = cat),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Repeat Interval"),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text("All"),
                          selected: selectedIntervalFilter == null,
                          onSelected: (_) =>
                              update(() => selectedIntervalFilter = null),
                        ),
                        ...intervals.map(
                          (intv) => ChoiceChip(
                            label: Text(intv),
                            selected: selectedIntervalFilter == intv,
                            onSelected: (_) =>
                                update(() => selectedIntervalFilter = intv),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Status"),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text("Overdue"),
                          selected: showOverdueOnly,
                          onSelected: (val) =>
                              update(() => showOverdueOnly = val),
                        ),
                        FilterChip(
                          label: const Text("Upcoming (14 days)"),
                          selected: showUpcomingOnly,
                          onSelected: (val) =>
                              update(() => showUpcomingOnly = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            selectedCategoryFilter = null;
                            selectedIntervalFilter = null;
                            showOverdueOnly = false;
                            showUpcomingOnly = false;
                            applyFiltersAndSorting();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Clear filters"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

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
        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.receipt_long, color: Colors.white),
        ),
        title: Text(bill.name),
        subtitle: Text(
          "${bill.category} • ${bill.repeatInterval}\nNext: $dateStr",
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "£${bill.amount.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (overdue)
              const Text(
                "Overdue",
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
