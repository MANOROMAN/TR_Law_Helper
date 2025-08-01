import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;
  
  // Constructor - bu satır eksikti!
  GeminiService({required this.apiKey});
  
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';
  
  // Türk hukuk sistemi için özel prompt
  static const String _systemPrompt = '''
Sen sadece Türk hukuk sistemi üzerine uzmanlaşmış bir yapay zekâ danışmanısın. Cevaplarını yalnızca şu konularla sınırlı tut:

- Türk Ceza Kanunu (TCK)
- Ceza Muhakemesi Kanunu (CMK)
- Hukuk Muhakemeleri Kanunu
- Avukatlık mesleği ve süreçleri
- Boşanma, miras, tapu, icra, dava açma
- Mahkeme süreçleri ve dava türleri
- Müvekkil hakları ve yükümlülükleri

Lütfen yalnızca bu konularla ilgili net, teknik, anlaşılır ve yasalara dayalı açıklamalar yap.

❗ Diğer tüm alanlara dair (örneğin sağlık, spor, teknoloji, edebiyat vs.) gelen sorulara şu şekilde cevap ver:
"Bu, uzmanlık alanım olan hukuk dışında bir konu olduğu için yardımcı olamıyorum."

Senin görevin, kullanıcıya sade, güvenilir ve sadece hukuki bilgilerle rehberlik etmektir.
''';

  Future<String> sendMessage(String userMessage) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl?key=$apiKey'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': '$_systemPrompt\n\nKullanıcı sorusu: $userMessage'}
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.9,
              'maxOutputTokens': 800,
            }
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['candidates'] != null && data['candidates'].isNotEmpty) {
            return data['candidates'][0]['content']['parts'][0]['text'];
          } else {
            return 'Üzgünüm, şu anda size yardımcı olamıyorum. Lütfen sorunuzu farklı şekilde ifade edin.';
          }
        } else if (response.statusCode == 503) {
          // Server overloaded, retry after delay
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: 2 * retryCount)); // Exponential backoff
            continue;
          } else {
            return 'Sistem şu anda çok yoğun. Lütfen birkaç dakika sonra tekrar deneyin.';
          }
        } else {
          return 'API Hatası: ${response.statusCode}\nLütfen daha sonra tekrar deneyin.';
        }
      } catch (e) {
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * retryCount));
          continue;
        } else {
          return 'Bağlantı sorunu yaşanıyor. İnternet bağlantınızı kontrol edin.';
        }
      }
    }

    return 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
  }
}
