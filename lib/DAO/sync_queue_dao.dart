import 'dart:convert';

import 'package:scan_desc/configBdd/datbaseHelper.dart';

class SyncQueueItem {
  final int id;
  final String collection;
  final String docId;
  final String operation; // 'set' ou 'delete'
  final Map<String, dynamic>? payload;

  SyncQueueItem({
    required this.id,
    required this.collection,
    required this.docId,
    required this.operation,
    required this.payload,
  });

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    final payloadRaw = json['payload'] as String?;
    return SyncQueueItem(
      id: json['id'] as int,
      collection: json['collection'] as String,
      docId: json['doc_id'] as String,
      operation: json['operation'] as String,
      payload: payloadRaw != null
          ? jsonDecode(payloadRaw) as Map<String, dynamic>
          : null,
    );
  }
}

class SyncQueueDao {
  final dbProvider = DatabaseHelper.instance;

  Future<void> enqueue({
    required String collection,
    required String docId,
    required String operation,
    Map<String, dynamic>? payload,
  }) async {
    final db = await dbProvider.database;
    await db.insert('sync_queue', {
      'collection': collection,
      'doc_id': docId,
      'operation': operation,
      'payload': payload != null ? jsonEncode(payload) : null,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<SyncQueueItem>> tousLesEnAttente() async {
    final db = await dbProvider.database;
    final result = await db.query('sync_queue', orderBy: 'id ASC');
    return result.map((e) => SyncQueueItem.fromJson(e)).toList();
  }

  Future<void> supprimer(int id) async {
    final db = await dbProvider.database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }
}
