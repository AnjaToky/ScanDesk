import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/view/colors/couleur.dart';
import 'package:scan_desc/view/widget/bottom_bar.dart';
import 'package:scan_desc/view/widget/button_etat.dart';
import 'package:scan_desc/view/widget/container_list.dart';
import 'package:scan_desc/viewModel/inventaire_notifier.dart';

class ListTout extends ConsumerWidget {
  const ListTout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toutAsync = ref.watch(inventaireProvider);
    final recherche = ref.watch(searchProvider);
    ButtonEtat buttonEtat = ButtonEtat();
    ContainerList containerList = ContainerList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ScanDesc",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchBar(
                hintText: "Rechercher...",
                onChanged: (value) {
                  ref.read(searchProvider.notifier).state = value;
                },
                leading: const Icon(Icons.search),
              ),
            ),
            buttonEtat.buildButton(context, ref),

            toutAsync.when(
              data: (tout) {
                final listeFiltre = tout.where((element) {
                  return element.name.toLowerCase().contains(
                    recherche.toLowerCase(),
                  );
                }).toList();
                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${listeFiltre.length}/${tout.length}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Container(
                        height: 2,
                        width: double.infinity,
                        color: Couleur.primaire,
                      ),

                      SizedBox(height: 16),
                      Expanded(
                        child: listeFiltre.isEmpty
                            ? const Center(
                                child: Text("Aucune materielle trouver"),
                              )
                            : ListView.builder(
                                itemCount: listeFiltre.length,
                                itemBuilder: (context, index) {
                                  final touts = listeFiltre[index];
                                  return containerList.buildCard(
                                    context,
                                    touts.name,
                                    touts.description,
                                    ContainerList.couleurEtat(
                                      touts.etatInventaire,
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
