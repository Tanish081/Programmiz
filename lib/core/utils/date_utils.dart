class AppDateUtils {
  static DateTime todayLocalDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String todayIsoDate() {
    final today = todayLocalDate();
    return today.toIso8601String();
  }

  static DateTime parseIsoDate(String value) {
    final parsed = DateTime.parse(value);
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static int dayDifference(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }
}
