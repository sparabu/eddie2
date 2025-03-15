/// Validation utilities for form validation
class ValidationUtils {
  /// Validates if the given string is a valid email address
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validates if the password meets minimum requirements
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Validates if passwords match
  static bool doPasswordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
} 