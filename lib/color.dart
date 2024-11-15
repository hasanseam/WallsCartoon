import 'package:flutter/material.dart';

// Define your color constants for both light and dark modes
class AppColors {
  // Default (non-theme dependent) primary, secondary, button, and description colors
  static const Color _primaryColorLight = Color(0xFF4A4459); // Main theme color for light mode
  static const Color _secondaryColorLight = Color(0xFFD3CAE2);
  static const Color _buttonTextColorLight = Color(0xFFFFFFFF); // Button text color for light mode
  static const Color _descriptionColorLight = Color(0xFF787878); // Description text color for light mode
  static const Color _likeBorderColorLight = Color(0xFFD3CAE2); // Like button border color for light mode
  static const Color _likeColorLight = Color(0xFF4A4459);
  static const Color _cleaningIconColorLight = Color(0xFFC64475);
  static const Color _cleanListButtonTextColorLight = Color(0xFFFDFDFD);// Like heart icon color for light mode

  static const Color _primaryColorDark = Color(0xFFF6E9FF); // Main theme color for dark mode
  static const Color _secondaryColorDark = Color(0xFF4A4459);
  static const Color _buttonTextColorDark = Color(0xFF100B19); // Button text color for dark mode
  static const Color _descriptionColorDark = Color(0xFFB1B1B1); // Description text color for dark mode
  static const Color _likeBorderColorDark = Color(0xFFD2C9E1); // Like button border color for dark mode
  static const Color _likeColorDark = Color(0xFF4A4459);
  static const Color _cleaningIconColorDark = Color(0xFFC64475);
  static const Color _cleanListButtonTextColorDark = Color(0xFFFBFBFB);

  // Light Mode Colors
  static const Color backgroundColorLight = Color(0xFFFEF7FF);
  static const Color borderColorLight = Color(0xFFE8DEF8);
  static const Color selectedButtonColorLight = Color(0xFFE7DDF7);

  // Dark Mode Colors
  static const Color backgroundColorDark = Color(0xFF141218);
  static const Color borderColorDark = Color(0xFF3A314D);
  static const Color selectedButtonColorDark = Color(0xFF3A314D);

  // Helper methods to get the appropriate color based on theme brightness
  static Color primaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _primaryColorDark
        : _primaryColorLight;
  }

  static Color secondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _secondaryColorDark
        : _secondaryColorLight;
  }

  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundColorDark
        : backgroundColorLight;
  }

  static Color borderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? borderColorDark
        : borderColorLight;
  }

  static Color selectedButtonColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? selectedButtonColorDark
        : selectedButtonColorLight;
  }

  // New methods for button text color, description color, like button border color, and like button color
  static Color buttonTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _buttonTextColorDark
        : _buttonTextColorLight;
  }

  static Color descriptionColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _descriptionColorDark
        : _descriptionColorLight;
  }

  static Color likeBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _likeBorderColorDark
        : _likeBorderColorLight;
  }

  static Color likeColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _likeColorDark
        : _likeColorLight;
  }

  static Color cleaningIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _cleaningIconColorDark
        : _cleaningIconColorLight;
  }

  static Color cleanListButtonTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _cleanListButtonTextColorDark
        : _cleanListButtonTextColorLight;
  }
}