import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import "../utils.dart" as utils;
import "contactsmodel.dart";

class ContactsDBWorker {

  ContactsDBWorker._();
  static final ContactsDBWorker db = ContactsDBWorker._();
  late Database _db;

  Future<Database> get database async {
    _db = await init();
    return _db;
  }

  Future<Database> init() async {
    String path = join(utils.docsDir!.path, "contacts.db");
    Database db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS contacts (
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT,
        phone TEXT,
        birthday TEXT
      )
    """);
  }

  Contact contactFromMap(Map inMap) {
    return Contact()
      ..id = inMap["id"]
      ..name = inMap["name"]
      ..email = inMap["email"]
      ..phone = inMap["phone"]
      ..birthday = inMap["birthday"];
  }

  Map<String, dynamic> contactToMap(Contact inContact) {
    return {
      "id": inContact.id,
      "name": inContact.name,
      "phone": inContact.phone,
      "email": inContact.email,
      "birthday": inContact.birthday
    };
  }

  Future<int> create(Contact inContact) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM contacts");
    int id = (val.first["id"] as int?) ?? 1;
    inContact.id = id;

    await db.rawInsert(
        "INSERT INTO contacts (id, name, email, phone, birthday) VALUES (?, ?, ?, ?, ?)",
        [id, inContact.name, inContact.email, inContact.phone, inContact.birthday]
    );
    return id;
  }

  Future<Contact> get(int inID) async {
    Database db = await database;
    var rec = await db.query("contacts", where: "id = ?", whereArgs: [inID]);
    return contactFromMap(rec.first);
  }

  Future<List<Contact>> getAll() async {
    Database db = await database;
    var recs = await db.query("contacts");
    return recs.isNotEmpty ? recs.map((m) => contactFromMap(m)).toList() : [];
  }

  Future<void> update(Contact inContact) async {
    Database db = await database;
    await db.update("contacts", contactToMap(inContact), where: "id = ?", whereArgs: [inContact.id]);
  }

  Future<void> delete(int inID) async {
    Database db = await database;
    await db.delete("contacts", where: "id = ?", whereArgs: [inID]);
  }
}
