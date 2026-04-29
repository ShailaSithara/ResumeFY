// lib/core/utils/validators.dart

class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    final regex = RegExp(r'^\+?[\d\s\-\(\)]{7,15}$');
    if (!regex.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }

  static String? year(String? value) {
    if (value == null || value.isEmpty) return null;
    final year = int.tryParse(value);
    if (year == null || year < 1950 || year > 2030) {
      return 'Enter a valid year';
    }
    return null;
  }
}
