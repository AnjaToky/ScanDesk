import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:scan_desc/DAO/emprunt_dao.dart';
import 'package:scan_desc/DAO/inventaire_dao.dart';
import 'package:scan_desc/DAO/personne_dao.dart';
import 'package:scan_desc/model/emprunter_model.dart';
import 'package:scan_desc/model/inventaire_model.dart';
import 'package:scan_desc/model/personne_model.dart';

class SyncService {
  static final SyncService _instance = SyncService._();
  SyncService._();
  static SyncService get instance => _instance;

  final _fs = FirebaseFirestore.instance;
  final _inventaireDao = InventaireDao();
  final _personneDao = PersonneDao();
  final _empruntDao = EmpruntDao();

  /// Tire toutes les donnees Firestore et les insere dans SQLite local.
  /// Si hors ligne ou echec, continue avec les donnees locales.
  Future<void> syncFromFirestore() async {
    try {
      // Personnes et inventaires en parallele, emprunts apres (depend des deux)
      await Future.wait([_syncInventaires(), _syncPersonnes()]);
      await _syncEmprunts();
    } catch (e) {
      debugPrint('[SyncService] Sync ignore: $e');
    }
  }

  Future<void> _syncInventaires() async {
    final snap = await _fs.collection('inventaires').get();
    for (final doc in snap.docs) {
      final id = int.tryParse(doc.id);
      if (id == null) continue;
      final data = doc.data();
      await _inventaireDao.ajouterInventaire(
        Inventaire(
          id: id,
          name: data['name'] as String,
          description: data['description'] as String? ?? '',
          etatInventaire: EtatInventaire.values.firstWhere(
            (e) => e.name == data['etat'],
            orElse: () => EtatInventaire.dispo,
          ),
        ),
      );
    }
  }

  Future<void> _syncPersonnes() async {
    final snap = await _fs.collection('personnes').get();
    for (final doc in snap.docs) {
      final id = int.tryParse(doc.id);
      if (id == null) continue;
      await _personneDao.ajouterPersonne(
        Personne(id: id, name: doc['name'] as String),
      );
    }
  }

  Future<void> _syncEmprunts() async {
    final snap = await _fs.collection('emprunts').get();
    for (final doc in snap.docs) {
      final id = int.tryParse(doc.id);
      if (id == null) continue;
      final data = doc.data();
      await _empruntDao.ajouterEmprunt(
        Emprunter(
          id: id,
          idInventaire: data['id_inventaire'] as int,
          idPersonne: data['id_personne'] as int,
          dateEmprunt: DateTime.parse(data['date_emprunt'] as String),
          dateRemise: data['date_remise'] != null
              ? DateTime.parse(data['date_remise'] as String)
              : null,
        ),
      );
    }
  }
}
