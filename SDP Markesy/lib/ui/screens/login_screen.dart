import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdp_markesy/data/database/db_helper.dart';
import '../../data/providers/auth_provider.dart';
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

class LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _tentarLogin() async {
    setState(() => _isLoading = true);

    final user = await DbHelper.verificarLogin(_userController.text, _passController.text);

    setState(() => _isLoading = false);

    if (user != null) {
      Sessao.usuario = user['login'];
      Sessao.cargo = user['cargo'];

      Navigator.pushReplacement(context, MaterialPageRouter(builder: (context) => const HomeScreen()));
    } else {
      const SnackBar(content: Text('Usuário ou senha incorretos!'), backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Markesý', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 30),
              TextField(
                controller: _userController,
                decoration: InputDecoration(labelText: 'Usuário', border: OutlineInputBorder()),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthProvider>().login(_userController.text, _passController.text);
                },
                child: Text('Entrar'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
