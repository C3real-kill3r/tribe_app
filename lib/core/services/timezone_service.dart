import 'package:intl/intl.dart';

/// Service for handling timezone conversions and time formatting.
/// 
/// This service automatically detects the user's local timezone and converts
/// UTC timestamps from the backend to the user's local time.
class TimezoneService {
  static final TimezoneService _instance = TimezoneService._internal();
  factory TimezoneService() => _instance;
  TimezoneService._internal();

  /// Get the user's local timezone name
  String get localTimezoneName {
    return DateTime.now().timeZoneName;
  }

  /// Get the user's local timezone offset in hours
  int get localTimezoneOffsetHours {
    return DateTime.now().timeZoneOffset.inHours;
  }

  /// Convert a UTC DateTime to local time
  /// 
  /// If the DateTime is already in local time, it will be returned as-is.
  /// If it's in UTC, it will be converted to local time.
  DateTime toLocalTime(DateTime utcDateTime) {
    // Convert from UTC to local time
    // DateTime.toLocal() handles both UTC and local times correctly
    return utcDateTime.toLocal();
  }

  /// Parse a UTC ISO8601 string and convert to local time
  DateTime parseUtcToLocal(String utcIso8601String) {
    try {
      // Parse as UTC
      final utcDateTime = DateTime.parse(utcIso8601String);
      // Convert to local time
      return utcDateTime.toLocal();
    } catch (e) {
      // If parsing fails, try parsing as local time
      return DateTime.parse(utcIso8601String);
    }
  }

  /// Format a date for display (handles UTC to local conversion)
  /// 
  /// Returns formatted date string like "Today", "Yesterday", "Monday", or "Jan 1, 2024"
  String formatDate(DateTime date) {
    // Convert to local time if it's UTC
    final localDate = date.isUtc ? date.toLocal() : date;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(localDate.year, localDate.month, localDate.day);
    
    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(localDate).inDays < 7) {
      return DateFormat('EEEE').format(localDate);
    } else {
      return DateFormat('MMM d, yyyy').format(localDate);
    }
  }

  /// Format a time for display (handles UTC to local conversion)
  /// 
  /// Returns formatted time string like "10:30 AM" or "2:45 PM"
  String formatTime(DateTime date) {
    // Convert to local time if it's UTC
    final localDate = date.isUtc ? date.toLocal() : date;
    return DateFormat('h:mm a').format(localDate);
  }

  /// Format a date and time for display (handles UTC to local conversion)
  /// 
  /// Returns formatted string like "Jan 1, 2024 at 10:30 AM"
  String formatDateTime(DateTime date) {
    // Convert to local time if it's UTC
    final localDate = date.isUtc ? date.toLocal() : date;
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(localDate);
  }

  /// Get relative time string (e.g., "2 minutes ago", "1 hour ago")
  /// 
  /// Returns relative time string for recent dates, or formatted date for older ones
  String getRelativeTime(DateTime date) {
    // Convert to local time if it's UTC
    final localDate = date.isUtc ? date.toLocal() : date;
    final now = DateTime.now();
    final difference = now.difference(localDate);

    if (difference.inDays > 7) {
      return formatDate(localDate);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if two dates are on the same day (in local time)
  bool isSameDay(DateTime date1, DateTime date2) {
    // Convert to local time if they're UTC
    final local1 = date1.isUtc ? date1.toLocal() : date1;
    final local2 = date2.isUtc ? date2.toLocal() : date2;
    return local1.year == local2.year &&
           local1.month == local2.month &&
           local1.day == local2.day;
  }
}

