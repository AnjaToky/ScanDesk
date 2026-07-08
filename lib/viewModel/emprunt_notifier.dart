import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/model/emprunter_model.dart';

final empruntModel = Provider<EmprunterModel>((ref) => EmprunterModel());

class EmpruntNotifier extends AsyncNotifier<List<Emprunter>> {
  @override
  Future<List<Emprunter>> build() async {
    final model = ref.watch(empruntModel);
    return model.afficherEmprunt();
  }

  Future<void> ajouterEmprunt(Emprunter emprunt) async {
    final model = ref.read(empruntModel);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await model.ajouterEmprunt(emprunt);
      return model.afficherEmprunt();
    });
  }

  Future<void> ajouterPersonne(Emprunter emprunt) => ajouterEmprunt(emprunt);

  Future<void> editePersonne(Emprunter emprunt) async {
    final model = ref.read(empruntModel);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await model.editeEmprunt(emprunt);
      return model.afficherEmprunt();
    });
  }

  Future<void> supprimerPersonne(int id) async {
    final model = ref.read(empruntModel);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await model.supprimerEmprunt(id);
      return model.afficherEmprunt();
    });
  }

  Future<void> actualisePersonne() async {
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

// Se rafraîchit automatiquement quand empruntProvider change
final empruntDetailProvider = FutureProvider<List<EmpruntDetail>>((ref) async {
  ref.watch(empruntProvider);
  final model = ref.read(empruntModel);
  return model.afficherEmpruntDetail();
});
