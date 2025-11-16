import 'package:flutter/foundation.dart';

/// Simple controller to request navigation to a specific admin section
class AdminNavController extends ChangeNotifier {
  String? _targetSectionTitle;

  String? get targetSectionTitle => _targetSectionTitle;

  /// Request navigation to a section by its page title (as shown in AdminMainPage).
  /// Example: 'Vendor Management', 'User Management', 'Audit Log Viewer', 'System Configuration'
  void goTo(String title) {
    _targetSectionTitle = title;
    notifyListeners();
  }

  /// Clear the pending target after it has been handled.
  void clear() {
    _targetSectionTitle = null;
  }
}


