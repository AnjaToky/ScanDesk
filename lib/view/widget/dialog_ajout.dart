import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/model/inventaire_model.dart';
import 'package:scan_desc/view/colors/couleur.dart';
import 'package:scan_desc/view/qr_code_list_view.dart';
import 'package:scan_desc/viewModel/inventaire_notifier.dart';

class DialogAjout {
  static void showAjouterDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AjoutSheet(ref: ref, parentContext: context),
    );
  }
}

class _AjoutSheet extends StatefulWidget {
  final WidgetRef ref;
  final BuildContext parentContext;
  const _AjoutSheet({required this.ref, required this.parentContext});

  @override
  State<_AjoutSheet> createState() => _AjoutSheetState();
}

class _AjoutSheetState extends State<_AjoutSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  EtatInventaire _etat = EtatInventaire.dispo;
  int _quantite = 1;
  bool _loading = false;

  final _etatOptions = [
    (value: EtatInventaire.dispo,       label: 'Disponible',  color: Couleur.succes),
    (value: EtatInventaire.maintenance, label: 'Maintenance', color: Couleur.alerte),
    (value: EtatInventaire.perdu,       label: 'Perdu',       color: Couleur.erreur),
    (value: EtatInventaire.emprunter,   label: 'Emprunté',    color: Color(0xFF6366F1)),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) return;

    setState(() => _loading = true);

    final name = _nameCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final etat = _etat;
    final quantite = _quantite;

    Navigator.pop(context);

    // Insere quantite inventaires separes : "dell 1", "dell 2", ..., "dell 10"
    final List<Inventaire> inventaires = [];
    for (int i = 1; i <= quantite; i++) {
      final itemName = quantite == 1 ? name : '$name $i';
      final id = await widget.ref
          .read(inventaireProvider.notifier)
          .ajouter(Inventaire(name: itemName, description: desc, etatInventaire: etat));
      inventaires.add(Inventaire(
        id: id,
        name: itemName,
        description: desc,
        etatInventaire: etat,
      ));
    }

    if (widget.parentContext.mounted) {
      Navigator.push(
        widget.parentContext,
        MaterialPageRoute(
          builder: (_) => QrCodeListView(inventaires: inventaires),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottom),
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

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Couleur.primaire.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_box_outlined,
                    color: Couleur.primaire,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nouveau matériel',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Couleur.textPrimaire,
                      ),
                    ),
                    Text(
                      'Remplissez les informations',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom
                _InputField(
                  controller: _nameCtrl,
                  label: 'Nom du matériel',
                  icon: Icons.inventory_2_outlined,
                ),
                const SizedBox(height: 12),

                // Description
                _InputField(
                  controller: _descCtrl,
                  label: 'Salle / Description',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 20),

                // Etat
                const Text(
                  'État',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _etatOptions.map((opt) {
                    final isSelected = _etat == opt.value;
                    return GestureDetector(
                      onTap: () => setState(() => _etat = opt.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? opt.color
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? opt.color : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          opt.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Nombre de QR codes
                const Text(
                  'Nombre de QR codes',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QrButton(
                        icon: Icons.remove,
                        onPressed: _quantite > 1
                            ? () => setState(() => _quantite--)
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '$_quantite',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Couleur.textPrimaire,
                          ),
                        ),
                      ),
                      _QrButton(
                        icon: Icons.add,
                        onPressed: () => setState(() => _quantite++),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton Ajouter
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Couleur.primaire,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Ajouter et générer QR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFFADB5BD)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Couleur.primaire, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _QrButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QrButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: onPressed != null
              ? Couleur.primaire.withValues(alpha: 0.1)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onPressed != null ? Couleur.primaire : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}
