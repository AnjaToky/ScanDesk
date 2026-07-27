import 'dart:core';

import 'package:scan_desc/DAO/inventaire_dao.dart';

enum EtatInventaire { perdu, maintenance, dispo, emprunter}

class Inventaire {
  int? id;
  String name;
  String description;
  EtatInventaire etatInventaire;

  Inventaire({
    this.id,
    required this.name,
    required this.description,
    required this.etatInventaire,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'etat': etatInventaire.name,
    };
  }

  Inventaire copyWith({int? id, EtatInventaire? etatInventaire}) {
    return Inventaire(
      id: id ?? this.id,
      name: name,
      description: description,
      etatInventaire: etatInventaire ?? this.etatInventaire,
    );
  }

  factory Inventaire.fromJson(Map<String, dynamic> json) {
    return Inventaire(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      etatInventaire: EtatInventaire.values.firstWhere(
        (e) => e.name == json['etat'],
        orElse: () => EtatInventaire.dispo,
      ),
    );
  }
}

class Inventairemodel {
  final InventaireDao inventaireDao = InventaireDao();

  Future<int> ajouterInventaire(Inventaire inventaire) async =>
      inventaireDao.ajouterInventaire(inventaire);

  Future<int> editeInventaire(Inventaire inventaire) async =>
      inventaireDao.editeInventaire(inventaire);

  Future<int> supprimerInventaire(int id) async =>
      inventaireDao.supprimerInventaire(id);

  Future<List<Inventaire>> afficherInventaire() async =>
      inventaireDao.afficherInventaire();
}
