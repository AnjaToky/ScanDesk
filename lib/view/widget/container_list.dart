import 'package:flutter/material.dart';
import 'package:scan_desc/model/inventaire_model.dart';
import 'package:scan_desc/view/colors/couleur.dart';

class ContainerList {
  static Color couleurEtat(EtatInventaire etat) {
    return switch (etat) {
      EtatInventaire.dispo => Couleur.succes,
      EtatInventaire.maintenance => Couleur.alerte,
      EtatInventaire.perdu => Couleur.erreur,
    };
  }

  Widget buildCard(
    BuildContext context,
    String name,
    String description,
    Color containerColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
      ),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
