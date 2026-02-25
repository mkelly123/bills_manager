import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bill.dart';

class ReminderOption {
  final String label;
  final int days;

  ReminderOption(this.label, this.days);
}

final reminderOptions = [
  ReminderOption("On the day", 0),
  ReminderOption("1 day before", 1),
  ReminderOption("3 days before", 3),
  ReminderOption("1 week before", 7),
  ReminderOption("2 weeks before", 14),
  ReminderOption("1 month before", 30),
];

class AddEditBillScreen extends StatefulWidget {
  final Bill? bill;

  const AddEditBillScreen({super.key, this.bill});

  @override
  State<AddEditBillScreen> createState() => _AddEditBillScreenState();
}

class _AddEditBillScreenState extends State<AddEditBillScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  DateTime? selectedDate;
  String? selectedCategory;
  String? repeatInterval;

  final List<String> categories = [
    'Utilities',
    'Entertainment',
    'Insurance',
    'Subscriptions',
    'Shopping',
    'Other',
  ];

  final List<String> repeatOptions = [
    'Weekly',
    'Monthly',
    'Quarterly',
    'Annually',
  ];

  int reminderOffsetDays = 0;

  bool get isProUser => false;

  // ⭐ Calculate next renewal based on repeat interval
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

  void showPaywall(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Upgrade to Pro to unlock this feature")),
    );
  }

  Widget buildReminderSelector(BuildContext context) {
    return ListTile(
      title: const Text("Reminder"),
      subtitle: Text(
        reminderOptions.firstWhere((o) => o.days == reminderOffsetDays).label,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => showReminderSelector(context),
    );
  }

  void showReminderSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "When should we remind you?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...reminderOptions.map((option) {
              final isLocked = !isProUser && option.days != 0;

              return ListTile(
                leading: isLocked
                    ? const Icon(Icons.lock, color: Colors.grey)
                    : const Icon(Icons.notifications),
                title: Text(option.label),
                onTap: () {
                  if (isLocked) {
                    showPaywall(context);
                    return;
                  }

                  setState(() {
                    reminderOffsetDays = option.days;
                  });

                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.bill != null) {
      nameController.text = widget.bill!.name;
      amountController.text = widget.bill!.amount.toString();
      notesController.text = widget.bill!.notes;
      selectedCategory = widget.bill!.category;
      selectedDate = widget.bill!.renewalDate;
      reminderOffsetDays = widget.bill!.reminderOffsetDays;
      repeatInterval = widget.bill!.repeatInterval;
    }
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> saveBill() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategory == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    if (repeatInterval == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a repeat interval')),
      );
      return;
    }

    if (selectedDate == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a renewal date')),
      );
      return;
    }

    final amount = double.tryParse(amountController.text);

    // ⭐ Calculate next renewal date
    final nextRenewal = calculateNextRenewal(selectedDate!, repeatInterval!);

    final data = {
      'name': nameController.text.trim(),
      'amount': amount,
      'renewal_date': selectedDate!.toIso8601String(),
      'next_renewal_date': nextRenewal.toIso8601String(),
      'category': selectedCategory,
      'notes': notesController.text.trim(),
      'reminder_offset_days': reminderOffsetDays,
      'repeat_interval': repeatInterval,
      'user_id': Supabase.instance.client.auth.currentUser!.id,
    };

    if (widget.bill == null) {
      await Supabase.instance.client.from('bills').insert(data);
    } else {
      await Supabase.instance.client
          .from('bills')
          .update(data)
          .eq('id', widget.bill!.id);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Bill saved successfully')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bill == null ? 'Add Bill' : 'Edit Bill'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Bill Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a bill name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Amount must be a number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: repeatInterval,
                decoration: const InputDecoration(labelText: 'Repeats'),
                items: repeatOptions
                    .map(
                      (opt) => DropdownMenuItem(value: opt, child: Text(opt)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => repeatInterval = value),
                validator: (value) =>
                    value == null ? 'Please select a repeat interval' : null,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate == null
                          ? 'No date chosen'
                          : 'Renewal: ${selectedDate!.toLocal()}'.split(' ')[0],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: pickDate,
                    child: const Text('Pick Date'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              buildReminderSelector(context),

              const SizedBox(height: 16),

              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveBill,
                  child: const Text('Save Bill'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
