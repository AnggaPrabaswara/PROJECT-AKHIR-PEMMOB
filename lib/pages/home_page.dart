import 'package:flutter/material.dart';
import '../models/wisata_model.dart';
import '../services/db_helper.dart';
import '../widgets/wisata_card.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<WisataModel> _wisataList = [];
  String _searchQuery = '';
  String _selectedKategori = 'Semua';
  bool _isLoading = true;

  final List<String> _kategoriList = const [
    'Semua', 'Alam', 'Budaya', 'Kuliner', 'Belanja', 'Sejarah', 'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    _loadWisata();
  }

  Future<void> _loadWisata() async {
    setState(() => _isLoading = true);
    try {
      final data = await DBHelper.instance.getAllWisata();
      if (mounted) {
        setState(() {
          _wisataList = data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data wisata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onKategoriSelected(String kategori) {
    setState(() {
      _selectedKategori = kategori;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _wisataList
        .where((w) =>
            w.nama.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            (_selectedKategori == 'Semua' || w.kategori == _selectedKategori))
        .toList();

    final Color primaryColor = Colors.blue.shade600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Melaly 🧭',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Pengaturan',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.travel_explore, color: primaryColor, size: 38),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Selamat datang!', style: TextStyle(color: Colors.white70, fontSize: 16)),
                            SizedBox(height: 4),
                            Text('Jelajahi Tempat Wisata Favoritmu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.transparent,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari tempat wisata...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: _onSearch,
                  ),
                ),
                Container(
                  height: 44,
                  alignment: Alignment.centerLeft,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _kategoriList.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final kategori = _kategoriList[idx];
                      final selected = kategori == _selectedKategori;
                      return ChoiceChip(
                        label: Text(kategori),
                        selected: selected,
                        onSelected: (_) => _onKategoriSelected(kategori),
                        selectedColor: primaryColor,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(color: selected ? Colors.white : primaryColor),
                        elevation: selected ? 4 : 0,
                        pressElevation: 2,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 12),
                              const Text(
                                'Belum ada data wisata ditemukan',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final wisata = filteredList[index];
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 350 + index * 30),
                              curve: Curves.easeIn,
                              margin: const EdgeInsets.only(bottom: 14),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: WisataCard(
                                  wisata: wisata,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/detail',
                                      arguments: wisata,
                                    ).then((_) => _loadWisata());
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        elevation: 6,
        onPressed: () => Navigator.pushNamed(context, '/add').then((_) => _loadWisata()),
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
