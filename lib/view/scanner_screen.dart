import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_desc/view/colors/couleur.dart';
import 'package:scan_desc/view/widget/bottom_bar.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with TickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();
  bool _detected = false;
  bool _torchOn = false;

  late final AnimationController _scanAnim;
  late final Animation<double> _scanLine;

  static const double _frameSize = 260;

  @override
  void initState() {
    super.initState();
    _scanAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLine = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanAnim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scanAnim.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_detected) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    _detected = true;
    _controller.stop();
    _scanAnim.stop();

    _showResultSheet(barcode.rawValue!);
  }

  void _resumeScan() {
    setState(() => _detected = false);
    _controller.start();
    _scanAnim.repeat(reverse: true);
  }

  void _showResultSheet(String rawValue) {
    Map<String, dynamic>? data;
    try {
      data = jsonDecode(rawValue);
    } catch (_) {
      data = null;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _ResultSheet(
        data: data,
        rawValue: rawValue,
        onRescan: () {
          Navigator.pop(context);
          _resumeScan();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Scanner',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          _ControlButton(
            icon: _torchOn ? Icons.flash_on : Icons.flash_off,
            onTap: () {
              _controller.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
            active: _torchOn,
          ),
          const SizedBox(width: 4),
          _ControlButton(
            icon: Icons.flip_camera_ios_outlined,
            onTap: () => _controller.switchCamera(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Caméra plein écran
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // Overlay sombre avec trou au centre
          CustomPaint(
            size: Size(size.width, size.height),
            painter: _ScanOverlayPainter(frameSize: _frameSize),
          ),

          // Coins du cadre + ligne animée
          Center(
            child: SizedBox(
              width: _frameSize,
              height: _frameSize,
              child: Stack(
                children: [
                  // 4 coins
                  ..._buildCorners(),

                  // Ligne de scan
                  AnimatedBuilder(
                    animation: _scanLine,
                    builder: (_, __) => Positioned(
                      top: _scanLine.value * (_frameSize - 2),
                      left: 12,
                      right: 12,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Couleur.primaire,
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Label bas
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pointez vers un QR code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar.buildBottom(context, ref),
    );
  }

  List<Widget> _buildCorners() {
    const len = 28.0;
    const thick = 3.5;
    const r = 6.0;
    final color = Couleur.primaire;

    Widget corner({bool top = true, bool left = true}) {
      return Positioned(
        top: top ? 0 : null,
        bottom: top ? null : 0,
        left: left ? 0 : null,
        right: left ? null : 0,
        child: SizedBox(
          width: len,
          height: len,
          child: CustomPaint(
            painter: _CornerPainter(
              color: color,
              thickness: thick,
              radius: r,
              top: top,
              left: left,
            ),
          ),
        ),
      );
    }

    return [
      corner(top: true,  left: true),
      corner(top: true,  left: false),
      corner(top: false, left: true),
      corner(top: false, left: false),
    ];
  }
}

// Overlay sombre avec trou transparent
class _ScanOverlayPainter extends CustomPainter {
  final double frameSize;
  const _ScanOverlayPainter({required this.frameSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final half = frameSize / 2;
    const r = 12.0;

    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(cx - half, cy - half, cx + half, cy + half),
          const Radius.circular(r),
        ),
      );

    canvas.drawPath(
      Path.combine(PathOperation.difference, full, hole),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// Coin en L
class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final double radius;
  final bool top;
  final bool left;

  const _CornerPainter({
    required this.color,
    required this.thickness,
    required this.radius,
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    final path = Path();

    if (top && left) {
      path.moveTo(0, h);
      path.lineTo(0, radius);
      path.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius));
      path.lineTo(w, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(w - radius, 0);
      path.arcToPoint(Offset(w, radius), radius: Radius.circular(radius));
      path.lineTo(w, h);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, h - radius);
      path.arcToPoint(Offset(radius, h), radius: Radius.circular(radius));
      path.lineTo(w, h);
    } else {
      path.moveTo(0, h);
      path.lineTo(w - radius, h);
      path.arcToPoint(Offset(w, h - radius), radius: Radius.circular(radius));
      path.lineTo(w, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// Bouton de contrôle (torche / flip)
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active
              ? Couleur.primaire.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// Bottom sheet résultat
class _ResultSheet extends StatelessWidget {
  final Map<String, dynamic>? data;
  final String rawValue;
  final VoidCallback onRescan;

  const _ResultSheet({
    required this.data,
    required this.rawValue,
    required this.onRescan,
  });

  Color _etatColor(String? etat) {
    return switch (etat) {
      'dispo'        => Couleur.succes,
      'maintenance'  => Couleur.alerte,
      'perdu'        => Couleur.erreur,
      'emprunter'    => const Color(0xFF6366F1),
      _              => Colors.grey,
    };
  }

  String _etatLabel(String? etat) {
    return switch (etat) {
      'dispo'        => 'Disponible',
      'maintenance'  => 'Maintenance',
      'perdu'        => 'Perdu',
      'emprunter'    => 'Emprunté',
      _              => etat ?? '-',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header succès
          Container(
            margin: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Couleur.succes.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Couleur.succes.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Couleur.succes,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QR Code lu avec succes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Couleur.textPrimaire,
                      ),
                    ),
                    Text(
                      'Informations du materiel',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Contenu
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: data != null
                ? _buildDataContent(data!)
                : _buildRawContent(rawValue),
          ),

          // Bouton
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRescan,
                icon: const Icon(Icons.qr_code_scanner, size: 18),
                label: const Text(
                  'Scanner a nouveau',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Couleur.primaire,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataContent(Map<String, dynamic> d) {
    final etat = d['etat'] as String?;
    final color = _etatColor(etat);

    return Column(
      children: [
        // Carte principale
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${d['name'] ?? '-'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Couleur.textPrimaire,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _etatLabel(etat),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if ((d['description'] as String?)?.isNotEmpty == true) ...[
                const SizedBox(height: 6),
                Text(
                  '${d['description']}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
              const Divider(height: 20, color: Color(0xFFF1F5F9)),
              Row(
                children: [
                  _InfoChip(label: 'ID', value: '${d['id'] ?? '-'}'),
                  const SizedBox(width: 10),
                  if (d['total'] != null && (d['total'] as int) > 1)
                    _InfoChip(
                      label: 'Unite',
                      value: '${d['unite']} / ${d['total']}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRawContent(String raw) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SelectableText(raw, style: const TextStyle(fontSize: 13)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label : ',
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Couleur.textPrimaire,
            ),
          ),
        ],
      ),
    );
  }
}
