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
      appBar: AppBar(
        title: const Text('Personnes'),
        backgroundColor: Couleur.primaire,
        foregroundColor: Colors.white,
      ),
      body: personnesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (personnes) {
          if (personnes.isEmpty) {
            return const Center(
              child: Text('Aucune personne.\nAppuyez sur + pour en ajouter.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: personnes.length,
            itemBuilder: (context, index) {
              final p = personnes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(p.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmerSuppression(context, ref, p),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAjouterDialog(context, ref),
        backgroundColor: Couleur.primaire,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add),
      ),
      bottomNavigationBar: BottomBar.buildBottom(context, ref),
    );
  }

  void _showAjouterDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter une personne'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nom'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Couleur.primaire),
            onPressed: () {
              final nom = nameCtrl.text.trim();
              if (nom.isEmpty) return;
              ref.read(personneProvider.notifier).ajouterPersonne(
                Personne(id: 0, name: nom),
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
    );
  }

  void _confirmerSuppression(BuildContext context, WidgetRef ref, Personne p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer "${p.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(personneProvider.notifier).supprimerPersonne(p.id);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
