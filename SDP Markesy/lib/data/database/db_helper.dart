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
              data_nascimento TEXT,
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

  static Future<List<Map<String, dynamic>>> buscarResumoPaciente(String ordem, {String filtro = ''}) async {
    final db = await database;
    String ordemCorrigida = ordem.contains('id') && !ordem.contains('p.') ? ordem.replaceAll('id', 'p.id') : ordem;

    String query =
        '''
      SELECT 
        p.id, p.nome, p.data_avaliacao, p.data_nascimento, p.telefone,
        a.fechou_pacote, a.profissional, a.especialidade, a.valor,
        a.tipo_pagamento, a.forma_pagamento, a.num_sessoes, a.observacoes
      FROM pacientes p
      LEFT JOIN avaliacoes a ON p.id = a.paciente_id
      WHERE p.nome LIKE ?
      ORDER BY $ordemCorrigida
    ''';

    return await db.rawQuery(query, ['%$filtro%']);
  }

  static Future<void> excluirPaciente(int id) async {
    final db = await database;
    await db.delete('pacientes', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> atualizarPaciente(int id, Map<String, dynamic> dados) async {
    final db = await database;
    await db.update('pacientes', dados, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> atualizarAvaliacao(int pacienteId, Map<String, dynamic> dados) async {
    final db = await database;
    await db.update('avaliacoes', dados, where: 'paciente_id = ?', whereArgs: [pacienteId]);
  }
}
