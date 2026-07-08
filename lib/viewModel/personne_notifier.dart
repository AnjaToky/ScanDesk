import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/DAO/personne_firestore_dao.dart';
import 'package:scan_desc/model/personne_model.dart';

final personneModel = Provider<PersonneModel>((ref) => PersonneModel());

final _firestoreDao = PersonneFirestoreDao();

class PersonneNotifier extends AsyncNotifier<List<Personne>> {
  @override
  Future<List<Personne>> build() async {
    final model = ref.watch(personneModel);
    return model.afficherPersonne();
  }

  Future<void> ajouterPersonne(Personne personne) async {
    final model = ref.read(personneModel);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final insertedId = await model.ajouterPersonne(personne);
      _firestoreDao
          .ajouter(Personne(id: insertedId, name: personne.name))
          .ignore();
      return model.afficherPersonne();
    });
  }

  Future<void> editePersonne(Personne personne) async {
    final model = ref.read(personneModel);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await model.editePersonne(personne);
      return model.afficherPersonne();
    });
  }

  Future<void> supprimerPersonne(int id) async {
    final model = ref.read(personneModel);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await model.supprimerPersonne(id);
      return model.afficherPersonne();
    });
  }

  Future<void> actualisePersonne() async {
    final model = ref.read(personneModel);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return model.afficherPersonne();
    });
  }
}

final personneProvider =
    AsyncNotifierProvider<PersonneNotifier, List<Personne>>(
      PersonneNotifier.new,
    );
