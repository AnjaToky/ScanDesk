import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/model/inventaire_model.dart';
import 'package:scan_desc/view/colors/couleur.dart';
import 'package:scan_desc/view/emprunt/emprunt_dialog.dart';

class ContainerList {
  static Color couleurEtat(EtatInventaire etat) => Couleur.couleurEtat(etat);

  static String _labelEtat(EtatInventaire etat) {
    return switch (etat) {
      EtatInventaire.dispo        => 'Disponible',
      EtatInventaire.maintenance  => 'Maintenance',
      EtatInventaire.perdu        => 'Perdu',
      EtatInventaire.emprunter    => 'Emprunté',
    };
  }

  Widget buildCard(
    BuildContext context,
    String name,
    String description,
    Color statusColor, {
    Inventaire? inventaire,
    WidgetRef? ref,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Barre colorée gauche
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            // Contenu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
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
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Couleur.textPrimaire,
                            ),
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              inventaire != null
                                  ? _labelEtat(inventaire.etatInventaire)
                                  : '',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (inventaire != null &&
                        ref != null &&
                        inventaire.etatInventaire == EtatInventaire.dispo)
                      IconButton(
                        icon: Icon(
                          Icons.person_add_alt_1,
                          color: Couleur.primaire.withValues(alpha: 0.7),
                          size: 22,
                        ),
                        tooltip: 'Emprunter',
                        onPressed: () => showEmpruntDialog(context, inventaire),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
