import 'package:supabase_flutter/supabase_flutter.dart';

class DbHelper {
  static final _supabase = Supabase.instance.client;

  static Future<int> inserirPaciente(Map<String, dynamic> dadosPaciente) async {
    final resp = await _supabase.from('pacientes').insert(dadosPaciente).select('id').single();
    return resp['id'] as int;
  }

  static Future<void> atualizarPaciente(int id, Map<String, dynamic> dadosPaciente) async {
    await _supabase.from('pacientes').update(dadosPaciente).eq('id', id);
  }

  static Future<void> excluirPaciente(int id) async {
    await _supabase.from('avaliacoes').delete().eq('paciente_id', id);
    await _supabase.from('pacientes').delete().eq('id', id);
  }

  static Future<void> inserirAvaliacao(Map<String, dynamic> novaAvaliacao) async {
    await _supabase.from('avaliacoes').insert(novaAvaliacao);
  }

  static Future<void> atualizarAvaliacao(int pacienteId, Map<String, dynamic> novaAvaliacao) async {
    await _supabase.from('avaliacoes').update(novaAvaliacao).eq('paciente_id', pacienteId);
  }

  static Future<Map<String, dynamic>> buscarPacientePorId(int id) async {
    final resposta = await _supabase.from('pacientes').select().eq('id', id).single();
    return resposta;
  }

  static Future<List<Map<String, dynamic>>> buscarResumoPaciente(String ordem, {String filtro = '', int? mesFiltro}) async {
    var query = _supabase.from('pacientes').select(''' 
      *, 
      avaliacoes ( * )
    ''');

    if (filtro.isNotEmpty) {
      query = query.ilike('nome', '%$filtro%');
    }

    final List<dynamic> resposta = await query;

    List<Map<String, dynamic>> listaProcessada = resposta.map((item) {
      var mapPlano = Map<String, dynamic>.from(item);

      var listaAvaliacoes = item['avaliacoes'] as List<dynamic>?;
      if (listaAvaliacoes != null && listaAvaliacoes.isNotEmpty) {
        var avaliacao = listaAvaliacoes[0];

        mapPlano['fechou_pacote'] = avaliacao['fechou_pacote'];
        mapPlano['data_avaliacao'] = avaliacao['data_avaliacao'];
        mapPlano['profissional'] = avaliacao['profissional'];
        mapPlano['especialidade'] = avaliacao['especialidade'];
        mapPlano['valor'] = avaliacao['valor'];
        mapPlano['observacoes'] = avaliacao['observacoes'];
        mapPlano['num_sessoes'] = avaliacao['num_sessoes'];
        mapPlano['forma_pagamento'] = avaliacao['forma_pagamento'];
        mapPlano['tipo_pagamento'] = avaliacao['tipo_pagamento'];
        mapPlano['num_parcelas'] = avaliacao['num_parcelas'];
      }
      mapPlano.remove('avaliacoes');
      return mapPlano;
    }).toList();

    if (mesFiltro != null) {
      listaProcessada = listaProcessada.where((item) {
        if (item['data_avaliacao'] == null) return false;
        try {
          DateTime data = DateTime.parse(item['data_avaliacao'].toString());
          return data.month == mesFiltro;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    if (ordem == 'nome ASC') {
      listaProcessada.sort((a, b) => (a['nome'] ?? '').toString().compareTo((b['nome'] ?? '').toString()));
    } else if (ordem == 'valor DESC') {
      listaProcessada.sort((a, b) => (b['valor'] ?? 0.0).compareTo(a['valor'] ?? 0.0));
    } else { 
      listaProcessada.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
    }

    return listaProcessada;
  }

  static Future<Map<String, dynamic>?> verificarLogin(String usuario, String senha) async {
    final resposta = await _supabase.from('usuarios').select().eq('login', usuario).eq('senha', senha).maybeSingle();

    return resposta;
  }

  static Future<void> inserirUsuario(Map<String, dynamic> dadosUsuario) async {
    await _supabase.from('usuarios').insert(dadosUsuario);
  }

  static Future<List<Map<String, dynamic>>> buscarUsuarios() async {
    final List<dynamic> resposta = await _supabase.from('usuarios').select();
    return List<Map<String, dynamic>>.from(resposta);
  }

  static Future<void> excluirUsuario(int id) async {
    await _supabase.from('usuarios').delete().eq('id', id);
  }
}
