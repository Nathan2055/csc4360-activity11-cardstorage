import 'package:cw11/data/database_helper.dart';
import 'package:cw11/models/playing_card.dart';

class CardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<PlayingCard>> getAllCards() async {
    final db = await _dbHelper.database;
    final result = await db.query('cards', orderBy: 'id ASC');
    return result.map((e) => PlayingCard.fromMap(e)).toList();
  }

  Future<List<PlayingCard>> getCardsByFolder(int folderId) async {
    final db = await _dbHelper.database;
    final result = await db.query('cards', where: 'folderId = ?', whereArgs: [folderId], orderBy: 'id ASC');
    return result.map((e) => PlayingCard.fromMap(e)).toList();
  }

  Future<List<PlayingCard>> getUnassignedCards() async {
    final db = await _dbHelper.database;
    final result = await db.query('cards', where: 'folderId IS NULL', orderBy: 'id ASC');
    return result.map((e) => PlayingCard.fromMap(e)).toList();
  }

  Future<int> insertCard(PlayingCard card) async {
    final db = await _dbHelper.database;
    return await db.insert('cards', card.toMap());
  }

  Future<int> updateCard(PlayingCard card) async {
    if (card.id == null) return 0;
    final db = await _dbHelper.database;
    return await db.update('cards', card.toMap(), where: 'id = ?', whereArgs: [card.id]);
  }

  Future<int> deleteCard(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }
}


