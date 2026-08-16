import 'dart:math';

/// Pure-Dart RFC 4122 v4 UUID generator and validator.
class AppUuid {
  static final _random = Random.secure();
  static final _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  /// Validates whether [id] is a valid 36-character UUID.
  static bool isValid(String? id) {
    if (id == null || id.isEmpty) return false;
    return _uuidRegex.hasMatch(id);
  }

  /// Generates a cryptographic random UUID v4.
  static String generate() {
    final values = List<int>.generate(16, (_) => _random.nextInt(256));
    // Set version to 4
    values[6] = (values[6] & 0x0f) | 0x40;
    // Set variant to RFC 4122
    values[8] = (values[8] & 0x3f) | 0x80;

    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }
}
