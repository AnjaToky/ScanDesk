import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scan_desc/model/emprunter_model.dart';

class EmpruntFirestoreDao {
  final _col = FirebaseFirestore.instance.collection('emprunts');

  Future<String> ajouter(EmpruntDetail detail) async {
    final doc = await _col.add({
      'id_inventaire': detail.idInventaire,
      'nom_inventaire': detail.nomInventaire,
      'id_personne': detail.idPersonne,
      'nom_personne': detail.nomPersonne,
      'date_emprunt': detail.dateEmprunt.toIso8601String(),
      'date_remise': detail.dateRemise?.toIso8601String(),
    });
    return doc.id;
  }

  Future<void> retourner(String firestoreId, DateTime dateRemise) async {
    await _col.doc(firestoreId).update({
      'date_remise': dateRemise.toIso8601String(),
    });
  }

  Future<void> supprimer(String firestoreId) async {
    await _col.doc(firestoreId).delete();
  }

  Future<List<EmpruntDetail>> afficherDetail() async {
    final snap = await _col.orderBy('date_emprunt', descending: true).get();
    return snap.docs.map((doc) => _fromDoc(doc)).toList();
  }

  Stream<List<EmpruntDetail>> streamDetail() {
    return _col
        .orderBy('date_emprunt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  EmpruntDetail _fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmpruntDetail(
      id: 0,
      idInventaire: data['id_inventaire'] as int? ?? 0,
      nomInventaire: data['nom_inventaire'] as String? ?? '',
      idPersonne: data['id_personne'] as int? ?? 0,
      nomPersonne: data['nom_personne'] as String? ?? '',
      dateEmprunt: DateTime.parse(data['date_emprunt'] as String),
      dateRemise: data['date_remise'] != null
          ? DateTime.parse(data['date_remise'] as String)
          : null,
    );
  }
}
