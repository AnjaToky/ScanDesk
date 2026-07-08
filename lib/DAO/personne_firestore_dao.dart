import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scan_desc/model/personne_model.dart';

class PersonneFirestoreDao {
  final _col = FirebaseFirestore.instance.collection('personnes');

  // personne.id doit etre l'ID SQLite (retourne par l'insertion locale)
  Future<void> ajouter(Personne personne) async {
    await _col.doc(personne.id.toString()).set({'name': personne.name});
  }

  Future<void> supprimer(int id) async {
    await _col.doc(id.toString()).delete();
  }

  Future<List<Personne>> afficher() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs
        .map((doc) => Personne(
              id: int.tryParse(doc.id) ?? 0,
              name: doc['name'] as String,
            ))
        .toList();
  }
}
