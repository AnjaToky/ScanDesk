import 'package:scan_desc/configBdd/datbaseHelper.dart';
import 'package:scan_desc/model/emprunter_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class EmpruntDao {
  final dbProvider = DatabaseHelper.instance;

  Future<int> ajouterEmprunt(Emprunter emprunt) async {
    final db = await dbProvider.database;
    return await db.insert(
      'emprunt',
      emprunt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> editeEmprunt(Emprunter emprunt) async {
    final db = await dbProvider.database;
    return db.update(
      'emprunt',
      emprunt.toMap(),
      where: 'id = ?',
      whereArgs: [emprunt.id],
    );
  }

  Future<int> supprimerEmprunt(int id) async {
    final db = await dbProvider.database;
    return await db.delete('emprunt', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Emprunter>> afficherEmprunt() async {
    final db = await dbProvider.database;
    final result = await db.query('emprunt', orderBy: 'id DESC');
    return result.map((e) => Emprunter.fromJson(e)).toList();
  }

  Future<List<EmpruntDetail>> afficherEmpruntDetail() async {
    final db = await dbProvider.database;
    final result = await db.rawQuery('''
      SELECT
        e.id,
        e.id_inventaire,
        e.id_personne,
        e.date_emprunt,
        e.date_remise,
        p.name AS nom_personne,
        l.name AS nom_inventaire
      FROM emprunt e
      JOIN personne p ON e.id_personne = p.id
      JOIN liste    l ON e.id_inventaire = l.id
      ORDER BY e.id DESC
    ''');
    return result.map((e) => EmpruntDetail.fromJson(e)).toList();
  }
}
