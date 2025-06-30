import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import 'package:provider/provider.dart';
import '../utils/theme_notifier.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _namaController = TextEditingController();
  String? _kategori;
  bool _isDark = false;
  final List<String> _kategoriList = [
    'Alam', 'Budaya', 'Kuliner', 'Belanja', 'Sejarah', 'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _namaController.text = await PrefsService.instance.getUsername();
    String fav = await PrefsService.instance.getFavoriteCategory();
    _kategori = _kategoriList.contains(fav) ? fav : null;
    _isDark = await PrefsService.instance.isDarkMode();
    setState(() {});
  }

  void _savePrefs() async {
    await PrefsService.instance.setUsername(_namaController.text);
    await PrefsService.instance.setFavoriteCategory(_kategori ?? '');
    await PrefsService.instance.setThemeMode(_isDark);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pengaturan disimpan')));
  }

  void _logout() async {
    await PrefsService.instance.setLogin(false);
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue.shade600;
    final Color secondaryColor = Colors.blue.shade400;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan avatar dan sapaan
            Container(
              width: double.infinity,
              child: Stack(
                children: [
                  // Watermark gear besar transparan
                  Align(
                    alignment: Alignment.centerRight,
                    child: Opacity(
                      opacity: 0.10,
                      child: Icon(Icons.settings, size: 120, color: Colors.white),
                    ),
                  ),
                  // Header content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Halo,', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(
                          _namaController.text.isNotEmpty ? _namaController.text : 'Pengguna',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        const Text('Atur preferensi aplikasi Anda', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  // Icon gear kecil di pojok kanan atas
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.settings, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _namaController,
                        decoration: InputDecoration(
                          labelText: 'Nama Pengguna',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _kategoriList.contains(_kategori) ? _kategori : null,
                        items: _kategoriList.map((k) => DropdownMenuItem(
                          value: k,
                          child: Row(
                            children: [
                              Icon(_iconForKategori(k), color: primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Text(k, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                            ],
                          ),
                        )).toList(),
                        onChanged: (v) => setState(() => _kategori = v),
                        decoration: InputDecoration(
                          labelText: 'Kategori Favorit',
                          prefixIcon: Icon(Icons.category_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(height: 32, thickness: 0.7),
                      SwitchListTile(
                        value: _isDark,
                        onChanged: (v) {
                          setState(() => _isDark = v);
                          Provider.of<ThemeNotifier>(context, listen: false).setDark(v);
                        },
                        title: const Text('Mode Gelap'),
                        activeColor: primaryColor,
                        contentPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _savePrefs,
                          icon: const Icon(Icons.save_alt),
                          label: const Text('Simpan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForKategori(String kategori) {
    switch (kategori) {
      case 'Alam':
        return Icons.park;
      case 'Budaya':
        return Icons.museum;
      case 'Kuliner':
        return Icons.restaurant;
      case 'Belanja':
        return Icons.shopping_bag;
      case 'Sejarah':
        return Icons.account_balance;
      default:
        return Icons.category;
    }
  }
} 