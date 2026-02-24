import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase(); 
    return _db!;
  }

  static Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;

    String userPath = Platform.environment['USERPROFILE'] ?? '';
    String oneDrivePath = join(userPath, 'OneDrive', 'Documentos', 'ClinicaDados');

    Directory(oneDrivePath).createSync(recursive: true);
    
    String path = join(oneDrivePath, 'clinica_sucesso.db');

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE pacientes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT,
              ano_nascimento INTEGER,
              telefone TEXT,
              data_avaliacao TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE avaliacoes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              paciente_id INTEGER,
              fechou_pacote INTEGER,
              profissional TEXT,
              especialidade TEXT,
              num_sessoes INTEGER,
              forma_pagamento TEXT,
              tipo_pagamento TEXT,
              valor REAL,
              data_avaliacao TEXT,
              observacoes TEXT,
              FOREIGN KEY (paciente_id) REFERENCES pacientes (id)
            )
          ''');
        },
      ),
    );
  }

  static Future<int> inserirPaciente(Map<String, dynamic> dados) async {
    final db = await database; 
    return await db.insert('pacientes', dados);
  }

  static Future<int> inserirAvaliacao(Map<String, dynamic> dados) async {
    final db = await database;
    return await db.insert('avaliacoes', dados);
  }
}