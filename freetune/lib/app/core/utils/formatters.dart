import 'package:intl/intl.dart';
import 'dart:math';

class Formatters {
  /// Format Duration object to HH:MM:SS or MM:SS
  static String formatDuration(dynamic duration) {
    Duration d;
    if (duration is int) {
      // If int, assume it's milliseconds
      d = Duration(milliseconds: duration);
    } else if (duration is Duration) {
      d = duration;
    } else {
      return '00:00';
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    
    // Only show hours if duration is >= 1 hour
    if (d.inHours > 0) {
      return '${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    }
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Format relative time (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(dateTime);
    }
  }

  /// Format number with K, M, B suffixes
  static String formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    if (count < 1000000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    return '${(count / 1000000000).toStringAsFixed(1)}B';
  }
}