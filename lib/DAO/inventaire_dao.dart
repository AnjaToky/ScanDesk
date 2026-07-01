import 'package:scan_desc/configBdd/datbaseHelper.dart';
import 'package:scan_desc/model/inventaire_model.dart';
import 'package:sqflite/sqflite.dart';

class InventaireDao {
  final dbProvider = DatabaseHelper.instance;

  Future<int> ajouterInventaire(Inventaire inventaire) async {
    final db = await dbProvider.database;
    return await db.insert(
      'liste',
      inventaire.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> editeInventaire(Inventaire inventaire) async {
    final db = await dbProvider.database;
    return db.update(
      'liste',
      inventaire.toMap(),
      where: 'id = ?',
      whereArgs: [inventaire.id],
    );
  }

  Future<int> supprimerInventaire(int id) async {
    final db = await dbProvider.database;
    return await db.delete('liste', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Inventaire>> afficherInventaire() async {
    final db = await dbProvider.database;
    final result = await db.query('liste', orderBy: 'id DESC');
    return result.map((e) => Inventaire.fromJson(e)).toList();
  }
}
