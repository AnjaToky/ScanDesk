import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scan_desc/DAO/inventaire_firestore_dao.dart';
import 'package:scan_desc/model/inventaire_model.dart';
import 'package:scan_desc/service/sync_queue_service.dart';

final inventaireModel = Provider<Inventairemodel>((ref) => Inventairemodel());

final _firestoreDao = InventaireFirestoreDao();
final _syncQueue = SyncQueueService.instance;

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
      final synced = inventaire.copyWith(id: insertedId);
      _syncQueue.runOrEnqueue(
        collection: 'inventaires',
        docId: insertedId.toString(),
        operation: 'set',
        payload: {
          'name': synced.name,
          'description': synced.description,
          'etat': synced.etatInventaire.name,
        },
        action: () => _firestoreDao.ajouter(synced),
      );
      return model.afficherInventaire();
    });
    return insertedId;
  }

  Future<void> editer(Inventaire inventaire) async {
    final model = ref.read(inventaireModel);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await model.editeInventaire(inventaire);
      _syncQueue.runOrEnqueue(
        collection: 'inventaires',
        docId: inventaire.id.toString(),
        operation: 'set',
        payload: {
          'name': inventaire.name,
          'description': inventaire.description,
          'etat': inventaire.etatInventaire.name,
        },
        action: () => _firestoreDao.editer(inventaire),
      );
      return model.afficherInventaire();
    });
  }

  Future<void> supprimer(int id) async {
    final model = ref.read(inventaireModel);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await model.supprimerInventaire(id);
      _syncQueue.runOrEnqueue(
        collection: 'inventaires',
        docId: id.toString(),
        operation: 'delete',
        action: () => _firestoreDao.supprimer(id),
      );
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
