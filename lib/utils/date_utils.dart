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
