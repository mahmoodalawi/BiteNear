import 'package:flutter/material.dart';

/// Central color palette for BiteNear.
///
/// The palette leans on warm, appetite-stimulating tones (tomato red,
/// saffron, charcoal) balanced with clean neutrals for readability.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFFF5A3C); // warm tomato
  static const Color primaryDark = Color(0xFFE03E22);
  static const Color secondary = Color(0xFFFFB627); // saffron
  static const Color accent = Color(0xFF2EC4B6); // fresh mint

  // Neutrals
  static const Color charcoal = Color(0xFF1F1D2B);
  static const Color textPrimary = Color(0xFF24262B);
  static const Color textSecondary = Color(0xFF8A8D9F);
  static const Color background = Color(0xFFFDFBF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFEDEDF2);

  // Semantic
  static const Color success = Color(0xFF2BB673);
  static const Color warning = Color(0xFFFFB627);
  static const Color error = Color(0xFFE53935);
  static const Color star = Color(0xFFFFC529);

  // Gradients
  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF7A50), Color(0xFFFF5A3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient photoScrim = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
