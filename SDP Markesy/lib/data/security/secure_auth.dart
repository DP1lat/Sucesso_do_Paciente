import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureAuth {
  static const _storage = FlutterSecureStorage();

  static const _keyUser = 'admin_markesy_user';
  static const _keyPass = 'admin_markesy_pass';

  static Future<bool> isPrimeiroAcesso() async {
    String? adminSalvo = await _storage.read(key: _keyUser);
    return adminSalvo == null;
  }

  static Future<void> registrarAdmin(String usuario, String senha) async {
    await _storage.write(key: _keyUser, value: usuario);
    await _storage.write(key: _keyPass, value: senha);
  }

  // static Future<void> inicializarAdminGeral() async {
  //   String? adminSalvo = await _storage.read(key: _keyUser);

  //   if (adminSalvo == null) {
  //     await _storage.write(key: _keyUser, value: 'admin');
  //     await _storage.write(key: _keyPass, value: '1234512345');
  //   }
  // }

  static Future<bool> validarLoginAdmin(String usuarioDigitado, String senhaDigitada) async {
    String? userCriptografado = await _storage.read(key: _keyUser);
    String? passCriptografado = await _storage.read(key: _keyPass);

    if (userCriptografado == null || passCriptografado == null) return false;

    return usuarioDigitado == userCriptografado && senhaDigitada == passCriptografado;
  }
}
