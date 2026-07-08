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

class ListDispo extends ConsumerWidget {
  const ListDispo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dispoAsync = ref.watch(inventaireProvider);
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
              child: SearchBarr.searchBar((value) {
                ref.read(searchProvider.notifier).state = value;
              }),
            ),
            buttonEtat.buildButton(context, ref),
            dispoAsync.when(
              data: (dispo) {
                final listDispo;

                if (recherche.isEmpty) {
                  // Sans recherche : uniquement les disponibles
                  listDispo = dispo
                      .where((e) => e.etatInventaire == EtatInventaire.dispo)
                      .toList();
                } else {
                  // Avec recherche : tous les éléments
                  listDispo = dispo
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
                        "${listDispo.length}/${dispo.length}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Container(
                        height: 2,
                        width: double.infinity,
                        color: Couleur.succes,
                      ),

                      SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: listDispo.length,
                          itemBuilder: (context, index) {
                            final disponible = listDispo[index];
                            return containerList.buildCard(
                              context,
                              disponible.name,
                              disponible.description,
                              Couleur.couleurEtat(
                                disponible.etatInventaire,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              error: (e, _) => Text("Erreur"),
              loading: () => Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomBar.buildBottom(context, ref),
    );
  }
}
