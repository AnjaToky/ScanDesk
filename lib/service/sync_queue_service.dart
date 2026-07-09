import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:scan_desc/DAO/sync_queue_dao.dart';

/// Rend les écritures Firestore résilientes au mode hors ligne : une écriture
/// tentée immédiatement qui échoue est mise en file locale (table sync_queue)
/// puis rejouée automatiquement au retour de la connexion.
class SyncQueueService {
  static final SyncQueueService _instance = SyncQueueService._();
  SyncQueueService._();
  static SyncQueueService get instance => _instance;

  final _dao = SyncQueueDao();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _processing = false;

  void startListening() {
    if (_sub != null) return;
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        processQueue();
      }
    });
    // Vérifie aussi l'état courant au démarrage (le stream n'émet qu'au changement).
    Connectivity().checkConnectivity().then((results) {
      if (!results.contains(ConnectivityResult.none)) {
        processQueue();
      }
    });
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  /// Tente l'action tout de suite ; si elle échoue (hors ligne, erreur réseau...),
  /// la mémorise pour la rejouer plus tard au lieu de perdre l'écriture.
  Future<void> runOrEnqueue({
    required String collection,
    required String docId,
    required String operation,
    Map<String, dynamic>? payload,
    required Future<void> Function() action,
  }) async {
    try {
      await action();
    } catch (e) {
      debugPrint('[SyncQueueService] Écriture différée ($collection/$docId): $e');
      await _dao.enqueue(
        collection: collection,
        docId: docId,
        operation: operation,
        payload: payload,
      );
    }
  }

  Future<void> processQueue() async {
    if (_processing) return;
    _processing = true;
    try {
      final pending = await _dao.tousLesEnAttente();
      for (final item in pending) {
        try {
          final col = FirebaseFirestore.instance.collection(item.collection);
          if (item.operation == 'delete') {
            await col.doc(item.docId).delete();
          } else {
            await col.doc(item.docId).set(item.payload ?? {});
          }
          await _dao.supprimer(item.id);
        } catch (e) {
          debugPrint('[SyncQueueService] Rejeu impossible pour ${item.id}: $e');
          // On laisse l'élément en file, il sera retenté à la prochaine occasion.
        }
      }
    } finally {
      _processing = false;
    }
  }
}
