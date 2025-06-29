import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../models/wisata_model.dart';
import '../services/db_helper.dart';
import 'add_wisata_page.dart';
import 'dart:io';

class DetailWisataPage extends StatelessWidget {
  final WisataModel args;
  const DetailWisataPage({Key? key, required this.args}) : super(key: key);

  void _openMaps(BuildContext context) async {
    if (args.lat != null && args.lng != null) {
      final geoUri = Uri.parse('geo:${args.lat},${args.lng}?q=${args.lat},${args.lng}');
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        return;
      }
      final url = 'https://www.google.com/maps/search/?api=1&query=${args.lat},${args.lng}';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tidak bisa membuka Maps')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Koordinat tidak tersedia')));
    }
  }

  void _deleteWisata(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus data wisata ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DBHelper.instance.deleteWisata(args.id!);
      Navigator.popUntil(context, ModalRoute.withName('/home'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue.shade600;
    final Color secondaryColor = Colors.blue.shade400;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: primaryColor,
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    child: args.gambarPath.isNotEmpty
                        ? kIsWeb
                            ? Image.network(args.gambarPath, fit: BoxFit.cover)
                            : Image.file(File(args.gambarPath), fit: BoxFit.cover)
                        : Container(color: Colors.blue[100]),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 32,
                    child: Text(
                      args.nama,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 44,
                    child: Row(
                      children: [
                        Tooltip(
                          message: 'Edit',
                          child: Material(
                            color: Colors.transparent,
                            elevation: 4,
                            shape: const CircleBorder(),
                            child: FloatingActionButton(
                              heroTag: 'edit',
                              mini: true,
                              backgroundColor: Colors.white,
                              foregroundColor: primaryColor,
                              elevation: 0,
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (c) => AddWisataPage(wisata: args)),
                                );
                                if (result == true) Navigator.pop(context, true);
                              },
                              child: const Icon(Icons.edit),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Tooltip(
                          message: 'Hapus',
                          child: Material(
                            color: Colors.transparent,
                            elevation: 4,
                            shape: const CircleBorder(),
                            child: FloatingActionButton(
                              heroTag: 'delete',
                              mini: true,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                              elevation: 0,
                              onPressed: () => _deleteWisata(context),
                              child: const Icon(Icons.delete),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
              child: Card(
                elevation: 2,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: primaryColor, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(args.lokasi, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(height: 24, thickness: 0.7),
                      Row(
                        children: [
                          Icon(Icons.category, color: secondaryColor, size: 22),
                          const SizedBox(width: 8),
                          Text('Kategori: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(args.kategori),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.monetization_on, color: Colors.amber, size: 22),
                          const SizedBox(width: 8),
                          Text('Dana: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('Rp${args.dana}'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.date_range, color: Colors.green, size: 22),
                          const SizedBox(width: 8),
                          Text('Tanggal Kunjungan: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(args.tanggalKunjungan),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.w600, color: primaryColor)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(args.deskripsi, style: const TextStyle(fontSize: 15)),
                      ),
                      const SizedBox(height: 18),
                      if (args.lat != null && args.lng != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.map, color: primaryColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Koordinat: ${args.lat != null ? args.lat!.toStringAsFixed(5) : '-'}, ${args.lng != null ? args.lng!.toStringAsFixed(5) : '-'}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _openMaps(context),
                                icon: const Icon(Icons.map_outlined),
                                label: const Text('Lihat di Maps'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 