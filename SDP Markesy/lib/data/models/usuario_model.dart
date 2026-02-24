enum Setor { recepcao, especialista, admin }

class Usuario {
  final String login;
  final String senha;
  final Setor setor;

  Usuario({required this.login, required this.senha, required this.setor});
}
