import 'dart:io';
import 'package:sqflite/sqflite.dart'; // to work with sqllite database
import 'package:path_provider/path_provider.dart'; // to find Documents folder location depending on os
import 'package:path/path.dart'; // to have additional functions for path manipulation

// data model class of ToDo item
class Item {
  int? id;
  String title;
  bool done;
  DateTime? created_at;
  DateTime? updated_at;

  // empty constructor
  Item(
      {this.id,
      required this.title,
      required this.done,
      this.created_at,
      this.updated_at});

  // construct class from json
  factory Item.fromMap(Map<String, dynamic> map) => Item(
      id: map['id'],
      title: map['title'],
      done: map['done'] == 1 ? true : false,
      created_at: DateTime.parse(map['created_at']),
      updated_at: DateTime.parse(map['updated_at']));

  // return class as json
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'done': done == true ? 1 : 0,
      'created_at': created_at?.toIso8601String(),
      'updated_at': updated_at?.toIso8601String()
    };
  }

  Map<String, dynamic> toMapForUpdate() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'done': done == true ? 1 : 0,
      'updated_at': updated_at?.toIso8601String()
    };
  }
}

// singleton class to manage the database
class DatabaseManager {
  static const _databaseName = "ToDoDatabase.db";
  static const _databaseVersion = 2;
  static final itemTableName = 'items';

  // Make this a singleton class.
  DatabaseManager._privateConstructor();
  static final DatabaseManager instance = DatabaseManager._privateConstructor();

  // Only allow a single open connection to the database.
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $itemTableName (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          done INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
          ''');
  }

  Future insertItem(Item item) async {
    Database db = await database;
    int id = await db.insert(itemTableName, item.toMap());
    return id;
  }

  Future<Item> getItem(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(itemTableName,
        columns: ['title', 'done'], where: 'id = ?', whereArgs: [id]);
    return Item.fromMap(maps.first);
  }

  Future<List<Item>> getAllItems() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(itemTableName);
    List<Item> items =
        maps.isNotEmpty ? maps.map((x) => Item.fromMap(x)).toList() : [];
    return items;
  }

  Future<int> updateItem(Item item) async {
    Database db = await database;
    int id = await db.update(itemTableName, item.toMapForUpdate(),
        where: 'id = ?', whereArgs: [item.id]);
    return id;
  }

  Future<int> deleteItem(int id_to_delete) async {
    Database db = await database;
    int id = await db
        .delete(itemTableName, where: 'id = ?', whereArgs: [id_to_delete]);
    return id;
  }
}
