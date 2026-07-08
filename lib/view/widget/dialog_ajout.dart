import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/model/inventaire_model.dart';
import 'package:scan_desc/view/colors/couleur.dart';
import 'package:scan_desc/view/qr_code_list_view.dart';
import 'package:scan_desc/viewModel/inventaire_notifier.dart';

class DialogAjout {
  static void showAjouterDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    EtatInventaire etat = EtatInventaire.dispo;
    int quantite = 1;

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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nombre de QR codes',
                    style: TextStyle(fontSize: 14),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: quantite > 1
                            ? () => setDialogState(() => quantite--)
                            : null,
                      ),
                      Text(
                        '$quantite',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setDialogState(() => quantite++),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Couleur.primaire,
              ),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;

                final name = nameCtrl.text.trim();
                final desc = descCtrl.text.trim();
                final etatFinal = etat;
                final quantiteFinal = quantite;

                Navigator.pop(ctx);

                final id = await ref
                    .read(inventaireProvider.notifier)
                    .ajouter(
                      Inventaire(
                        name: name,
                        description: desc,
                        etatInventaire: etatFinal,
                      ),
                    );

                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QrCodeListView(
                        inventaire: Inventaire(
                          id: id,
                          name: name,
                          description: desc,
                          etatInventaire: etatFinal,
                        ),
                        quantite: quantiteFinal,
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Ajouter',
                style: TextStyle(color: Couleur.textSecondaire),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
