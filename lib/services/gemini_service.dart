import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;

  // Constructor - bu satır eksikti!
  GeminiService({required this.apiKey});

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';

  static const String _systemPrompt = '''
Sen sadece Türk hukuk sistemi üzerine uzmanlaşmış bir yapay zekâ danışmanısın. 

 İZİN VERİLEN KONULAR:
- Türk Ceza Kanunu (TCK) ve ilgili maddeler
- Ceza Muhakemesi Kanunu (CMK) süreçleri
- Hukuk Muhakemeleri Kanunu ve dava türleri
- Avukatlık mesleği, hakları ve yükümlülükleri
- Boşanma, miras, tapu, icra işlemleri
- Mahkeme süreçleri ve dava açma prosedürleri
- Müvekkil hakları ve yükümlülükleri
- Hukuki belge hazırlama (dilekçe, sözleşme vb.)
- Adli yardım ve hukuki destek
- Türk Anayasa Mahkemesi kararları
- Yargıtay ve Danıştay kararları

 KESİNLİKLE YASAK KONULAR:
- Kişisel hukuki tavsiye (sadece genel bilgi ver)
- Spesifik dava sonucu tahmini
- Avukat önerisi veya tavsiyesi
- Sağlık, spor, teknoloji, edebiyat gibi hukuk dışı konular
- Siyasi görüş veya yorum
- Kişisel veri işleme
- Yasadışı faaliyetler hakkında bilgi

 GÜVENLİK KURALLARI:
- Kullanıcıya sadece genel hukuki bilgi ver
- "Bu konuda avukatınıza danışmanızı öneririm" ifadesini kullan
- Kişisel bilgi isteme
- Yasal sorumluluk reddi: "Bu bilgiler genel niteliktedir"

📝 CEVAP FORMATI:
- Net, anlaşılır ve teknik açıklamalar
- İlgili kanun maddelerini belirt
- Pratik örnekler ver
- Güvenlik uyarısı ekle

❗ HUKUK DIŞI SORULAR İÇİN:
"Bu, uzmanlık alanım olan hukuk dışında bir konu olduğu için yardımcı olamıyorum. Size hukuki konularda yardımcı olmaktan memnuniyet duyarım."

Senin görevin, kullanıcıya sadece hukuki konularda güvenilir, genel bilgilerle rehberlik etmektir.
''';

  static const List<String> _forbiddenWords = [
    'bomba',
    'silah',
    'uyuşturucu',
    'hack',
    'kırma',
    'çalma',
    'dolandırma',
    'sahte',
    'sahtecilik',
    'kaçak',
    'kaçırma',
    'rehin',
    'fidye',
  ];

  bool _isMessageSafe(String message) {
    final lowerMessage = message.toLowerCase();
    for (final word in _forbiddenWords) {
      if (lowerMessage.contains(word)) {
        return false;
      }
    }
    return true;
  }

  Future<String> sendMessage(String userMessage) async {
    // Güvenlik kontrolü
    if (!_isMessageSafe(userMessage)) {
      return 'Bu tür sorulara cevap veremiyorum. Lütfen hukuki konularda sorularınızı yöneltin.';
    }

    // Mesaj uzunluğu kontrolü
    if (userMessage.length > 1000) {
      return 'Mesajınız çok uzun. Lütfen sorunuzu daha kısa bir şekilde ifade edin.';
    }

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': '$_systemPrompt\n\nKullanıcı sorusu: $userMessage'},
                ],
              },
            ],
            'generationConfig': {
              'temperature': 0.7, // Daha tutarlı cevaplar için düşürüldü
              'maxOutputTokens': 600, // Daha kısa cevaplar
              'topP': 0.8,
              'topK': 40,
            },
            'safetySettings': [
              {
                'category': 'HARM_CATEGORY_HARASSMENT',
                'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
              },
              {
                'category': 'HARM_CATEGORY_HATE_SPEECH',
                'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
              },
              {
                'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
                'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
              },
              {
                'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
              },
            ],
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['candidates'] != null && data['candidates'].isNotEmpty) {
            String responseText =
                data['candidates'][0]['content']['parts'][0]['text'];

            // Güvenlik uyarısı ekle
            if (!responseText.contains('Bu bilgiler genel niteliktedir')) {
              responseText +=
                  '\n\n⚠️ Bu bilgiler genel niteliktedir. Spesifik durumunuz için avukatınıza danışmanızı öneririm.';
            }

            return responseText;
          } else {
            return 'Üzgünüm, şu anda size yardımcı olamıyorum. Lütfen sorunuzu farklı şekilde ifade edin.';
          }
        } else if (response.statusCode == 503) {
          // Server overloaded, retry after delay
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(
              Duration(seconds: 2 * retryCount),
            ); // Exponential backoff
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
