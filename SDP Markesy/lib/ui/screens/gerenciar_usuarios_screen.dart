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
  String _cargoSelecionado = 'funcionario';

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro: Este login já existe.'), backgroundColor: Colors.red));
    }

    setState(() {});
    _userController.clear();
    _passController.clear();
  }

  void _confirmarExclusao(int id, String login) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir o usuário "$login"?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                await DbHelper.excluirUsuario(id);
                if (mounted) {
                  Navigator.of(context).pop();
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário excluído!'), backgroundColor: Colors.red));
                }
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Funcionários')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                TextField(
                  controller: _userController,
                  decoration: const InputDecoration(labelText: 'Login'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passController,
                  decoration: const InputDecoration(labelText: 'Senha'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _cargoSelecionado,
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'funcionario', child: Text('Funcionário')),
                  ],
                  onChanged: (v) => setState(() => _cargoSelecionado = v!),
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _cadastrar, child: const Text('SALVAR NOVO USUÁRIO')),
              ],
            ),
          ),
          const Divider(),
          const Text('Usuários Ativos', style: TextStyle(fontWeight: FontWeight.bold)),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DbHelper.buscarUsuarios(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final usuarios = snapshot.data!;
                return ListView.separated(
                  itemCount: usuarios.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: Colors.black12, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final u = usuarios[index];
                    return ListTile(
                      leading: Icon(u['cargo'] == 'admin' ? Icons.verified_user : Icons.person),
                      title: Text(u['login']),
                      subtitle: Text('Cargo: ${u['cargo']}'),
                      trailing: u['login'] == 'admin'
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmarExclusao(u['id'], u['login']),
                            ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
