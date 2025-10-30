import 'package:intl/intl.dart';

/// A utility class for consistent date and time formatting.
class DateFormatter {
  /// Formats a DateTime as `dd MMM yyyy` (e.g., 20 Oct 2025).
  static String formatShortDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Formats a DateTime as `dd MMM yyyy, hh:mm a` (e.g., 20 Oct 2025, 5:00 PM).
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  /// Returns a relative time description (e.g., "5 min ago", "Yesterday").
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';

    return DateFormat('dd MMM yyyy').format(date);
  }
}