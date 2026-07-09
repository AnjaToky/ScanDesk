import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_desc/model/emprunter_model.dart';
import 'package:scan_desc/model/inventaire_model.dart';
import 'package:scan_desc/view/colors/couleur.dart';
import 'package:scan_desc/view/emprunt/emprunt_dialog.dart';
import 'package:scan_desc/view/widget/bottom_bar.dart';
import 'package:scan_desc/viewModel/emprunt_notifier.dart';
import 'package:scan_desc/viewModel/inventaire_notifier.dart';

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

    final id = data != null ? (data['id'] as num?)?.toInt() : null;
    final inventaires = ref.read(inventaireProvider).value ?? const [];
    Inventaire? inventaire;
    if (id != null) {
      for (final inv in inventaires) {
        if (inv.id == id) {
          inventaire = inv;
          break;
        }
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _ResultSheet(
        inventaire: inventaire,
        rawValue: rawValue,
        onRescan: () {
          Navigator.pop(context);
          _resumeScan();
        },
        onEmprunter: () {
          Navigator.pop(context);
          showEmpruntDialog(context, inventaire!);
          _resumeScan();
        },
        onChangerEtat: (etat) async {
          Navigator.pop(context);
          await ref
              .read(inventaireProvider.notifier)
              .editer(inventaire!.copyWith(etatInventaire: etat));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${inventaire.name} : état mis à jour')),
            );
          }
          _resumeScan();
        },
        onRetourner: () async {
          Navigator.pop(context);
          final emprunts = ref.read(empruntProvider).value ?? const [];
          Emprunter? actif;
          for (final e in emprunts) {
            if (e.idInventaire == inventaire!.id) {
              actif = e;
              break;
            }
          }
          if (actif != null) {
            await ref
                .read(empruntProvider.notifier)
                .supprimerEmprunt(actif.id!, inventaire!.id!);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${inventaire.name} : retourné')),
              );
            }
          }
          _resumeScan();
        },
        onSupprimer: () async {
          final confirme = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Supprimer'),
              content: Text('Supprimer "${inventaire!.name}" ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Couleur.erreur),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
          if (confirme == true) {
            if (mounted) Navigator.pop(context);
            await ref.read(inventaireProvider.notifier).supprimer(inventaire!.id!);
          }
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
  final Inventaire? inventaire;
  final String rawValue;
  final VoidCallback onRescan;
  final VoidCallback onEmprunter;
  final void Function(EtatInventaire) onChangerEtat;
  final VoidCallback onRetourner;
  final VoidCallback onSupprimer;

  const _ResultSheet({
    required this.inventaire,
    required this.rawValue,
    required this.onRescan,
    required this.onEmprunter,
    required this.onChangerEtat,
    required this.onRetourner,
    required this.onSupprimer,
  });

  String _etatLabel(EtatInventaire etat) {
    return switch (etat) {
      EtatInventaire.dispo       => 'Disponible',
      EtatInventaire.maintenance => 'Maintenance',
      EtatInventaire.perdu       => 'Perdu',
      EtatInventaire.emprunter   => 'Emprunté',
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
            child: inventaire != null
                ? _buildDataContent(inventaire!)
                : _buildRawContent(rawValue),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: inventaire != null ? _buildActions(inventaire!) : _buildRescanButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataContent(Inventaire inv) {
    final color = Couleur.couleurEtat(inv.etatInventaire);

    return Container(
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
                  inv.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Couleur.textPrimaire,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _etatLabel(inv.etatInventaire),
                  style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          if (inv.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              inv.description,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _InfoChip(label: 'ID', value: '${inv.id}'),
        ],
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Article introuvable dans la base locale.',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          SelectableText(raw, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRescanButton() {
    return SizedBox(
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildActions(Inventaire inv) {
    final etat = inv.etatInventaire;
    final secondaryButtons = <Widget>[];

    void addEtatButton(EtatInventaire cible, String label, IconData icon) {
      secondaryButtons.add(
        _ActionButton(
          label: label,
          icon: icon,
          color: Couleur.couleurEtat(cible),
          onTap: () => onChangerEtat(cible),
        ),
      );
    }

    if (etat == EtatInventaire.emprunter) {
      secondaryButtons.add(
        _ActionButton(
          label: 'Retourner',
          icon: Icons.assignment_return_outlined,
          color: Couleur.succes,
          onTap: onRetourner,
        ),
      );
    } else {
      if (etat != EtatInventaire.dispo) {
        addEtatButton(EtatInventaire.dispo, 'Disponible', Icons.check_circle_outline);
      }
      if (etat != EtatInventaire.maintenance) {
        addEtatButton(EtatInventaire.maintenance, 'Maintenance', Icons.build_outlined);
      }
      if (etat != EtatInventaire.perdu) {
        addEtatButton(EtatInventaire.perdu, 'Perdu', Icons.warning_amber_outlined);
      }
    }

    return Column(
      children: [
        if (etat == EtatInventaire.dispo) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onEmprunter,
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: const Text(
                'Emprunter',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Couleur.primaire,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: secondaryButtons,
        ),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: onSupprimer,
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
          label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: onRescan,
          child: const Text('Scanner a nouveau'),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
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
