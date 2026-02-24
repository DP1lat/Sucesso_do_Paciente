class AvaliacaoSucesso {
  final int? id;
  final int pacienteId;
  final bool fechouPacote;
  final String profissional;
  final String especialidade;
  final int numSessoes;
  final String formaPagamento;
  final String tipoPagamento;
  final double valor;
  final DateTime dataAvaliacao;
  final String observacoes;

  AvaliacaoSucesso({
    this.id,
    required this.pacienteId,
    required this.fechouPacote,
    required this.profissional,
    required this.especialidade,
    required this.numSessoes,
    required this.formaPagamento,
    required this.tipoPagamento,
    required this.valor,
    required this.dataAvaliacao,
    required this.observacoes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'paciente_id': pacienteId,
      'fechou_pacote': fechouPacote ? 1 : 0,
      'profissional': profissional,
      'especialidade': especialidade,
      'num_sessoes': numSessoes,
      'forma_pagamento': formaPagamento,
      'tipo_pagamento': tipoPagamento,
      'valor': valor,
      'data_avaliacao': dataAvaliacao.toIso8601String(),
      'observacoes': observacoes,
    };
  }

  factory AvaliacaoSucesso.fromMap(Map<String, dynamic> map) {
    return AvaliacaoSucesso(
      id: map['id'],
      pacienteId: map['paciente_id'],
      fechouPacote: map['fechou_pacote'] == 1,
      profissional: map['profissional'],
      especialidade: map['especialidade'],
      numSessoes: map['num_sessoes'],
      formaPagamento: map['forma_pagamento'],
      tipoPagamento: map['tipo_pagamento'],
      valor: map['valor'],
      dataAvaliacao: map['data_avaliacao'],
      observacoes: map['observacoes'],
    );
  }
}
