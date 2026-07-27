import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/model/inventaire_model.dart';
import 'package:scan_desc/view/colors/couleur.dart';
import 'package:scan_desc/view/widget/app_nav_bar.dart';
import 'package:scan_desc/view/widget/bottom_bar.dart';
import 'package:scan_desc/view/widget/button_etat.dart';
import 'package:scan_desc/view/widget/container_list.dart';
import 'package:scan_desc/view/widget/search_barr.dart';
import 'package:scan_desc/viewModel/inventaire_notifier.dart';

class ListMaintenance extends ConsumerWidget {
  const ListMaintenance({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceAsync = ref.watch(inventaireProvider);
    final recherche = ref.watch(searchProvider);
    ButtonEtat buttonEtat = ButtonEtat();
    ContainerList containerList = ContainerList();

    return Scaffold(
      appBar: AppNavBar.appBar(),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchBarr.searchBar(
                (value) => ref.read(searchProvider.notifier).state = value,
              ),
            ),
            buttonEtat.buildButton(context, ref),

            // On utilise .when, mais on s'assure que le résultat en cas de succès
            // prenne l'espace disponible dans la Column principale.
            maintenanceAsync.when(
              data: (maintenance) {
                final listMaintenance;
                if (recherche.isEmpty) {
                  listMaintenance = maintenance
                      .where(
                        (m) => m.etatInventaire == EtatInventaire.maintenance,
                      )
                      .toList();
                } else {
                  listMaintenance = maintenance
                      .where(
                        (e) =>
                            e.name.toLowerCase().contains(
                              recherche.toLowerCase(),
                            ) ||
                            e.description.toLowerCase().contains(
                              recherche.toLowerCase(),
                            ),
                      )
                      .toList();
                }
                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${listMaintenance.length}/${maintenance.length}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 2,
                        width: double.infinity,
                        color: Couleur.alerte,
                      ),
                      const SizedBox(height: 16),
                      // L'Expanded ici fonctionne à présent car son parent direct est une Column
                      // contenue dans un autre Expanded. Flutter sait maintenant calculer les tailles !
                      Expanded(
                        child: ListView.builder(
                          itemCount: listMaintenance.length,
                          itemBuilder: (context, index) {
                            final maintenances = listMaintenance[index];
                            return containerList.buildCard(
                              context,
                              maintenances.name,
                              maintenances.description,
                              Couleur.couleurEtat(maintenances.etatInventaire),
                              inventaire: maintenances,
                              ref: ref,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              // Petit fix pour éviter un autre crash potentiel :
              // Si c'est en erreur ou en chargement, on les met dans un Expanded ou un Center
              // pour que le layout reste propre.
              error: (e, _) => const Center(child: Text("Erreur")),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomBar.buildBottom(context, ref),
    );
  }
}
