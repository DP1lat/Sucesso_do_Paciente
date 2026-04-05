import 'package:flutter/material.dart';
import 'package:sdp_markesy/data/database/db_helper.dart';
import 'package:sdp_markesy/data/services/realtime_service.dart';
import 'package:sdp_markesy/main.dart';

class Sessao {
  static String? usuario;
  static String? cargo;
  static bool get isAdmin => cargo == 'admin';
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _tentarLogin() async {
    String loginDigitado = _userController.text.trim();
    String senhaDigitada = _passController.text.trim();

    if (loginDigitado.isEmpty || senhaDigitada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, preencha todos os campos.')));
      return;
    }

    setState(() => _isLoading = true);

    final user = await DbHelper.verificarLogin(loginDigitado, senhaDigitada);

    setState(() => _isLoading = false);

    if (user != null) {
      Sessao.usuario = user['login'];
      Sessao.cargo = user['cargo'];

      RealtimeService.iniciarEscuta();

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário ou senha incorretos!'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_hospital, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text('Sucesso do Paciente', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(
                controller: _userController,
                decoration: const InputDecoration(labelText: 'Usuário', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _tentarLogin,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      child: const Text('ENTRAR'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
