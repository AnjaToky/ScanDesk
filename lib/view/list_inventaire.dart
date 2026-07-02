import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/model/inventaire_model.dart';
import 'package:scan_desc/view/dash_board.dart';
import 'package:scan_desc/viewModel/inventaire_notifier.dart';

const _blue = Color(0xFF2D62ED);
const _green = Color(0xFF4CAF50);
const _orange = Color(0xFFFFA726);
const _red = Color(0xFFEF5350);

class ListInventaire extends ConsumerStatefulWidget {
  const ListInventaire({super.key});

  @override
  ConsumerState<ListInventaire> createState() => _ListInventaireState();
}

class _ListInventaireState extends ConsumerState<ListInventaire> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  EtatInventaire? _filtreEtat;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _couleurEtat(EtatInventaire etat) {
    return switch (etat) {
      EtatInventaire.dispo => _green,
      EtatInventaire.maintenance => _orange,
      EtatInventaire.perdu => _red,
    };
  }

  List<Inventaire> _filtrer(List<Inventaire> items) {
    return items.where((item) {
      final matchSearch =
          _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchEtat =
          _filtreEtat == null || item.etatInventaire == _filtreEtat;
      return matchSearch && matchEtat;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final asyncInventaire = ref.watch(inventaireProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: _blue,
        title: const Text(
          'ScanDesk',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 0,
      ),
      body: asyncInventaire.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (items) {
          final filtered = _filtrer(items);
          return Column(
            children: [
              _buildFiltres(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nombre de matériel  ${filtered.length}/${items.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const Divider(
                color: _green,
                thickness: 1.5,
                indent: 16,
                endIndent: 16,
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('Aucun matériel trouvé'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _ItemCard(
                            item: item,
                            couleur: _couleurEtat(item.etatInventaire),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAjouterDialog(context),
        backgroundColor: _blue,
        label: const Text(
          'Ajouter',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: _BottomNav(currentIndex: 2),
    );
  }

  Widget _buildFiltres() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Recherche',
              filled: true,
              fillColor: Colors.grey[300],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _FiltreEtatChip(
                label: 'Dispo',
                color: _green,
                selected: _filtreEtat == EtatInventaire.dispo,
                onTap: () => setState(() {
                  _filtreEtat = _filtreEtat == EtatInventaire.dispo
                      ? null
                      : EtatInventaire.dispo;
                }),
              ),
              const SizedBox(width: 8),
              _FiltreEtatChip(
                label: 'Maintenance',
                color: _orange,
                selected: _filtreEtat == EtatInventaire.maintenance,
                onTap: () => setState(() {
                  _filtreEtat = _filtreEtat == EtatInventaire.maintenance
                      ? null
                      : EtatInventaire.maintenance;
                }),
              ),
              const SizedBox(width: 8),
              _FiltreEtatChip(
                label: 'Perdu',
                color: _red,
                selected: _filtreEtat == EtatInventaire.perdu,
                onTap: () => setState(() {
                  _filtreEtat = _filtreEtat == EtatInventaire.perdu
                      ? null
                      : EtatInventaire.perdu;
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAjouterDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    EtatInventaire etat = EtatInventaire.dispo;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Ajouter un matériel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description / Salle',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<EtatInventaire>(
                initialValue: etat,
                decoration: const InputDecoration(labelText: 'État'),
                items: const [
                  DropdownMenuItem(
                    value: EtatInventaire.dispo,
                    child: Text('Disponible'),
                  ),
                  DropdownMenuItem(
                    value: EtatInventaire.maintenance,
                    child: Text('Maintenance'),
                  ),
                  DropdownMenuItem(
                    value: EtatInventaire.perdu,
                    child: Text('Perdu'),
                  ),
                ],
                onChanged: (v) => setDialogState(() => etat = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _blue),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                ref
                    .read(inventaireProvider.notifier)
                    .ajouter(
                      Inventaire(
                        name: nameCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        etatInventaire: etat,
                      ),
                    );
                Navigator.pop(ctx);
              },
              child: const Text(
                'Ajouter',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Inventaire item;
  final Color couleur;

  const _ItemCard({required this.item, required this.couleur});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: couleur,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltreEtatChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FiltreEtatChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          border: selected ? Border.all(color: Colors.black26, width: 2) : null,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: _blue,
      unselectedItemColor: Colors.black54,
      onTap: (index) {
        if (index == 1 && currentIndex != 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashBoard()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
      ],
    );
  }
}
