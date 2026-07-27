import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scan_desc/model/inventaire_model.dart';

class InventaireFirestoreDao {
  final _col = FirebaseFirestore.instance.collection('inventaires');

  Future<void> ajouter(Inventaire inventaire) async {
    await _col.doc(inventaire.id.toString()).set({
      'name': inventaire.name,
      'description': inventaire.description,
      'etat': inventaire.etatInventaire.name,
    });
  }

  Future<void> editer(Inventaire inventaire) async {
    await _col.doc(inventaire.id.toString()).update({
      'name': inventaire.name,
      'description': inventaire.description,
      'etat': inventaire.etatInventaire.name,
    });
  }

  Future<void> supprimer(int id) async {
    await _col.doc(id.toString()).delete();
  }

  Stream<List<Inventaire>> stream() {
    return _col.orderBy('name').snapshots().map(
      (snap) => snap.docs.map((doc) {
        return Inventaire(
          name: doc['name'] as String,
          description: doc['description'] as String? ?? '',
          etatInventaire: EtatInventaire.values.firstWhere(
            (e) => e.name == doc['etat'],
            orElse: () => EtatInventaire.dispo,
          ),
        );
      }).toList(),
    );
  }

  Future<List<Inventaire>> afficher() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs.map((doc) {
      return Inventaire(
        name: doc['name'] as String,
        description: doc['description'] as String? ?? '',
        etatInventaire: EtatInventaire.values.firstWhere(
          (e) => e.name == doc['etat'],
          orElse: () => EtatInventaire.dispo,
        ),
      );
    }).toList();
  }
}
