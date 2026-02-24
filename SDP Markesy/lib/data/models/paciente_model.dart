class Paciente {
  final int? id;
  final String nome;
  final int anoNascimento;
  final String telefone;
  final DateTime dataAvaliacao;

  Paciente({
    this.id,
    required this.nome,
    required this.anoNascimento,
    required this.telefone,
    required this.dataAvaliacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'ano_nascimento': anoNascimento,
      'telefone': telefone,
      'data_avaliacao': dataAvaliacao.toIso8601String(),
    };
  }

  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      id: map['id'],
      nome: map['nome'],
      anoNascimento: map['ano_nascimento'],
      telefone: map['telefone'],
      dataAvaliacao: DateTime.parse(map['data_avaliacao']),
    );
  }
}
