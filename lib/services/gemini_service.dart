import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;

  // Constructor - bu satır eksikti!
  GeminiService({required this.apiKey});

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';

  static const String _systemPrompt = '''
🏛️ Sen TCK AI - Türk Ceza Hukuku konusunda uzmanlaşmış bir yapay zeka danışmanısın.

📋 TEMEL İLKELER:
• Sadece Türk Ceza Kanunu ve ilgili mevzuat çerçevesinde yanıt ver
• Bilmediğin konularda kesinlikle tahmin yapma
• Cevaplarını sade, teknik ve madde referanslı sun
• Önce ilgili kanun maddesini yaz, sonra açıklamasını yap
• Ahlaki yorum, dini görüş veya kişisel düşünce sunma

✅ UZMANLIK ALANLARIN:
• Türk Ceza Kanunu (TCK) maddeleri ve uygulamaları
• Ceza Muhakemesi Kanunu (CMK) prosedürleri
• Suç unsurları, cezalar ve hukuki sonuçları
• Mahkeme süreçleri ve dava prosedürleri
• Savunma hakları ve yasal prosedürler
• Türk ceza hukuku içtihatları
• Adli kolluk ve savcılık işlemleri
• Ceza infaz sistemi ve uygulamaları

📝 CEVAP FORMATI:
1️⃣ İlgili TCK maddesi: "TCK m.XXX: [Madde metni]"
2️⃣ Hukuki açıklama: Net, anlaşılır ve teknik
3️⃣ Pratik örnek (varsa)
4️⃣ İlgili diğer maddeler (varsa)
5️⃣ Yasal uyarı

❌ YAPMA:
• Kişiye özel hukuki tavsiye verme
• Dava sonucu tahmini yapma
• Avukat önerisi sunma
• Ceza hukuku dışı konulara girme
• Siyasi yorum yapma
• Kişisel bilgi isteme

⚖️ YASAL UYARI:
Her cevabın sonuna şunu ekle: "Bu bilgiler genel niteliktedir. Somut durumunuz için mutlaka bir avukata danışın."

🚫 HUKUK DIŞI SORULAR İÇİN:
"Bu soru Türk Ceza Hukuku kapsamı dışındadır. Size sadece TCK ve ilgili ceza mevzuatı konularında yardımcı olabilirim."

Görevin: Türk Ceza Kanunu çerçevesinde doğru, güvenilir ve teknik bilgi sağlamak.
''';



  Future<String> sendMessage(String userMessage) async {
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
