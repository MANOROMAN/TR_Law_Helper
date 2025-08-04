import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/app_colors.dart';

class LegalDictionaryScreen extends StatefulWidget {
  @override
  _LegalDictionaryScreenState createState() => _LegalDictionaryScreenState();
}

class _LegalDictionaryScreenState extends State<LegalDictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Hukuki terimler listesi
  final Map<String, String> _legalTerms = {
    'Adalet': 'Hukuksal ve ahlaki açıdan doğru olanı ifade eden temel kavram. Hak sahiplerine haklarını veren, suçluları cezalandıran sistem.',
    'Avukat': 'Hukuk fakültesi mezunu olup, barokaydı bulunan ve müvekkillerin hukuki işlerini yürüten kişi.',
    'Barolar': 'Avukatların meslek kuruluşları. Avukatlık mesleğinin düzenlenmesi ve denetimi görevini üstlenir.',
    'Ceza Hukuku': 'Suç teşkil eden fiilleri ve bunlara verilecek cezaları düzenleyen hukuk dalı.',
    'Dava': 'Mahkemede görülen hukuki uyuşmazlık. Taraflar arasındaki anlaşmazlığın çözümlenmesi süreci.',
    'Emsal': 'Benzer durumlarda referans alınan önceki mahkeme kararları. Yargısal içtihat oluşturur.',
    'Fesih': 'Bir sözleşmenin hukuki nedenlerle sona erdirilmesi. Genellikle ihlal durumunda uygulanır.',
    'Gasp': 'Başkasının malını zorla ve tehdit kullanarak alma suçu. Türk Ceza Kanunu\'nda düzenlenmiştir.',
    'Hâkim': 'Yargı yetkisini kullanan, mahkemelerde karar veren kamu görevlisi.',
    'İcra': 'Mahkeme kararlarının ve icra edilebilir belgelerin zorla yerine getirilmesi süreci.',
    'Jüri': 'Bazı suçlarda karar verme sürecine katılan halk temsilcilerinden oluşan kurul.',
    'Karar': 'Mahkemenin yargılama sonunda verdiği hüküm. Kesinleştikten sonra bağlayıcı hale gelir.',
    'Lehtar': 'Bir hak veya yarardan faydalanan kişi. Genellikle sigorta ve miras hukukunda kullanılır.',
    'Mütecaviz': 'Saldırıda bulunan, haksız fiil işleyen kişi. Ceza hukukunda fail olarak adlandırılır.',
    'Nafaka': 'Eşler arası veya çocuklar için ödenen bakım ücreti. Aile hukukunun önemli konularından.',
    'Oy Birliği': 'Mahkeme heyetinin tüm üyelerinin aynı yönde karar vermesi durumu.',
    'Polis': 'Kamu düzenini sağlayan, suçları önleyen ve kovuşturmaya yardımcı olan kolluk kuvveti.',
    'Rüşvet': 'Kamu görevlisine görevini kötüye kullanması için verilen para veya menfaat.',
    'Savcı': 'Kamu adına dava açan, suçluları takip eden ve devleti temsil eden hukuk mezunu.',
    'Temyiz': 'Alt mahkeme kararlarına karşı üst mahkemeye başvurma yolu. İtiraz hakkı.',
    'Uzlaşma': 'Tarafların anlaşmazlığı mahkeme dışında çözme yöntemi. Alternatif uyuşmazlık çözümü.',
    'Vasi': 'Küçük veya kısıtlı kişilerin hukuki işlerini yürüten, mahkemece atanan kişi.',
    'Yargıtay': 'Türkiye\'de en yüksek adli yargı organı. Temyiz incelemesi yapar.',
    'Zimmət': 'Kamu görevlisinin görevi nedeniyle elinde bulunan devlet malını kendine mal etmesi suçu.',
  };

  List<MapEntry<String, String>> get _filteredTerms {
    if (_searchQuery.isEmpty) {
      return _legalTerms.entries.toList();
    }
    return _legalTerms.entries
        .where((entry) =>
            entry.key.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            entry.value.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Hukuki Terimler Sözlüğü',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Column(
        children: [
          // Arama kutusu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Hukuki terim ara...',
                  hintStyle: TextStyle(color: AppColors.grey),
                  prefixIcon: Icon(Icons.search, color: AppColors.primaryBlue),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          // Terimler listesi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredTerms.length,
              itemBuilder: (context, index) {
                final term = _filteredTerms[index];
                return _buildTermCard(term.key, term.value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermCard(String term, String definition) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  FontAwesomeIcons.balanceScale,
                  color: AppColors.primaryBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  term,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            definition,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
