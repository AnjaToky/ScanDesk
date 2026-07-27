import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/model/inventaire_model.dart';
import 'package:scan_desc/view/colors/couleur.dart';
import 'package:scan_desc/view/widget/bottom_bar.dart';
import 'package:scan_desc/viewModel/emprunt_notifier.dart';
import 'package:scan_desc/viewModel/inventaire_notifier.dart';

String _formatDate(DateTime date) {
  const months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class DashBoard extends ConsumerWidget {
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncInventaire = ref.watch(inventaireProvider);
    final asyncEmprunts = ref.watch(empruntDetailProvider);
    final retards = asyncEmprunts.value?.where((e) => e.estEnRetard).length ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: asyncInventaire.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (items) => _buildBody(context, items, retards),
      ),
      bottomNavigationBar: BottomBar.buildBottom(context, ref),
    );
  }

  Widget _buildBody(BuildContext context, List<Inventaire> items, int retards) {
    final total = items.length;
    final dispo = items.where((i) => i.etatInventaire == EtatInventaire.dispo).length;
    final maintenance = items.where((i) => i.etatInventaire == EtatInventaire.maintenance).length;
    final perdu = items.where((i) => i.etatInventaire == EtatInventaire.perdu).length;
    final emprunter = items.where((i) => i.etatInventaire == EtatInventaire.emprunter).length;

    return CustomScrollView(
      slivers: [
        // Header
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          backgroundColor: Couleur.primaire,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Couleur.primaire, const Color(0xFF1E40AF)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'ScanDesk',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(DateTime.now()),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          title: const Text(
            'ScanDesk',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bouton Scan CTA
                _ScanCta(context: context),
                const SizedBox(height: 24),

                // Titre stats
                const Text(
                  'Vue d\'ensemble',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Couleur.textPrimaire,
                  ),
                ),
                const SizedBox(height: 12),

                // Grille stats
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _StatTile(
                      label: 'Total',
                      value: total,
                      icon: Icons.inventory_2_outlined,
                      color: Couleur.primaire,
                    ),
                    _StatTile(
                      label: 'Disponible',
                      value: dispo,
                      icon: Icons.check_circle_outline,
                      color: Couleur.succes,
                    ),
                    _StatTile(
                      label: 'Maintenance',
                      value: maintenance,
                      icon: Icons.build_outlined,
                      color: Couleur.alerte,
                    ),
                    _StatTile(
                      label: 'Perdu',
                      value: perdu,
                      icon: Icons.warning_amber_outlined,
                      color: Couleur.erreur,
                    ),
                  ],
                ),

                if (emprunter > 0) ...[
                  const SizedBox(height: 12),
                  _StatTileFull(
                    label: 'Emprunté',
                    value: emprunter,
                    icon: Icons.person_outline,
                    color: const Color(0xFF6366F1),
                  ),
                ],

                if (retards > 0) ...[
                  const SizedBox(height: 12),
                  _StatTileFull(
                    label: 'Emprunts en retard',
                    value: retards,
                    icon: Icons.warning_amber_outlined,
                    color: Couleur.erreur,
                  ),
                ],

                const SizedBox(height: 24),

                // Activité récente
                const Text(
                  'Récemment ajoutés',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Couleur.textPrimaire,
                  ),
                ),
                const SizedBox(height: 12),
                _RecentList(items: items),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanCta extends StatelessWidget {
  final BuildContext context;
  const _ScanCta({required this.context});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/scan-screen'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Couleur.primaire.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Couleur.primaire.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: Couleur.primaire,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scanner un QR code',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Couleur.textPrimaire,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Identifiez un matériel rapidement',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTileFull extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatTileFull({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const Spacer(),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentList extends StatelessWidget {
  final List<Inventaire> items;
  const _RecentList({required this.items});

  @override
  Widget build(BuildContext context) {
    final recent = items.take(5).toList();

    if (recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('Aucun matériel ajouté', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: recent.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final color = Couleur.couleurEtat(item.etatInventaire);
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  item.description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.etatInventaire.name,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (i < recent.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
