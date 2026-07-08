import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/model/emprunter_model.dart';
import 'package:scan_desc/view/widget/bottom_bar.dart';
import 'package:scan_desc/viewModel/emprunt_notifier.dart';

class EmpruntPage extends ConsumerWidget {
  const EmpruntPage({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empruntsAsync = ref.watch(empruntDetailProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Emprunts')),
      body: empruntsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (emprunts) {
          if (emprunts.isEmpty) {
            return const Center(child: Text('Aucun emprunt enregistré'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: emprunts.length,
            itemBuilder: (context, index) {
              final e = emprunts[index];
              return _EmpruntCard(
                emprunt: e,
                formatDate: _formatDate,
                onSupprimer: () =>
                    ref.read(empruntProvider.notifier).supprimerPersonne(e.id),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomBar.buildBottom(context, ref),
    );
  }
}

class _EmpruntCard extends StatelessWidget {
  final EmpruntDetail emprunt;
  final String Function(DateTime?) formatDate;
  final VoidCallback onSupprimer;

  const _EmpruntCard({
    required this.emprunt,
    required this.formatDate,
    required this.onSupprimer,
  });

  @override
  Widget build(BuildContext context) {
    final couleur = emprunt.estRetourne ? Colors.green[100]! : Colors.orange[100]!;
    final badge = emprunt.estRetourne ? 'Retourné' : 'En cours';
    final badgeCouleur = emprunt.estRetourne ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    emprunt.nomInventaire,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: couleur,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: badgeCouleur,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Emprunté par : ${emprunt.nomPersonne}'),
            Text('Date emprunt : ${formatDate(emprunt.dateEmprunt)}'),
            Text('Retour prévu : ${formatDate(emprunt.dateRemise)}'),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onSupprimer,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
