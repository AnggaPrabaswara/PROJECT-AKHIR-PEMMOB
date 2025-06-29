import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/wisata_model.dart';
import 'dart:io';

class WisataCard extends StatelessWidget {
  final WisataModel wisata;
  final VoidCallback? onTap;

  const WisataCard({required this.wisata, this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[100],
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: wisata.gambarPath.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: kIsWeb
                    ? Image.network(
                        wisata.gambarPath,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(wisata.gambarPath),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
              )
            : Icon(Icons.image, size: 48, color: Colors.blue[300]),
        title: Text(wisata.nama, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(wisata.lokasi),
        trailing: Icon(Icons.chevron_right, color: Colors.blue[700]),
      ),
    );
  }
} 