import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color accent = Color(0xFF00BCD4);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color surfaceLight = Color(0xFFF5F5F5);

  // Ticket priority colors
  static const Color priorityCritical = Color(0xFFD32F2F);
  static const Color priorityHigh = Color(0xFFF57C00);
  static const Color priorityMedium = Color(0xFFFFC107);
  static const Color priorityLow = Color(0xFF4CAF50);

  // Ticket status colors
  static const Color statusNew = Color(0xFF2196F3);
  static const Color statusAssigned = Color(0xFF9C27B0);
  static const Color statusPending = Color(0xFFFFA726);
  static const Color statusResolved = Color(0xFF4CAF50);
  static const Color statusClosed = Color(0xFF757575);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  /// Returns the color based on ticket priority
  static Color getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'critical':
      case 'critica':
        return priorityCritical;
      case 'high':
      case 'alta':
        return priorityHigh;
      case 'medium':
      case 'media':
        return priorityMedium;
      case 'low':
      case 'bassa':
        return priorityLow;
      default:
        return Colors.grey;
    }
  }

  /// Returns the color based on ticket status
  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'new':
      case 'nuovo':
        return statusNew;
      case 'assigned':
      case 'assegnato':
        return statusAssigned;
      case 'pending':
      case 'in attesa':
        return statusPending;
      case 'resolved':
      case 'risolto':
        return statusResolved;
      case 'closed':
      case 'chiuso':
        return statusClosed;
      default:
        return Colors.grey;
    }
  }

  /// Returns the icon based on ticket status
  static IconData getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'new':
      case 'nuovo':
        return Icons.fiber_new;
      case 'assigned':
      case 'assegnato':
        return Icons.person;
      case 'pending':
      case 'in attesa':
        return Icons.hourglass_empty;
      case 'resolved':
      case 'risolto':
        return Icons.check_circle;
      case 'closed':
      case 'chiuso':
        return Icons.lock;
      default:
        return Icons.help_outline;
    }
  }
}
