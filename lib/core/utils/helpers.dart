import 'package:makan_mate/features/auth/presentation/bloc/auth_state.dart';

/// ------------------------------------------------------------
/// AuthState convenience checks (tiny ergonomics boost in UI)
/// ------------------------------------------------------------
extension AuthStateX on AuthState {
  bool get isLoading => this is AuthLoading;
  bool get isAuthenticated => this is Authenticated;
  bool get isUnauthenticated => this is Unauthenticated;
  bool get hasError => this is AuthError;

  /// Returns the error message if state is AuthError, else null.
  String? get errorMessage =>
      this is AuthError ? (this as AuthError).message : null;
}

/// ------------------------------------------------------------
/// General helpers (small, reusable utilities)
/// ------------------------------------------------------------
class Helpers {
  /// Returns true if the string is null or empty after trimming.
  static bool isNullOrEmpty(String? value) =>
      value == null || value.trim().isEmpty;

  /// Safely parses an int; returns [defaultValue] if parsing fails.
  static int tryParseInt(String? value, {int defaultValue = 0}) =>
      int.tryParse(value ?? '') ?? defaultValue;

  /// Capitalizes the first letter of a non-empty string.
  static String capitalize(String text) =>
      text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';

  /// Truncates a string to [maxLength] and adds ellipsis if needed.
  static String truncate(String text, [int maxLength = 50]) =>
      text.length <= maxLength ? text : '${text.substring(0, maxLength)}…';

  /// Masks an email for UI display (e.g., joh***@mail.com).
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].isEmpty) return email;
    final name = parts[0];
    final masked = name.length <= 3
        ? '${name[0]}***'
        : '${name.substring(0, 3)}***';
    return '$masked@${parts[1]}';
  }
}
