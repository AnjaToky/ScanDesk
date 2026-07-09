import 'package:scan_desc/DAO/personne_dao.dart';

class Personne {
  int? id;
  String name;
  Personne({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
    };
  }

  factory Personne.fromJson(Map<String, dynamic> json) {
    return Personne(id: json['id'] as int?, name: json['name']);
  }
}

class PersonneModel {
  final PersonneDao personneDao = PersonneDao();

  Future<int> ajouterPersonne(Personne personne) async =>
      personneDao.ajouterPersonne(personne);

  Future<int> editePersonne(Personne personne) async =>
      personneDao.editePersonne(personne);

  Future<int> supprimerPersonne(int id) async =>
      personneDao.supprimerPersonne(id);

  Future<List<Personne>> afficherPersonne() async =>
      personneDao.afficherPersonne();
}
