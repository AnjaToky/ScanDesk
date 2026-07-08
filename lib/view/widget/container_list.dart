import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/model/inventaire_model.dart';
import 'package:scan_desc/view/emprunt/emprunt_dialog.dart';
import 'package:scan_desc/view/colors/couleur.dart';

class ContainerList {
  static Color couleurEtat(EtatInventaire etat) {
    return Couleur.couleurEtat(etat);
  }

  Widget buildCard(
    BuildContext context,
    String name,
    String description,
    Color containerColor, {
    Inventaire? inventaire,
    WidgetRef? ref,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (inventaire != null && ref != null)
            IconButton(
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
              tooltip: 'Emprunter',
              onPressed: () => showEmpruntDialog(context, inventaire),
            ),
        ],
      ),
    );
  }
}
