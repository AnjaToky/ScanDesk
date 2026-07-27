import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String nomDb = "scan_desc.db";
  static const int versionDb = 4;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, nomDb);

    return await openDatabase(
      path,
      version: versionDb,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE liste (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        etat TEXT
      )
    ''');
    await _createPersonne(db);
    await _createEmprunt(db);
    await _createSyncQueue(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await _createPersonne(db);
      await _createEmprunt(db);
    }
    if (oldVersion < 4) {
      await _createSyncQueue(db);
    }
  }

  Future<void> _createPersonne(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS personne (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createEmprunt(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS emprunt (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_inventaire INTEGER,
        id_personne INTEGER,
        date_emprunt TEXT NOT NULL,
        date_remise TEXT
      )
    ''');
  }

  /// File d'attente des écritures Firestore à rejouer quand la synchronisation
  /// immédiate échoue (hors ligne, erreur réseau...).
  Future<void> _createSyncQueue(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        collection TEXT NOT NULL,
        doc_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }
}
