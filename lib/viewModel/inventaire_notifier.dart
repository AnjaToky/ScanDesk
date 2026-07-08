import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scan_desc/model/inventaire_model.dart';

// 🔹 Provider du Model
final inventaireModel = Provider<Inventairemodel>((ref) {
  return Inventairemodel();
});

// 🔹 Notifier
class InventaireNotifier extends AsyncNotifier<List<Inventaire>> {
  @override
  Future<List<Inventaire>> build() async {
    final model = ref.watch(inventaireModel);
    return model.afficherInventaire();
  }

  // ➕ Ajouter
  Future<int> ajouter(Inventaire inventaire) async {
    final model = ref.read(inventaireModel);

    state = const AsyncLoading();

    int insertedId = 0;
    state = await AsyncValue.guard(() async {
      insertedId = await model.ajouterInventaire(inventaire);
      return model.afficherInventaire();
    });
    return insertedId;
  }

  // ✏️ Modifier
  Future<void> editer(Inventaire inventaire) async {
    final model = ref.read(inventaireModel);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await model.editeInventaire(inventaire);
      return model.afficherInventaire();
    });
  }

  // ❌ Supprimer
  Future<void> supprimer(int id) async {
    final model = ref.read(inventaireModel);

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await model.supprimerInventaire(id);
      return model.afficherInventaire();
    });
  }

  // 🔄 Refresh
  Future<void> refresh() async {
    final model = ref.read(inventaireModel);

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return model.afficherInventaire();
    });
  }
}

final searchProvider = StateProvider<String>((ref) => "");

// 🔹 Provider principal
final inventaireProvider =
    AsyncNotifierProvider<InventaireNotifier, List<Inventaire>>(
      InventaireNotifier.new,
    );
