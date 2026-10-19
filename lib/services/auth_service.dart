import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Giriş simülasyonu. Gerçek backend'e bağlamak için sadece [login]
/// içindeki "await Future.delayed" bölümünü HTTP isteğiyle değiştirin.
class AuthService extends ChangeNotifier {
  static const _kUser = 'logged_user';

  String? _identifier;
  bool get isLoggedIn => _identifier != null;

  /// "ali.yilmaz@mail.com" -> "Ali Yilmaz"
  String get displayName {
    final raw = (_identifier ?? '').split('@').first;
    final words = raw
        .replaceAll(RegExp(r'[._\-]+'), ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty);
    return words
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _identifier = p.getString(_kUser);
  }

  /// Başarılıysa null, hatalıysa hata mesajı döner.
  Future<String?> login(String identifier, String password) async {
    await Future.delayed(const Duration(milliseconds: 1300)); // sunucu simülasyonu
    if (identifier.trim().isEmpty) return 'Kullanıcı adı / e-posta gerekli';
    if (password.length < 4) return 'Şifre en az 4 karakter olmalı';

    _identifier = identifier.trim();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kUser, _identifier!);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _identifier = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(_kUser);
    notifyListeners();
  }
}
