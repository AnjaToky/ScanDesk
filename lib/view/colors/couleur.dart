import 'package:flutter/painting.dart';
import 'package:scan_desc/model/inventaire_model.dart';

class Couleur {
  static const Color primaire = Color(0xFF2563EB);
  static const Color secondaire = Color(0xFFF8FAFC);
  static const Color input = Color(0xffA3A3A3);
  static const Color textPrimaire = Color(0xff1E293B);
  static const Color textSecondaire = Color(0xFFF8FAFC);
  static const Color succes = Color(0xff22C55E);
  static const Color alerte = Color(0xffF59E0B);
  static const Color erreur = Color(0xffEF4444);

  static Color couleurEtat(EtatInventaire etat) {
    return switch (etat) {
      EtatInventaire.dispo => Couleur.succes,
      EtatInventaire.maintenance => Couleur.alerte,
      EtatInventaire.perdu => Couleur.erreur,
    };
  }
}
