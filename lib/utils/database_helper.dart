import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';

class DatabaseHelper {
  DatabaseHelper._createInstance(); //Named Constructor to create instance of DatabaseHelper

  static final DatabaseHelper _databaseHelper =
      DatabaseHelper._createInstance(); //Singleton class

  static Database? _database; //Singleton database

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  factory DatabaseHelper() {
    //Factory methods helps not to create another instance
    return _databaseHelper;
  }

  // Getter for database
  Future<Database?> get database async {
    _database ??=
        await initializeDatabase(); //If database is null return to initializedatabase function
    return _database;
  }

  // Initialize Database
  Future<Database> initializeDatabase() async {
    // Get directory path for both Android and IOs to store database
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'note.db';

    // Create database at the given path
    var notesDatabase = openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  // Create Database Table
  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable ($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  // Fetch Operation: Get all the note objects from the databse (R)
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database? db = await database;

    // var result =
    //      await db?.rawQuery('SELECT * FROM $noteTable order by $colPriority');    ->Raw query

    var result = await db!.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  // Insert Operation: Insert a note objects to the database (C)
  Future<int> insertNote(Note note) async {
    Database? db = await database;
    var result = await db!.insert(noteTable, note.toMap());
    return result;
  }

  // Update Operation: Update a Note objects and save it to databse (U)
  Future<int> updateNote(Note note) async {
    Database? db = await database;
    var result = await db!.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Delete Operation: Delete a Note objects from database (D)
  Future<int> deleteNote(int id) async {
    Database? db = await database;
    var result =
        await db!.delete(noteTable, where: '$colId = ? ', whereArgs: [id]);
    return result;
  }

  // Get number of Note objects in database
  Future<int> getCount() async {
    Database? db = await database;
    List<Map<String, dynamic>> x =
        await db!.rawQuery('SELECT COUNT (*) from $noteTable');
    int? result = Sqflite.firstIntValue(x);
    return result!;
  }

  // Get the Map list <list<Map>> and convert it to the Notelist object
  Future<List<Note>> getNoteList() async {
    var noteMapList =
        await getNoteMapList(); //Get the maplist from the database
    int count =
        noteMapList.length; //Count the number of map entries in db table

    List<Note> noteList = <Note>[];
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(
          noteMapList[i])); //For loop to create a note list from a map list
    }
    return noteList;
  }
}
