import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LegalTopic> _searchResults = [];
  bool _isSearching = false;

  // Hukuki konular ve açıklamaları
  final List<LegalTopic> _allLegalTopics = [
    LegalTopic(
      title: 'Boşanma Davası',
      description:
          'Evlilik birliğinin sona erdirilmesi ile ilgili hukuki süreçler. Nafaka, velayet, mal paylaşımı gibi konuları kapsar.',
      details: [
        'Anlaşmalı boşanma ve çekişmeli boşanma türleri',
        'Nafaka hesaplama ve ödeme koşulları',
        'Çocuk velayeti ve görüşme hakları',
        'Mal paylaşımı ve evlilik birliği malları',
        'Boşanma sonrası haklar ve yükümlülükler',
      ],
    ),
    LegalTopic(
      title: 'Miras Hukuku',
      description:
          'Kişinin ölümü sonrası malvarlığının kimlere, ne şekilde geçeceğini düzenleyen hukuk dalı.',
      details: [
        'Yasal mirasçılar ve miras payları',
        'Vasiyetname türleri ve geçerlilik koşulları',
        'Miras bırakanın borçları ve sorumlulukları',
        'Mirasçılık belgesi alma süreci',
        'Miras davaları ve itiraz hakları',
      ],
    ),
    LegalTopic(
      title: 'İş Hukuku',
      description:
          'İşçi ve işveren arasındaki ilişkileri düzenleyen, çalışma koşullarını belirleyen hukuk dalı.',
      details: [
        'İş sözleşmesi türleri ve geçerlilik koşulları',
        'Çalışma süreleri ve fazla mesai hakları',
        'İş güvencesi ve işe iade davaları',
        'İş kazası ve meslek hastalığı tazminatları',
        'Toplu iş hukuku ve sendika hakları',
      ],
    ),
    LegalTopic(
      title: 'Ceza Hukuku',
      description:
          'Suç teşkil eden fiilleri ve bunlara uygulanacak cezaları düzenleyen hukuk dalı.',
      details: [
        'Suç türleri ve ceza miktarları',
        'Suçun unsurları ve sorumluluk koşulları',
        'Ceza davası süreci ve haklar',
        'İnfaz hukuku ve cezaevi koşulları',
        'Güvenlik tedbirleri ve denetimli serbestlik',
      ],
    ),
    LegalTopic(
      title: 'Ticaret Hukuku',
      description:
          'Ticari işlemleri, şirketleri ve ticari hayatı düzenleyen hukuk dalı.',
      details: [
        'Şirket türleri ve kuruluş süreçleri',
        'Ticari sözleşmeler ve ticari işlemler',
        'Şirket yönetimi ve ortaklık hakları',
        'Ticari defterler ve muhasebe yükümlülükleri',
        'Şirket birleşme ve devralma işlemleri',
      ],
    ),
    LegalTopic(
      title: 'Gayrimenkul Hukuku',
      description:
          'Emlak, arsa, konut gibi gayrimenkul varlıklarla ilgili hukuki düzenlemeler.',
      details: [
        'Emlak alım-satım sözleşmeleri',
        'Kat mülkiyeti ve kat karşılığı inşaat',
        'Kira hukuku ve kiracı hakları',
        'İmar hukuku ve yapı ruhsatları',
        'Emlak vergileri ve değer artış kazancı',
      ],
    ),
    LegalTopic(
      title: 'Aile Hukuku',
      description:
          'Aile ilişkilerini, evlilik, boşanma, nafaka gibi konuları düzenleyen hukuk dalı.',
      details: [
        'Evlenme koşulları ve evlilik sözleşmesi',
        'Aile içi şiddet ve koruma kararları',
        'Soybağı ve evlat edinme süreçleri',
        'Aile malları ortaklığı',
        'Aile mahkemesi süreçleri',
      ],
    ),
    LegalTopic(
      title: 'İcra ve İflas Hukuku',
      description:
          'Alacakların tahsili ve borçlunun malvarlığının tasfiyesi ile ilgili hukuki süreçler.',
      details: [
        'İcra takibi türleri ve süreçleri',
        'İhtiyati haciz ve önleyici tedbirler',
        'İflas davası ve konkordato süreçleri',
        'İcra müdürlüğü işlemleri',
        'İcra ve iflas davalarında itiraz hakları',
      ],
    ),
    LegalTopic(
      title: 'Vergi Hukuku',
      description:
          'Vergi yükümlülükleri, vergi türleri ve vergi uyuşmazlıklarını düzenleyen hukuk dalı.',
      details: [
        'Gelir vergisi ve kurumlar vergisi',
        'KDV ve diğer dolaylı vergiler',
        'Vergi beyannamesi ve ödeme süreleri',
        'Vergi uyuşmazlıkları ve dava süreçleri',
        'Vergi cezaları ve gecikme faizi',
      ],
    ),
    LegalTopic(
      title: 'İdare Hukuku',
      description:
          'Kamu yönetimi, idari işlemler ve kamu hizmetleri ile ilgili hukuki düzenlemeler.',
      details: [
        'İdari işlemler ve idari sözleşmeler',
        'Kamu görevlileri ve memur hukuku',
        'İdari yargı ve iptal davaları',
        'Kamu hizmetleri ve özelleştirme',
        'İdari yaptırımlar ve idari cezalar',
      ],
    ),
    LegalTopic(
      title: 'Anayasa Hukuku',
      description:
          'Devletin temel yapısını, temel hak ve özgürlükleri düzenleyen hukuk dalı.',
      details: [
        'Temel hak ve özgürlükler',
        'Anayasa Mahkemesi ve iptal davaları',
        'Seçim hukuku ve siyasi haklar',
        'Yasama, yürütme ve yargı organları',
        'Anayasa değişikliği süreçleri',
      ],
    ),
    LegalTopic(
      title: 'Borçlar Hukuku',
      description:
          'Kişiler arası borç ilişkilerini, sözleşmeleri ve haksız fiilleri düzenleyen hukuk dalı.',
      details: [
        'Sözleşme türleri ve geçerlilik koşulları',
        'Haksız fiil ve tazminat davaları',
        'Borçların ifası ve temerrüt',
        'Alacak hakkı ve alacaklı koruma tedbirleri',
        'Zamanaşımı ve hak düşürücü süreler',
      ],
    ),
  ];

  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
    });

    // Arama simülasyonu
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        if (query.isEmpty) {
          _searchResults = [];
        } else {
          _searchResults = _allLegalTopics
              .where(
                (topic) =>
                    topic.title.toLowerCase().contains(query.toLowerCase()) ||
                    topic.description.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
        }
        _isSearching = false;
      });
    });
  }

  void _showTopicDetails(LegalTopic topic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          topic.title,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                topic.description,
                style: const TextStyle(fontSize: 16, color: AppColors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'Önemli Konular:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              ...topic.details
                  .map(
                    (detail) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(color: AppColors.primaryYellow),
                          ),
                          Expanded(
                            child: Text(
                              detail,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Kapat',
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Burada AI chat'e yönlendirme yapılabilir
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${topic.title} hakkında AI danışmanına yönlendiriliyorsunuz...',
                  ),
                  backgroundColor: AppColors.primaryBlue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.primaryBlue,
            ),
            child: const Text('AI Danışman'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hukuki Arama'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.primaryYellow),
      ),
      body: Column(
        children: [
          // Arama kutusı
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Hukuki konu ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: AppColors.surfaceBackground,
              ),
              onChanged: _performSearch,
            ),
          ),

          // Arama sonuçları
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: AppColors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Hukuki konularda arama yapın'
                              : 'Sonuç bulunamadı',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final topic = _searchResults[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.gavel,
                            color: AppColors.primaryBlue,
                          ),
                          title: Text(
                            topic.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          subtitle: Text(
                            topic.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _showTopicDetails(topic),
                        ),
                      );
                    },
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

// Hukuki konu modeli
class LegalTopic {
  final String title;
  final String description;
  final List<String> details;

  LegalTopic({
    required this.title,
    required this.description,
    required this.details,
  });
}
