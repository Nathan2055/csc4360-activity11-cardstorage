import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = 'card_organizer.db';
  static const _databaseVersion = 1;

  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        previewImage TEXT,
        createdAt TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        suit TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        imageBytes TEXT,
        folderId INTEGER,
        createdAt TEXT NOT NULL,
        FOREIGN KEY(folderId) REFERENCES folders(id) ON DELETE CASCADE
      );
    ''');

    await _prepopulate(db);
  }

  Future<void> _prepopulate(Database db) async {
    final nowIso = DateTime.now().toIso8601String();
    final suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];

    for (final suit in suits) {
      await db.insert('folders', {
        'name': suit,
        'previewImage': null,
        'createdAt': nowIso,
      });
    }

    // Use a small set of sample images (public placeholder URLs)
    // In a real app, replace with proper card art URLs or local assets.
    final rankNames = [
      'Ace', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven',
      'Eight', 'Nine', 'Ten', 'Jack', 'Queen', 'King'
    ];

    for (final suit in suits) {
      for (var i = 0; i < rankNames.length; i++) {
        final name = '${rankNames[i]} of $suit';
        // Use a widely available static source; adjust if any URL 404s.
        final imageUrl = 'https://deckofcardsapi.com/static/img/${_rankCode(i)}${_suitCode(suit)}.png';
        await db.insert('cards', {
          'name': name,
          'suit': suit,
          'imageUrl': imageUrl,
          'imageBytes': null,
          'folderId': null, // unassigned by default
          'createdAt': nowIso,
        });
      }
    }
  }

  String _rankCode(int index) {
    // index 0..12 -> A,2,3,4,5,6,7,8,9,0,J,Q,K where 10 is represented by 0
    const codes = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'J', 'Q', 'K'];
    return codes[index];
  }

  String _suitCode(String suit) {
    switch (suit) {
      case 'Hearts':
        return 'H';
      case 'Spades':
        return 'S';
      case 'Diamonds':
        return 'D';
      case 'Clubs':
        return 'C';
      default:
        return 'S';
    }
  }
}


