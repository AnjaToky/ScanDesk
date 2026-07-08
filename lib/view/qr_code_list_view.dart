import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scan_desc/model/inventaire_model.dart';

class QrCodeListView extends StatelessWidget {
  final List<Inventaire> inventaires;

  const QrCodeListView({super.key, required this.inventaires});

  String _buildData(Inventaire inv) {
    return jsonEncode({
      'id': inv.id,
      'name': inv.name,
      'description': inv.description,
      'etat': inv.etatInventaire.name,
    });
  }

  Future<Uint8List> _qrToBytes(String data) async {
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: false,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF000000),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF000000),
      ),
    );
    final imageData = await painter.toImageData(
      300,
      format: ui.ImageByteFormat.png,
    );
    return imageData!.buffer.asUint8List();
  }

  Future<void> _exportPdf(BuildContext context) async {
    try {
      final doc = pw.Document();
      const perPage = 2;
      final total = inventaires.length;
      final pages = (total / perPage).ceil();

      for (int page = 0; page < pages; page++) {
        final start = page * perPage;
        final end = (start + perPage).clamp(0, total);

        final List<pw.Widget> cards = [];
        for (int i = start; i < end; i++) {
          final inv = inventaires[i];
          final bytes = await _qrToBytes(_buildData(inv));
          cards.add(
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 24),
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    '${inv.name}  (${i + 1} / $total)',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    inv.description,
                    style: const pw.TextStyle(
                      fontSize: 11,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Image(pw.MemoryImage(bytes), width: 180, height: 180),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'ID: ${inv.id}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build: (pw.Context ctx) => pw.Column(children: cards),
          ),
        );
      }

      final bytes = await doc.save();
      final baseName = inventaires.isNotEmpty
          ? inventaires.first.name.replaceAll(RegExp(r'\s+\d+$'), '')
          : 'qrcodes';
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'qrcodes_$baseName.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur export PDF : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = inventaires.length;
    final baseName = total > 0
        ? inventaires.first.name.replaceAll(RegExp(r'\s+\d+$'), '')
        : 'QR Codes';

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Codes — $baseName ($total)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exporter en PDF',
            onPressed: () => _exportPdf(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: total,
        itemBuilder: (context, index) {
          final inv = inventaires[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${index + 1} / $total',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  QrImageView(
                    data: _buildData(inv),
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    inv.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  Text(
                    inv.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'ID: ${inv.id}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _exportPdf(context),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Exporter PDF'),
      ),
    );
  }
}
