import 'package:sqflite/sqflite.dart';

import '../user/user_model.dart';

class SQLiteService {
  final Database db;

  SQLiteService(this.db);

  Future<void> insertUserInSQLite(User user) async {
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<User>> getAllUsersFromSQLite() async {
    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (index) {
      return User(
        id: maps[index]['id'],
        nickname: maps[index]['nickname'],
        photoUrl: maps[index]['photoUrl'],
      );
    });
  }

  Future<void> updateUserInSQLite(User user) async {
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUserFromSQLite(String userId) async {
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
