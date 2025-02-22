import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import "../utils.dart" as utils;
import 'appointmentsmodel.dart';

class AppointmentsDBWorker {
  AppointmentsDBWorker._();

  static final AppointmentsDBWorker db = AppointmentsDBWorker._();

  late Database _db;

  Future<Database> get database async {
    _db = await init();
    return _db;
  }

  Future<Database> init() async {
    String path = join(utils.docsDir!.path, "appointments.db");
    Database db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS appointments (
        id INTEGER PRIMARY KEY,
        title TEXT,
        description TEXT,
        apptDate TEXT,
        apptTime TEXT
      )
    """);
  }

  Appointment appointmentFromMap(Map inMap) {
    return Appointment()
      ..id = inMap["id"]
      ..title = inMap["title"]
      ..description = inMap["description"]
      ..apptDate = inMap["apptDate"]
      ..apptTime = inMap["apptTime"];
  }

  Map<String, dynamic> appointmentToMap(Appointment inAppointment) {
    return {
      "id": inAppointment.id,
      "title": inAppointment.title,
      "description": inAppointment.description,
      "apptDate": inAppointment.apptDate,
      "apptTime": inAppointment.apptTime
    };
  }

  Future<void> create(Appointment inAppointment) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM appointments");
    int id = (val.first["id"] as int?) ?? 1;
    inAppointment.id = id;

    await db.rawInsert(
        "INSERT INTO appointments (id, title, description, apptDate, apptTime) VALUES (?, ?, ?, ?, ?)",
        [id, inAppointment.title, inAppointment.description, inAppointment.apptDate, inAppointment.apptTime]
    );
  }

  Future<Appointment> get(int inID) async {
    Database db = await database;
    var rec = await db.query("appointments", where: "id = ?", whereArgs: [inID]);
    return appointmentFromMap(rec.first);
  }

  Future<List<Appointment>> getAll() async {
    Database db = await database;
    var recs = await db.query("appointments");
    return recs.isNotEmpty ? recs.map((m) => appointmentFromMap(m)).toList() : [];
  }

  Future<void> update(Appointment inAppointment) async {
    Database db = await database;
    await db.update("appointments", appointmentToMap(inAppointment), where: "id = ?", whereArgs: [inAppointment.id]);
  }

  Future<void> delete(int inID) async {
    Database db = await database;
    await db.delete("appointments", where: "id = ?", whereArgs: [inID]);
  }
}
