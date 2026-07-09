import 'package:scan_desc/DAO/emprunt_dao.dart';

class Emprunter {
  int? id;
  int idInventaire;
  int idPersonne;
  DateTime dateEmprunt;
  DateTime? dateRemise;

  Emprunter({
    this.id,
    required this.idInventaire,
    required this.idPersonne,
    required this.dateEmprunt,
    this.dateRemise,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'id_inventaire': idInventaire,
      'id_personne': idPersonne,
      'date_emprunt': dateEmprunt.toIso8601String(),
      'date_remise': dateRemise?.toIso8601String(),
    };
  }

  factory Emprunter.fromJson(Map<String, dynamic> json) {
    return Emprunter(
      id: json['id'] as int?,
      idInventaire: json['id_inventaire'] as int,
      idPersonne: json['id_personne'] as int,
      dateEmprunt: DateTime.parse(json['date_emprunt'] as String),
      dateRemise: json['date_remise'] != null
          ? DateTime.parse(json['date_remise'] as String)
          : null,
    );
  }
}

class EmpruntDetail {
  final int id;
  final int idInventaire;
  final String nomInventaire;
  final int idPersonne;
  final String nomPersonne;
  final DateTime dateEmprunt;
  final DateTime? dateRemise;

  EmpruntDetail({
    required this.id,
    required this.idInventaire,
    required this.nomInventaire,
    required this.idPersonne,
    required this.nomPersonne,
    required this.dateEmprunt,
    this.dateRemise,
  });

  factory EmpruntDetail.fromJson(Map<String, dynamic> json) {
    return EmpruntDetail(
      id: json['id'] as int,
      idInventaire: json['id_inventaire'] as int,
      nomInventaire: json['nom_inventaire'] as String,
      idPersonne: json['id_personne'] as int,
      nomPersonne: json['nom_personne'] as String,
      dateEmprunt: DateTime.parse(json['date_emprunt'] as String),
      dateRemise: json['date_remise'] != null
          ? DateTime.parse(json['date_remise'] as String)
          : null,
    );
  }

  bool get estRetourne => dateRemise != null;

  /// En retard si une date de retour prévue est dépassée et que l'emprunt
  /// existe toujours (un emprunt rendu est supprimé de la base, cf. EmpruntNotifier.supprimerEmprunt).
  bool get estEnRetard =>
      dateRemise != null && dateRemise!.isBefore(DateTime.now());
}

class EmprunterModel {
  final EmpruntDao empruntDao = EmpruntDao();

  Future<int> ajouterEmprunt(Emprunter emprunt) async =>
      empruntDao.ajouterEmprunt(emprunt);

  Future<int> editeEmprunt(Emprunter emprunt) async =>
      empruntDao.editeEmprunt(emprunt);

  Future<int> supprimerEmprunt(int id) async =>
      empruntDao.supprimerEmprunt(id);

  Future<List<Emprunter>> afficherEmprunt() async =>
      empruntDao.afficherEmprunt();

  Future<List<EmpruntDetail>> afficherEmpruntDetail() async =>
      empruntDao.afficherEmpruntDetail();
}
