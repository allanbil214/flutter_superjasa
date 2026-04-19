import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2563EB); // Blue 600
  static const Color primaryLight = Color(0xFF60A5FA); // Blue 400
  static const Color primaryDark = Color(0xFF1E40AF); // Blue 800
  
  // Secondary Colors
  static const Color secondary = Color(0xFF10B981); // Emerald 500
  static const Color secondaryLight = Color(0xFF34D399); // Emerald 400
  static const Color secondaryDark = Color(0xFF047857); // Emerald 700
  
  // Neutral Colors
  static const Color background = Color(0xFFF9FAFB); // Gray 50
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color card = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Gray 900
  static const Color textSecondary = Color(0xFF6B7280); // Gray 500
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray 400
  static const Color textInverse = Color(0xFFFFFFFF);
  
  // Border & Divider
  static const Color border = Color(0xFFE5E7EB); // Gray 200
  static const Color divider = Color(0xFFF3F4F6); // Gray 100
  
  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color info = Color(0xFF3B82F6); // Blue 500
  
  // Order Status Colors
  static const Color statusPending = Color(0xFFF59E0B); // Amber
  static const Color statusConfirmed = Color(0xFF3B82F6); // Blue
  static const Color statusAssigned = Color(0xFF8B5CF6); // Purple
  static const Color statusOnTheWay = Color(0xFFEC4899); // Pink
  static const Color statusInProgress = Color(0xFF06B6D4); // Cyan
  static const Color statusDone = Color(0xFF10B981); // Emerald
  static const Color statusReviewed = Color(0xFF6366F1); // Indigo
  static const Color statusCancelled = Color(0xFFEF4444); // Red
  
  // Rating Star
  static const Color starActive = Color(0xFFFBBF24); // Amber 400
  static const Color starInactive = Color(0xFFD1D5DB); // Gray 300
  
  // Chat Bubbles
  static const Color bubbleCustomer = Color(0xFF2563EB); // Primary
  static const Color bubbleAdmin = Color(0xFF10B981); // Secondary
  static const Color bubbleEmployee = Color(0xFF8B5CF6); // Purple
  static const Color bubbleBot = Color(0xFFF3F4F6); // Gray 100
  static const Color bubbleSystem = Color(0xFFE5E7EB); // Gray 200
  
  // Prevent instantiation
  AppColors._();
}