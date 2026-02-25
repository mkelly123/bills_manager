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
