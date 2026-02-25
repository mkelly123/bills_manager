class Bill {
  final int id; // Supabase returns INT, not String
  final String name;
  final double amount;
  final DateTime renewalDate;
  final DateTime nextRenewalDate;
  final String category;
  final String notes;
  final int reminderOffsetDays;
  final String repeatInterval;
  final String userId;

  Bill({
    required this.id,
    required this.name,
    required this.amount,
    required this.renewalDate,
    required this.nextRenewalDate,
    required this.category,
    required this.notes,
    required this.reminderOffsetDays,
    required this.repeatInterval,
    required this.userId,
  });

  factory Bill.fromMap(Map<String, dynamic> data) {
    return Bill(
      id: int.tryParse(data['id'].toString()) ?? 0,
      name: data['name'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      renewalDate: DateTime.parse(data['renewal_date']),
      nextRenewalDate:
          (data['next_renewal_date'] == null ||
              data['next_renewal_date'].toString().isEmpty)
          ? DateTime.parse(data['renewal_date'])
          : DateTime.parse(data['next_renewal_date']),
      repeatInterval: data['repeat_interval']?.toString() ?? 'Monthly',
      category: data['category']?.toString() ?? '',
      notes: data['notes'] ?? '',
      reminderOffsetDays:
          int.tryParse(data['reminder_offset_days'].toString()) ?? 0,
      userId: data['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'renewal_date': renewalDate.toIso8601String(),
      'next_renewal_date': nextRenewalDate.toIso8601String(),
      'category': category,
      'notes': notes,
      'reminder_offset_days': reminderOffsetDays,
      'repeat_interval': repeatInterval,
      'user_id': userId,
    };
  }

  int get daysUntilRenewal {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return nextRenewalDate.difference(today).inDays;
  }
}
