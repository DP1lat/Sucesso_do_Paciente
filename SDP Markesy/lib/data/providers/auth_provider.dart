import 'package:flutter/material.dart';
import '../models/usuario_model.dart';

class AuthProvider extends ChangeNotifier {
  Usuario? _usuarioLogado;

  Usuario? get usuario => _usuarioLogado;

  bool get podeAlterarFinanceiro =>
      _usuarioLogado?.setor == Setor.recepcao ||
      _usuarioLogado?.setor == Setor.admin;

  void login(String user, String password) {
    if (user == 'admin' && password == '123') {
      _usuarioLogado = Usuario(
        login: user,
        senha: password,
        setor: Setor.admin,
      );
    } else if (user == 'recepcao' && password == 'clinica') {
      _usuarioLogado = Usuario(
        login: user,
        senha: password,
        setor: Setor.recepcao,
      );
    }

    notifyListeners();
  }

  void logout() {
    _usuarioLogado = null;
    notifyListeners();
  }
}
