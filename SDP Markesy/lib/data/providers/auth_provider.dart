import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import 'package:sdp_markesy/data/security/secure_auth.dart';

class AuthProvider extends ChangeNotifier {
  Usuario? _usuarioLogado;

  Usuario? get usuario => _usuarioLogado;

  bool get podeAlterarFinanceiro => _usuarioLogado?.setor == Setor.recepcao || _usuarioLogado?.setor == Setor.admin;

  Future<bool> login(String user, String password) async {
    bool isAdmin = await SecureAuth.validarLoginAdmin(user, password);

    if (isAdmin) {
      _usuarioLogado = Usuario(login: user, senha: password, setor: Setor.admin);
      notifyListeners();
      return true;
    } else if (user == 'recepcao' && password == 'clinica') {
      _usuarioLogado = Usuario(login: user, senha: password, setor: Setor.recepcao);
      notifyListeners();
      return true;
    }

    return false;
  }

  void logout() {
    _usuarioLogado = null;
    notifyListeners();
  }
}
