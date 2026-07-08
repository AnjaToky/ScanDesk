import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scan_desc/model/personne_model.dart';

class PersonneFirestoreDao {
  final _col = FirebaseFirestore.instance.collection('personnes');

  Future<String> ajouter(Personne personne) async {
    final doc = await _col.add({'name': personne.name});
    return doc.id;
  }

  Future<void> supprimer(String firestoreId) async {
    await _col.doc(firestoreId).delete();
  }

  Future<List<Personne>> afficher() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs
        .map((doc) => Personne(id: 0, name: doc['name'] as String))
        .toList();
  }

  Stream<List<Personne>> stream() {
    return _col.orderBy('name').snapshots().map(
      (snap) => snap.docs
          .map((doc) => Personne(id: 0, name: doc['name'] as String))
          .toList(),
    );
  }
}
