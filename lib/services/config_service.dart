import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _apiKeyKey = 'gemini_api_key';
  static const String _userNameKey = 'user_name';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _chatCountKey = 'chat_count';
  static const String _lastChatDateKey = 'last_chat_date';
  static const String _blockedMessagesKey = 'blocked_messages';

  // API Key'i güvenli şekilde sakla
  static Future<void> setApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }

  // API Key'i al
  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  // Kullanıcı adını sakla
  static Future<void> setUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, userName);
  }

  // Kullanıcı adını al
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // İlk açılış kontrolü
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  // İlk açılış tamamlandı
  static Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstLaunchKey, false);
  }

  // Chat sayısını artır
  static Future<void> incrementChatCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_chatCountKey) ?? 0;
    await prefs.setInt(_chatCountKey, currentCount + 1);
  }

  // Toplam chat sayısını al
  static Future<int> getChatCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_chatCountKey) ?? 0;
  }

  // Son chat tarihini güncelle
  static Future<void> updateLastChatDate() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    await prefs.setString(_lastChatDateKey, now);
  }

  // Son chat tarihini al
  static Future<DateTime?> getLastChatDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_lastChatDateKey);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  // Engellenen mesaj sayısını artır
  static Future<void> incrementBlockedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_blockedMessagesKey) ?? 0;
    await prefs.setInt(_blockedMessagesKey, currentCount + 1);
  }

  // Engellenen mesaj sayısını al
  static Future<int> getBlockedMessagesCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_blockedMessagesKey) ?? 0;
  }

  // Günlük kullanım istatistikleri
  static Future<Map<String, dynamic>> getDailyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().day;
    final lastChatDate = await getLastChatDate();

    return {
      'total_chats': await getChatCount(),
      'blocked_messages': await getBlockedMessagesCount(),
      'last_chat_date': lastChatDate?.toIso8601String(),
      'chats_today': lastChatDate?.day == today ? 1 : 0,
    };
  }

  // Tüm verileri temizle
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
