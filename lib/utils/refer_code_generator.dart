import 'package:uuid/uuid.dart';

/// Kullanıcıya özel referans kodu üretici
class ReferCodeGenerator {
  /// Kullanıcı adı ve id ile benzersiz, okunabilir kod üretir
  static String generate({required String userId, String? username}) {
    if (username != null && username.isNotEmpty) {
      final slug = username.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      return slug + userId.substring(0, 4);
    }
    return const Uuid().v4().substring(0, 8);
  }
} 