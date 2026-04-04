import 'package:flutter/material.dart';
import 'package:sdp_markesy/data/security/secure_auth.dart';
import 'package:sdp_markesy/ui/screens/login_screen.dart';

class PrimeiroAcessoScreen extends StatefulWidget {
  const PrimeiroAcessoScreen({super.key});

  @override
  State<PrimeiroAcessoScreen> createState() => _PrimeiroAcessoScreenState();
}

class _PrimeiroAcessoScreenState extends State<PrimeiroAcessoScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  void _configurarSistema() async {
    String user = _userController.text.trim();
    String pass = _passController.text.trim();
    String confirmPass = _confirmPassController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha todos os campos!')));
      return;
    }

    if (pass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('As senhas não coincidem!'), backgroundColor: Colors.red));
      return;
    }

    await SecureAuth.registrarAdmin(user, pass);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Administrador Criado com sucesso!'), backgroundColor: Colors.green));

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
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
              const Icon(Icons.security, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              const Text('Bem-Vindo a Markesý!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Como é o seu primeiro acesso, crie a conta de Administrador no Sistema.', textAlign: TextAlign.center),
              const SizedBox(height: 40),

              TextField(
                controller: _userController,
                decoration: const InputDecoration(labelText: 'Nome de usuário'),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Crie sua senha"),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _confirmPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Confirme sua senha"),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _configurarSistema,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.orange, foregroundColor: Colors.white),
                child: const Text('SALVAR CREDENCIAIS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
