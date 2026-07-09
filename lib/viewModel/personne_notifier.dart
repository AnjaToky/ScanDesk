import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/DAO/personne_firestore_dao.dart';
import 'package:scan_desc/model/personne_model.dart';
import 'package:scan_desc/service/sync_queue_service.dart';

final personneModel = Provider<PersonneModel>((ref) => PersonneModel());

final _firestoreDao = PersonneFirestoreDao();
final _syncQueue = SyncQueueService.instance;

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
      final synced = Personne(id: insertedId, name: personne.name);
      _syncQueue.runOrEnqueue(
        collection: 'personnes',
        docId: insertedId.toString(),
        operation: 'set',
        payload: {'name': synced.name},
        action: () => _firestoreDao.ajouter(synced),
      );
      return model.afficherPersonne();
    });
  }

  Future<void> editePersonne(Personne personne) async {
    final model = ref.read(personneModel);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await model.editePersonne(personne);
      _syncQueue.runOrEnqueue(
        collection: 'personnes',
        docId: personne.id.toString(),
        operation: 'set',
        payload: {'name': personne.name},
        action: () => _firestoreDao.ajouter(personne),
      );
      return model.afficherPersonne();
    });
  }

  Future<void> supprimerPersonne(int id) async {
    final model = ref.read(personneModel);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await model.supprimerPersonne(id);
      _syncQueue.runOrEnqueue(
        collection: 'personnes',
        docId: id.toString(),
        operation: 'delete',
        action: () => _firestoreDao.supprimer(id),
      );
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
