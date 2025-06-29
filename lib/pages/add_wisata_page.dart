// File: add_wisata_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../models/wisata_model.dart';
import '../services/db_helper.dart';

class AddWisataPage extends StatefulWidget {
  final WisataModel? wisata;
  const AddWisataPage({Key? key, this.wisata}) : super(key: key);

  @override
  State<AddWisataPage> createState() => _AddWisataPageState();
}

class _AddWisataPageState extends State<AddWisataPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _danaController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  String? _kategori;
  File? _imageFile;
  final List<String> _kategoriList = [
    'Alam', 'Budaya', 'Kuliner', 'Belanja', 'Sejarah', 'Lainnya'
  ];
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.wisata != null) {
      final w = widget.wisata!;
      _namaController.text = w.nama;
      _lokasiController.text = w.lokasi;
      _deskripsiController.text = w.deskripsi;
      _danaController.text = w.dana.toString();
      _tanggalController.text = w.tanggalKunjungan;
      _kategori = w.kategori;
      _latController.text = w.lat?.toString() ?? '';
      _lngController.text = w.lng?.toString() ?? '';
      if (w.gambarPath.isNotEmpty) _imageFile = File(w.gambarPath);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Ambil dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isGettingLocation = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Izin lokasi ditolak')),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _isGettingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izin lokasi ditolak permanen. Buka pengaturan untuk mengaktifkan.')),
        );
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true,
      );
      setState(() {
        _latController.text = position.latitude.toString();
        _lngController.text = position.longitude.toString();
        _isGettingLocation = false;
      });
    } catch (e) {
      setState(() => _isGettingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil lokasi: $e')),
      );
    }
  }

  Future<void> openInGoogleMaps() async {
    final lat = _latController.text;
    final lng = _lngController.text;

    if (lat.isEmpty || lng.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Koordinat belum tersedia')),
      );
      return;
    }

    final latVal = double.tryParse(lat);
    final lngVal = double.tryParse(lng);
    if (latVal == null || lngVal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Format koordinat tidak valid')),
      );
      return;
    }

    // Coba intent geo: (khusus Android)
    final geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    if (await canLaunchUrl(geoUrl)) {
      await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback ke browser
    final browserUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(browserUrl)) {
      await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tidak bisa membuka Google Maps')),
    );
  }

  void _saveWisata() async {
    if (!_formKey.currentState!.validate() || _kategori == null || _imageFile == null) return;
    final wisata = WisataModel(
      id: widget.wisata?.id,
      nama: _namaController.text,
      lokasi: _lokasiController.text,
      deskripsi: _deskripsiController.text,
      kategori: _kategori!,
      gambarPath: _imageFile!.path,
      dana: int.tryParse(_danaController.text) ?? 0,
      tanggalKunjungan: _tanggalController.text,
      lat: _latController.text.isNotEmpty ? double.tryParse(_latController.text) : null,
      lng: _lngController.text.isNotEmpty ? double.tryParse(_lngController.text) : null,
    );
    if (widget.wisata == null) {
      await DBHelper.instance.insertWisata(wisata);
    } else {
      await DBHelper.instance.updateWisata(wisata);
    }
    Navigator.pop(context, true);
  } 

  Future<void> _pickDate() async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: DateTime(now.year - 2),
    lastDate: DateTime(now.year + 5),
  );
  if (picked != null) {
    setState(() {
      _tanggalController.text = picked.toIso8601String().split('T').first;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue.shade600;
    final Color secondaryColor = Colors.blue.shade400;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.wisata == null ? 'Tambah Wisata' : 'Edit Wisata'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Area input gambar yang lebih modern
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: kIsWeb
                              ? Image.network(_imageFile!.path, height: 180, fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => _buildImagePlaceholder(primaryColor))
                              : Image.file(_imageFile!, height: 180, fit: BoxFit.cover),
                        )
                      : _buildImagePlaceholder(primaryColor),
                ),
              ),
              _buildSectionTitle('Informasi Utama'),
              _buildFormCard(
                children: [
                  TextFormField(
                    controller: _namaController,
                    decoration: _buildInputDecoration(label: 'Nama Tempat Wisata', icon: Icons.place_outlined),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lokasiController,
                    decoration: _buildInputDecoration(label: 'Lokasi/Alamat', icon: Icons.location_on_outlined),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _deskripsiController,
                    decoration: _buildInputDecoration(label: 'Deskripsi', icon: Icons.description_outlined),
                    maxLines: 2,
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              _buildSectionTitle('Detail Tambahan'),
              _buildFormCard(
                children: [
                  DropdownButtonFormField<String>(
                    value: _kategori,
                    items: _kategoriList.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                    onChanged: (v) => setState(() => _kategori = v),
                    decoration: _buildInputDecoration(label: 'Kategori', icon: Icons.category_outlined),
                    validator: (v) => v == null ? 'Pilih kategori' : null,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _danaController,
                    decoration: _buildInputDecoration(label: 'Dana (Rp)', icon: Icons.monetization_on_outlined),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tanggalController,
                    decoration: _buildInputDecoration(label: 'Tanggal Kunjungan', icon: Icons.date_range_outlined),
                    readOnly: true,
                    onTap: _pickDate,
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              _buildSectionTitle('Koordinat Lokasi (Opsional)'),
              _buildFormCard(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latController,
                          decoration: _buildInputDecoration(label: 'Latitude', icon: Icons.my_location_outlined),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _lngController,
                          decoration: _buildInputDecoration(label: 'Longitude', icon: Icons.my_location_outlined),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isGettingLocation ? null : getCurrentLocation,
                          icon: const Icon(Icons.my_location, size: 18),
                          label: const Text('Ambil Lokasi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: openInGoogleMaps,
                          icon: const Icon(Icons.map, size: 18),
                          label: const Text('Lihat di Maps'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _saveWisata,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: Text(widget.wisata == null ? 'Simpan' : 'Update'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(Color primaryColor) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 48, color: primaryColor),
            const SizedBox(height: 8),
            const Text(
              'Tap untuk menambah foto',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildFormCard({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: children),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label, required IconData icon}) {
    final primaryColor = Colors.blue.shade600;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.grey, width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }
}
