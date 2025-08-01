import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  bool _isSearching = false;

  // Örnek arama sonuçları
  final List<String> _allLegalTopics = [
    'Boşanma Davası',
    'Miras Hukuku',
    'İş Hukuku',
    'Ceza Hukuku',
    'Ticaret Hukuku',
    'Gayrimenkul Hukuku',
    'Aile Hukuku',
    'İcra ve İflas Hukuku',
    'Vergi Hukuku',
    'İdare Hukuku',
    'Anayasa Hukuku',
    'Borçlar Hukuku',
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
              .where((topic) => topic.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
        _isSearching = false;
      });
    });
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
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.gavel, color: AppColors.primaryBlue),
                              title: Text(_searchResults[index]),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                // Burada seçilen konuyla ilgili detay sayfasına gidilebilir
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${_searchResults[index]} seçildi'),
                                  ),
                                );
                              },
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
