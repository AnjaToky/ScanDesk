import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/model/inventaire_model.dart';
import 'package:scan_desc/view/colors/couleur.dart';
import 'package:scan_desc/view/widget/bottom_bar.dart';
import 'package:scan_desc/view/widget/button_etat.dart';
import 'package:scan_desc/view/widget/container_list.dart';
import 'package:scan_desc/viewModel/inventaire_notifier.dart';

class ListPerdu extends ConsumerWidget {
  const ListPerdu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perduAsync = ref.watch(inventaireProvider);
    ButtonEtat buttonEtat = ButtonEtat();
    ContainerList containerList = ContainerList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ScanDesc",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Couleur.primaire,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.all(8.0), child: SearchBar()),
            buttonEtat.buildButton(context, ref),

            perduAsync.when(
              data: (perdu) {
                final listPerdu = perdu
                    .where((m) => m.etatInventaire == EtatInventaire.perdu)
                    .toList();

                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${listPerdu.length}/${perdu.length}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 2,
                        width: double.infinity,
                        color: Couleur.erreur,
                      ),
                      const SizedBox(height: 16),

                      Expanded(
                        child: ListView.builder(
                          itemCount: listPerdu.length,
                          itemBuilder: (context, index) {
                            final perdue = listPerdu[index];
                            return containerList.buildCard(
                              context,
                              perdue.name,
                              perdue.description,
                              Couleur.erreur,
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
