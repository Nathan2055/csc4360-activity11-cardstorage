import 'package:cw11/data/database_helper.dart';
import 'package:cw11/models/folder.dart';
import 'package:sqflite/sqflite.dart';

class FolderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Folder>> getAllFolders() async {
    final db = await _dbHelper.database;
    final result = await db.query('folders', orderBy: 'id ASC');
    return result.map((e) => Folder.fromMap(e)).toList();
  }

  Future<Folder?> getFolder(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query('folders', where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isEmpty) return null;
    return Folder.fromMap(result.first);
  }

  Future<int> insertFolder(Folder folder) async {
    final db = await _dbHelper.database;
    return await db.insert('folders', folder.toMap());
  }

  Future<int> updateFolder(Folder folder) async {
    if (folder.id == null) return 0;
    final db = await _dbHelper.database;
    return await db.update('folders', folder.toMap(), where: 'id = ?', whereArgs: [folder.id]);
  }

  Future<int> deleteFolder(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countCardsInFolder(int folderId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM cards WHERE folderId = ?', [folderId]);
    return (result.first['cnt'] as int?) ?? 0;
  }

  Future<void> updatePreviewImageFromFirstCard(int folderId) async {
    final db = await _dbHelper.database;
    final firstCard = await db.query(
      'cards',
      where: 'folderId = ?',
      whereArgs: [folderId],
      orderBy: 'id ASC',
      limit: 1,
    );
    final preview = firstCard.isNotEmpty ? (firstCard.first['imageUrl'] as String?) : null;
    await db.update('folders', {'previewImage': preview}, where: 'id = ?', whereArgs: [folderId]);
  }
}


