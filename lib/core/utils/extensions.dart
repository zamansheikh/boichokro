import 'package:intl/intl.dart';

/// String extensions
extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  bool get isValidPhone {
    return RegExp(r'^\+?[1-9]\d{9,14}$').hasMatch(this);
  }
}

/// DateTime extensions
extension DateTimeExtensions on DateTime {
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String toFormattedDate() {
    return DateFormat('MMM dd, yyyy').format(this);
  }

  String toFormattedDateTime() {
    return DateFormat('MMM dd, yyyy hh:mm a').format(this);
  }

  String toTimeOnly() {
    return DateFormat('hh:mm a').format(this);
  }
}

/// Double extensions for distance
extension DoubleExtensions on double {
  String toDistanceString() {
    if (this < 1) {
      return '${(this * 1000).toStringAsFixed(0)}m';
    } else {
      return '${toStringAsFixed(1)}km';
    }
  }
}

/// List extensions
extension ListExtensions<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
