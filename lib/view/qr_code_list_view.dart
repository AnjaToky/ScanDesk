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
  final Inventaire inventaire;
  final int quantite;

  const QrCodeListView({
    super.key,
    required this.inventaire,
    required this.quantite,
  });

  String _buildData(int unite) {
    return jsonEncode({
      'id': inventaire.id,
      'name': inventaire.name,
      'description': inventaire.description,
      'etat': inventaire.etatInventaire.name,
      'unite': unite,
      'total': quantite,
    });
  }

  Future<Uint8List> _qrToBytes(String data) async {
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: false,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
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
      final pages = (quantite / perPage).ceil();

      for (int page = 0; page < pages; page++) {
        final start = page * perPage;
        final end = (start + perPage).clamp(0, quantite);

        final List<pw.Widget> cards = [];
        for (int i = start; i < end; i++) {
          final bytes = await _qrToBytes(_buildData(i + 1));
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
                    '${inventaire.name}  —  Unité ${i + 1} / $quantite',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    inventaire.description,
                    style: const pw.TextStyle(
                      fontSize: 11,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Image(pw.MemoryImage(bytes), width: 180, height: 180),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'ID: ${inventaire.id}',
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
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'qrcodes_${inventaire.name}.pdf',
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
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Codes — ${inventaire.name}'),
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
        itemCount: quantite,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Unité ${index + 1} / $quantite',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  QrImageView(
                    data: _buildData(index + 1),
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    inventaire.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    inventaire.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'ID: ${inventaire.id}',
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
