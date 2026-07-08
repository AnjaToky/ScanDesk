import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/DAO/emprunt_firestore_dao.dart';
import 'package:scan_desc/model/emprunter_model.dart';

final empruntModel = Provider<EmprunterModel>((ref) => EmprunterModel());

final _firestoreDao = EmpruntFirestoreDao();

class EmpruntNotifier extends AsyncNotifier<List<Emprunter>> {
  @override
  Future<List<Emprunter>> build() async {
    final model = ref.watch(empruntModel);
    return model.afficherEmprunt();
  }

  Future<void> ajouterEmprunt(Emprunter emprunt, EmpruntDetail detail) async {
    final model = ref.read(empruntModel);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final insertedId = await model.ajouterEmprunt(emprunt);
      _firestoreDao.ajouter(insertedId, detail).ignore();
      return model.afficherEmprunt();
    });
  }

  Future<void> supprimerEmprunt(int id) async {
    final model = ref.read(empruntModel);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await model.supprimerEmprunt(id);
      return model.afficherEmprunt();
    });
  }

  Future<void> actualiser() async {
    final model = ref.read(empruntModel);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return model.afficherEmprunt();
    });
  }
}

final empruntProvider =
    AsyncNotifierProvider<EmpruntNotifier, List<Emprunter>>(
      EmpruntNotifier.new,
    );

final empruntDetailProvider = FutureProvider<List<EmpruntDetail>>((ref) async {
  ref.watch(empruntProvider);
  final model = ref.read(empruntModel);
  return model.afficherEmpruntDetail();
});
