import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import 'package:sdp_markesy/data/security/secure_auth.dart';
import 'package:sdp_markesy/data/services/realtime_service.dart';

class AuthProvider extends ChangeNotifier {
  Usuario? _usuarioLogado;

  Usuario? get usuario => _usuarioLogado;

  bool get podeAlterarFinanceiro => _usuarioLogado?.setor == Setor.recepcao || _usuarioLogado?.setor == Setor.admin;

  Future<bool> login(String user, String password) async {
    bool isAdmin = await SecureAuth.validarLoginAdmin(user, password);

    if (isAdmin) {
      _usuarioLogado = Usuario(login: user, senha: password, setor: Setor.admin);
      notifyListeners();
      RealtimeService.iniciarEscuta();
      return true;
    } else if (user == 'recepcao' && password == 'clinica') {
      _usuarioLogado = Usuario(login: user, senha: password, setor: Setor.recepcao);
      notifyListeners();
      RealtimeService.iniciarEscuta();
      return true;
    }

    return false;
  }

  void logout() {
    _usuarioLogado = null;
    notifyListeners();
    RealtimeService.pararEscuta();
  }
}
