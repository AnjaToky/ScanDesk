import 'package:scan_desc/configBdd/datbaseHelper.dart';
import 'package:scan_desc/model/personne_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class PersonneDao {
  final dbProvider = DatabaseHelper.instance;

  Future<int> ajouterPersonne(Personne personne) async {
    final db = await dbProvider.database;
    return await db.insert(
      'personne',
      personne.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> editePersonne(Personne personne) async {
    final db = await dbProvider.database;
    return db.update(
      'personne',
      personne.toMap(),
      where: 'id = ?',
      whereArgs: [personne.id],
    );
  }

  Future<int> supprimerPersonne(int id) async {
    final db = await dbProvider.database;
    return await db.delete('personne', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Personne>> afficherPersonne() async {
    final db = await dbProvider.database;
    final result = await db.query('personne', orderBy: 'id DESC');
    return result.map((e) => Personne.fromJson(e)).toList();
  }
}
