# Hukuki Asistan - Turkish Legal Assistant App

Türk hukuk sistemi için AI destekli mobil hukuki danışman uygulaması.

## 🚀 Özellikler

### 🤖 AI'ye Sor
- Google Gemini API entegrasyonu
- Türk hukuk sistemi konusunda uzmanlaşmış AI danışmanı
- Özel prompt engineering ile yalnızca hukuki konularda yardım
- Anlık soru-cevap desteği

### 📞 Avukatla İletişim
- Telefon arama özelliği
- WhatsApp entegrasyonu
- E-posta gönderme
- Randevu talep sistemi
- Çalışma saatleri bilgisi

### 📁 Dosya Yönetimi
- Belge yükleme ve kategorilendirme
- PDF, Word, resim dosyası desteği
- Sözleşme, dava dosyası, kimlik belgesi vb. kategoriler
- Güvenli yerel depolama

### 📅 Takvim
- Duruşma takibi
- Randevu planlama
- Müvekkil görüşmeleri
- Etkinlik ekleme/silme/düzenleme

## 🛠️ Teknik Özellikler

- **Framework:** Flutter
- **AI API:** Google Gemini Pro
- **Yerel Depolama:** SharedPreferences
- **UI/UX:** Material Design
- **Dosya İşlemleri:** File Picker
- **İletişim:** URL Launcher
- **Takvim:** Table Calendar

## 📱 Kurulum

### Gereksinimler
- Flutter SDK (3.8.1+)
- Android Studio / VS Code
- Google Gemini API anahtarı

### Adımlar

1. Projeyi klonlayın:
```bash
git clone <repository-url>
cd hukuki_asistan
```

2. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

3. Gemini API anahtarını ekleyin:
`lib/services/gemini_service.dart` dosyasında:
```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
```
satırını kendi API anahtarınızla değiştirin.

4. Uygulamayı çalıştırın:
```bash
flutter run
```

## 🔑 API Anahtarı Alma

1. [Google AI Studio](https://makersuite.google.com/app/apikey) sayfasına gidin
2. Yeni API anahtarı oluşturun
3. Anahtarı `gemini_service.dart` dosyasına ekleyin

## 🎨 Renk Paleti

- **Ana Renk:** #2D3E50 (Koyu Mavi-Gri)
- **Arkaplan:** Beyaz
- **Aksan Renkleri:** 
  - Mavi: Randevular için
  - Kırmızı: Duruşmalar için
  - Yeşil: Belgeler için
  - Turuncu: Müvekkil görüşmeleri için

## 📋 Prompt Engineering

AI asistanı yalnızca şu konularda yardım sağlar:
- Türk Ceza Kanunu (TCK)
- Ceza Muhakemesi Kanunu (CMK)
- Hukuk Muhakemeleri Kanunu
- Avukatlık mesleği ve süreçleri
- Boşanma, miras, tapu, icra, dava açma
- Mahkeme süreçleri ve dava türleri
- Müvekkil hakları ve yükümlülükleri

Diğer konulardaki sorulara "uzmanlık alanım dışında" yanıtı verir.

## 🏗️ Proje Yapısı

```
lib/
├── main.dart                 # Ana uygulama dosyası
├── screens/                  # Ekran bileşenleri
│   ├── home_screen.dart     # Ana menü
│   ├── ai_chat_screen.dart  # AI sohbet ekranı
│   ├── lawyer_contact_screen.dart # Avukat iletişim
│   ├── documents_screen.dart # Dosya yönetimi
│   └── calendar_screen.dart # Takvim
└── services/
    └── gemini_service.dart  # Gemini API entegrasyonu
```

## 🚧 Gelecek Özellikler

- [ ] Offline AI desteği
- [ ] Push notification sistemi
- [ ] Çoklu dil desteği
- [ ] Gelişmiş dosya arama
- [ ] Bulut senkronizasyonu
- [ ] Biometric authentication

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

