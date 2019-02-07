import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Note {
  int _id;
  String _title;
  String _description;

  Note(this._title, this._description);

  Note.map(dynamic obj) {
    this._id = obj['id'];
    this._title = obj['title'];
    this._description = obj['description'];
  }

  int get id => _id;
  String get title => _title;
  String get description => _description;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;

    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
  }
}

class TodoDb {
  static final TodoDb _instance = new TodoDb.internal();

  factory TodoDb() => _instance;

  final String tableNote = 'todo';
  final String columnId = 'id';
  final String columnTitle = 'title';
  final String columnDescription = 'body';

  static Database _db;

  TodoDb.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'todo1.db');

    //await deleteDatabase(path); // just for testing

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableNote($columnId INTEGER PRIMARY KEY, $columnTitle TEXT, $columnDescription TEXT)');
  }

  Future<int> saveNote(Map<String, dynamic> note) async {
    var dbClient = await db;
    var result = await dbClient.insert(tableNote, note);
//    var result = await dbClient.rawInsert(
//        'INSERT INTO $tableNote ($columnTitle, $columnDescription) VALUES (\'${note.title}\', \'${note.description}\')');

    return result;
  }

  Future<List> getAllNotes() async {
    var dbClient = await db;
    var result = await dbClient
        .query(tableNote, columns: [columnId, columnTitle, columnDescription]);
//    var result = await dbClient.rawQuery('SELECT * FROM $tableNote');

    return result.toList();
  }
  
  Future<List<Map<String, dynamic>>> getAll() async {
    var dbClient = await db;
    // var result = await dbClient
    //     .query(tableNote, columns: [columnId, columnTitle, columnDescription]);
   var result = await dbClient.rawQuery('SELECT * FROM $tableNote');
    return result;
  }

  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM $tableNote'));
  }

  Future<Note> getNote(int id) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(tableNote,
        columns: [columnId, columnTitle, columnDescription],
        where: '$columnId = ?',
        whereArgs: [id]);
//    var result = await dbClient.rawQuery('SELECT * FROM $tableNote WHERE $columnId = $id');

    if (result.length > 0) {
      return new Note.fromMap(result.first);
    }

    return null;
  }

  Future<int> deleteByTitle(String title) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableNote, where: '$columnTitle = ?', whereArgs: [title]);
//    return await dbClient.rawDelete('DELETE FROM $tableNote WHERE $columnId = $id');
  }

  Future<int> deleteNote(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableNote, where: '$columnId = ?', whereArgs: [id]);
//    return await dbClient.rawDelete('DELETE FROM $tableNote WHERE $columnId = $id');
  }

  Future<int> updateNote(int id, Map<String, dynamic> note) async {
    var dbClient = await db;
    return await dbClient.update(tableNote, note,
        where: "$columnId = ?", whereArgs: [id]);
//    return await dbClient.rawUpdate(
//        'UPDATE $tableNote SET $columnTitle = \'${note.title}\', $columnDescription = \'${note.description}\' WHERE $columnId = ${note.id}');
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
