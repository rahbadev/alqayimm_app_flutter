import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    // احصل على مسار مجلد التطبيق
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = '${documentsDir.path}/app_main.db';

    // إذا لم تكن القاعدة موجودة، انسخها من assets
    if (!await File(dbPath).exists()) {
      ByteData data = await rootBundle.load('assets/db/app_main.db');
      List<int> bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    _db = await openDatabase(dbPath);
    return _db!;
  }
}
