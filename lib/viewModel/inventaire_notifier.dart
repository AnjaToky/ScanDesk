import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scan_desc/DAO/inventaire_firestore_dao.dart';
import 'package:scan_desc/model/inventaire_model.dart';

final inventaireModel = Provider<Inventairemodel>((ref) => Inventairemodel());

final _firestoreDao = InventaireFirestoreDao();

class InventaireNotifier extends AsyncNotifier<List<Inventaire>> {
  @override
  Future<List<Inventaire>> build() async {
    final model = ref.watch(inventaireModel);
    return model.afficherInventaire();
  }

  Future<int> ajouter(Inventaire inventaire) async {
    final model = ref.read(inventaireModel);
    state = const AsyncLoading();
    int insertedId = 0;
    state = await AsyncValue.guard(() async {
      insertedId = await model.ajouterInventaire(inventaire);
      _firestoreDao.ajouter(inventaire.copyWith(id: insertedId)).ignore();
      return model.afficherInventaire();
    });
    return insertedId;
  }

  Future<void> editer(Inventaire inventaire) async {
    final model = ref.read(inventaireModel);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await model.editeInventaire(inventaire);
      _firestoreDao.editer(inventaire).ignore();
      return model.afficherInventaire();
    });
  }

  Future<void> supprimer(int id) async {
    final model = ref.read(inventaireModel);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await model.supprimerInventaire(id);
      _firestoreDao.supprimer(id).ignore();
      return model.afficherInventaire();
    });
  }

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
