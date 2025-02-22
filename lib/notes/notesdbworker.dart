import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import "../utils.dart" as utils;
import "notesmodel.dart";

class NotesDBWorker {
  NotesDBWorker._();
  static final NotesDBWorker db = NotesDBWorker._();

  late Database _db;

  Future<Database> get database async {
    _db = await init();
    return _db;
  }

  Future<Database> init() async {
    String path = join(utils.docsDir!.path, "notes.db");
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY,
        title TEXT,
        content TEXT,
        color TEXT
      )
    """);
  }

  Note noteFromMap(Map<String, dynamic> inMap) {
    return Note()
      ..id = inMap["id"]
      ..title = inMap["title"]
      ..content = inMap["content"]
      ..color = inMap["color"];
  }

  Map<String, dynamic> noteToMap(Note inNote) {
    return {
      "id": inNote.id,
      "title": inNote.title,
      "content": inNote.content,
      "color": inNote.color,
    };
  }

  Future<int> create(Note inNote) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM notes");
    int id = (val.first["id"] as int?) ?? 1;
    inNote.id = id;

    await db.rawInsert(
        "INSERT INTO notes (id, title, content, color) VALUES (?, ?, ?, ?)",
        [id, inNote.title, inNote.content, inNote.color]);

    return id;
  }

  Future<Note> get(int inID) async {
    Database db = await database;
    var rec = await db.query("notes", where: "id = ?", whereArgs: [inID]);
    return noteFromMap(rec.first);
  }

  Future<List<Note>> getAll() async {
    Database db = await database;
    var recs = await db.query("notes");
    return recs.isNotEmpty ? recs.map((m) => noteFromMap(m)).toList() : [];
  }

  Future<void> update(Note inNote) async {
    Database db = await database;
    await db.update("notes", noteToMap(inNote), where: "id = ?", whereArgs: [inNote.id]);
  }

  Future<void> delete(int inID) async {
    Database db = await database;
    await db.delete("notes", where: "id = ?", whereArgs: [inID]);
  }
}
