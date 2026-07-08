import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/model/personne_model.dart';
import 'package:scan_desc/view/colors/couleur.dart';
import 'package:scan_desc/view/widget/bottom_bar.dart';
import 'package:scan_desc/viewModel/personne_notifier.dart';

class PersonnePage extends ConsumerWidget {
  const PersonnePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personnesAsync = ref.watch(personneProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Couleur.primaire,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Personnes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
      ),
      body: personnesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (personnes) => _buildBody(context, ref, personnes),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAjouterSheet(context, ref),
        backgroundColor: Couleur.primaire,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: BottomBar.buildBottom(context, ref),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, List<Personne> personnes) {
    if (personnes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Couleur.primaire.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline, size: 48, color: Couleur.primaire),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune personne',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Couleur.textPrimaire,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Appuyez sur + pour en ajouter',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Compteur
        Container(
          color: Couleur.primaire,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${personnes.length} personne${personnes.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: personnes.length,
            itemBuilder: (context, index) {
              final p = personnes[index];
              return _PersonneCard(
                personne: p,
                onSupprimer: () => _confirmerSuppression(context, ref, p),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAjouterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AjouterPersonneSheet(ref: ref),
    );
  }

  void _confirmerSuppression(BuildContext context, WidgetRef ref, Personne p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer', style: TextStyle(fontWeight: FontWeight.bold)),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Couleur.textPrimaire, fontSize: 14),
            children: [
              const TextSpan(text: 'Supprimer '),
              TextSpan(
                text: p.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' de la liste ?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Couleur.erreur,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              ref.read(personneProvider.notifier).supprimerPersonne(p.id);
              Navigator.pop(ctx);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _PersonneCard extends StatelessWidget {
  final Personne personne;
  final VoidCallback onSupprimer;

  const _PersonneCard({required this.personne, required this.onSupprimer});

  Color _avatarColor(String name) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF0EA5E9),
      Couleur.succes,
      Couleur.alerte,
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor(personne.name);
    final initiale = personne.name.isNotEmpty
        ? personne.name[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(
            initiale,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          personne.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Couleur.textPrimaire,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Color(0xFFCBD5E1)),
          onPressed: onSupprimer,
        ),
      ),
    );
  }
}

class _AjouterPersonneSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AjouterPersonneSheet({required this.ref});

  @override
  State<_AjouterPersonneSheet> createState() => _AjouterPersonneSheetState();
}

class _AjouterPersonneSheetState extends State<_AjouterPersonneSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Couleur.primaire.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_add_outlined,
                    color: Couleur.primaire,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nouvelle personne',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Couleur.textPrimaire,
                      ),
                    ),
                    Text(
                      'Entrez le nom complet',
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
              children: [
                TextField(
                  controller: _ctrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nom complet',
                    labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      size: 18,
                      color: Color(0xFFADB5BD),
                    ),
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final nom = _ctrl.text.trim();
                      if (nom.isEmpty) return;
                      widget.ref
                          .read(personneProvider.notifier)
                          .ajouterPersonne(Personne(id: 0, name: nom));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Couleur.primaire,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Ajouter',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
