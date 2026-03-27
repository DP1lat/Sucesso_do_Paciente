import 'package:flutter/material.dart';
import '../../data/database/db_helper.dart';

class GerenciarUsuariosScreen extends StatefulWidget {
  const GerenciarUsuariosScreen({super.key});

  @override
  State<GerenciarUsuariosScreen> createState() => _GerenciarUsuariosScreenState();
}

class _GerenciarUsuariosScreenState extends State<GerenciarUsuariosScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  String _cargoSelecionado = 'funcionário';

  void _cadastrar() async {
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha todos os campos!')));
      return;
    }

    final novoUsuario = {'login': _userController.text.trim().toLowerCase(), 'senha': _passController.text.trim(), 'cargo': _cargoSelecionado};

    try {
      await DbHelper.inserirUsuario(novoUsuario);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario cadastrado com sucesso!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(/*const SnackBar(content: Text('Erro: Este login já existe.*/SnackBar(content: Text('Erro Real: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Funcionários')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: 'Login/Usuário', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _cargoSelecionado,
              decoration: const InputDecoration(labelText: 'Nível de Acesso', border: OutlineInputBorder()),
              items: [
                DropdownMenuItem(value: 'admin', child: Text('Administrador (Acesso Total)')),
                DropdownMenuItem(value: 'funcionário', child: Text('Funcinário (Acesso Básico)')),
              ],
              onChanged: (value) => setState(() => _cargoSelecionado = value!),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _cadastrar,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Salvar novo Usuário'),
            ),
          ],
        ),
      ),
    );
  }
}
