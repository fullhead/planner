import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import "../utils.dart" as utils;
import "tasksmodel.dart";

class TasksDBWorker {
  TasksDBWorker._();
  static final TasksDBWorker db = TasksDBWorker._();
  late Database _db;

  Future<Database> get database async {
    _db = await init();
    return _db;
  }

  Future<Database> init() async {
    String path = join(utils.docsDir!.path, "tasks.db");
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY,
        description TEXT,
        dueDate TEXT,
        completed TEXT
      )
    """);
  }

  Task taskFromMap(Map<String, dynamic> inMap) {
    return Task()
      ..id = inMap["id"]
      ..description = inMap["description"]
      ..dueDate = inMap["dueDate"]
      ..completed = inMap["completed"];
  }

  Map<String, dynamic> taskToMap(Task inTask) {
    return {
      "id": inTask.id,
      "description": inTask.description,
      "dueDate": inTask.dueDate,
      "completed": inTask.completed,
    };
  }

  Future<int> create(Task inTask) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM tasks");
    int id = (val.first["id"] as int?) ?? 1;
    inTask.id = id;

    await db.rawInsert(
        "INSERT INTO tasks (id, description, dueDate, completed) VALUES (?, ?, ?, ?)",
        [id, inTask.description, inTask.dueDate, inTask.completed]);
    return id;
  }

  Future<Task> get(int inID) async {
    Database db = await database;
    var rec = await db.query("tasks", where: "id = ?", whereArgs: [inID]);
    return taskFromMap(rec.first);
  }

  Future<List<Task>> getAll() async {
    Database db = await database;
    var recs = await db.query("tasks");
    return recs.isNotEmpty ? recs.map((m) => taskFromMap(m)).toList() : [];
  }

  Future<void> update(Task inTask) async {
    Database db = await database;
    await db.update("tasks", taskToMap(inTask), where: "id = ?", whereArgs: [inTask.id]);
  }

  Future<void> delete(int inID) async {
    Database db = await database;
    await db.delete("tasks", where: "id = ?", whereArgs: [inID]);
  }
}
