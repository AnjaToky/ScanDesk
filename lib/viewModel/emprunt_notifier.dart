import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/DAO/emprunt_firestore_dao.dart';
import 'package:scan_desc/model/emprunter_model.dart';
import 'package:scan_desc/model/inventaire_model.dart';
import 'package:scan_desc/service/sync_queue_service.dart';
import 'package:scan_desc/viewModel/inventaire_notifier.dart';

final empruntModel = Provider<EmprunterModel>((ref) => EmprunterModel());

final _firestoreDao = EmpruntFirestoreDao();
final _syncQueue = SyncQueueService.instance;

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
      _syncQueue.runOrEnqueue(
        collection: 'emprunts',
        docId: insertedId.toString(),
        operation: 'set',
        payload: {
          'id_inventaire': detail.idInventaire,
          'nom_inventaire': detail.nomInventaire,
          'id_personne': detail.idPersonne,
          'nom_personne': detail.nomPersonne,
          'date_emprunt': detail.dateEmprunt.toIso8601String(),
          'date_remise': detail.dateRemise?.toIso8601String(),
        },
        action: () => _firestoreDao.ajouter(insertedId, detail),
      );
      await _marquerInventaire(emprunt.idInventaire, EtatInventaire.emprunter);
      return model.afficherEmprunt();
    });
  }

  Future<void> supprimerEmprunt(int id, int idInventaire) async {
    final model = ref.read(empruntModel);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await model.supprimerEmprunt(id);
      _syncQueue.runOrEnqueue(
        collection: 'emprunts',
        docId: id.toString(),
        operation: 'delete',
        action: () => _firestoreDao.supprimer(id),
      );
      await _marquerInventaire(idInventaire, EtatInventaire.dispo);
      return model.afficherEmprunt();
    });
  }

  /// Met a jour l'etat de l'inventaire emprunte/rendu et rafraichit sa liste.
  Future<void> _marquerInventaire(int idInventaire, EtatInventaire etat) async {
    final inventaires = ref.read(inventaireProvider).value;
    if (inventaires == null) return;
    for (final inventaire in inventaires) {
      if (inventaire.id == idInventaire) {
        await ref
            .read(inventaireProvider.notifier)
            .editer(inventaire.copyWith(etatInventaire: etat));
        break;
      }
    }
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
