class DateTimeHelpers {
  
  // ✅ OBLICZANIE END TIME NA PODSTAWIE START TIME + DURATION
  static DateTime calculateEndTime(DateTime startTime, int durationInSeconds) {
    return startTime.add(Duration(seconds: durationInSeconds));
  }

  // ✅ FORMATOWANIE DATY
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  // ✅ FORMATOWANIE CZASU (GODZINA:MINUTA:SEKUNDA)
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  // ✅ FORMATOWANIE CZASU (GODZINA:MINUTA)
  static String formatTimeShort(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // ✅ SZCZEGÓŁOWE FORMATOWANIE CZASU TRWANIA
  static String formatDetailedDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final secs = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  // ✅ RANGE DAT SESJI
  static String getSessionDateRange(DateTime start, DateTime end) {
    if (start.day == end.day && start.month == end.month && start.year == end.year) {
      return formatDateTime(start);
    } else {
      return '${formatDateTime(start)} - ${formatDateTime(end)}';
    }
  }

  // ✅ DZIEŃ TYGODNIA
  static String getDayOfWeek(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  // ✅ ILE DNI TEMU
  static String getDaysAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    return "$difference days ago";
  }

  // ✅ FORMATOWANIE PEŁNEGO RANGE CZASOWEGO
  static String formatFullTimeRange(DateTime startTime, int durationInSeconds) {
    final endTime = calculateEndTime(startTime, durationInSeconds);
    final startTimeStr = formatTimeShort(startTime);
    final endTimeStr = formatTimeShort(endTime);
    return '$startTimeStr - $endTimeStr';
  }

  // ✅ SPRAWDZENIE CZY SESJA TRWA WIĘCEJ NIŻ JEDEN DZIEŃ
  static bool isMultiDaySession(DateTime startTime, int durationInSeconds) {
    final endTime = calculateEndTime(startTime, durationInSeconds);
    return startTime.day != endTime.day || 
           startTime.month != endTime.month || 
           startTime.year != endTime.year;
  }
}