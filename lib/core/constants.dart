import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color primaryHover = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color accent = Color(0xFF6366F1);

  // Backgrounds & Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Borders
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFF0FDF4);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEF2F2);
}

class AppConstants {
  // Live Render cloud deployment (default)
  static const String renderUrl = 'https://e-commerce-store-anqa.onrender.com/api';

  // Localhost (Windows desktop / iOS simulator / Flutter Web)
  static const String localHostUrl = 'http://localhost:5000/api';

  // Android Emulator pointing to host computer localhost
  static const String androidEmulatorUrl = 'http://10.0.2.2:5000/api';

  // Active Base URL: points to the live Render backend
  static const String baseUrl = renderUrl;
  static const String appName = 'BuyBuddy';
  static const String stripePublishableKey = 'pk_test_51RZsHRE65I6UmEu1gzLA4ceeeFz5i8XM5sL3PgIwJC35Jg4C4mHa9wSe3548CutR4g2VztEidkhqm7KJvv9FVynZ00sFe5OLBC';
}
