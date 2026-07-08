import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scan_desc/model/emprunter_model.dart';

class EmpruntFirestoreDao {
  final _col = FirebaseFirestore.instance.collection('emprunts');

  // id = ID SQLite retourne apres l'insertion locale
  Future<void> ajouter(int id, EmpruntDetail detail) async {
    await _col.doc(id.toString()).set({
      'id_inventaire': detail.idInventaire,
      'nom_inventaire': detail.nomInventaire,
      'id_personne': detail.idPersonne,
      'nom_personne': detail.nomPersonne,
      'date_emprunt': detail.dateEmprunt.toIso8601String(),
      'date_remise': detail.dateRemise?.toIso8601String(),
    });
  }

  Future<void> supprimer(int id) async {
    await _col.doc(id.toString()).delete();
  }

  Future<List<EmpruntDetail>> afficher() async {
    final snap = await _col.orderBy('date_emprunt', descending: true).get();
    return snap.docs.map((doc) {
      final data = doc.data();
      return EmpruntDetail(
        id: int.tryParse(doc.id) ?? 0,
        idInventaire: data['id_inventaire'] as int? ?? 0,
        nomInventaire: data['nom_inventaire'] as String? ?? '',
        idPersonne: data['id_personne'] as int? ?? 0,
        nomPersonne: data['nom_personne'] as String? ?? '',
        dateEmprunt: DateTime.parse(data['date_emprunt'] as String),
        dateRemise: data['date_remise'] != null
            ? DateTime.parse(data['date_remise'] as String)
            : null,
      );
    }).toList();
  }
}
