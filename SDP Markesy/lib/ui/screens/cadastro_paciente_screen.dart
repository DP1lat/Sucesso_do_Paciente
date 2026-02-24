import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sdp_markesy/data/database/db_helper.dart';
import 'package:sdp_markesy/data/models/paciente_model.dart';
import 'avaliacao_sucesso_screen.dart';

class CadastroPacienteScreen extends StatefulWidget {
  const CadastroPacienteScreen({super.key});

  @override
  State<CadastroPacienteScreen> createState() => _CadastroPacienteScreenState();
}

class _CadastroPacienteScreenState extends State<CadastroPacienteScreen> {
  final _nomeController = TextEditingController();
  final _anoController = TextEditingController();
  final _telefoneController = TextEditingController();
  DateTime _dataSelecionada = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Cadastro de Paciente')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações do Paciente',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _anoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ano de Nascimento',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: TextField(
                    controller: _telefoneController,
                    decoration: const InputDecoration(
                      labelText: 'Telefone/WhatsApp',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ListTile(
              title: const Text('Data da Avaliação'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_dataSelecionada)),
              leading: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _dataSelecionada,
                  firstDate: DateTime(1960),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _dataSelecionada = picked);
              },
            ),

            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                final novoPaciente = Paciente(
                  nome: _nomeController.text,
                  anoNascimento: int.tryParse(_anoController.text) ?? 0,
                  telefone: _telefoneController.text,
                  dataAvaliacao: _dataSelecionada,
                );

                final idGerado = await DbHelper.inserirPaciente(novoPaciente.toMap());

                if(mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Paciente salvo com sucesso!')),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AvaliacaoSucessoScreen(pacienteId: idGerado)),
                  );
                }
                print('Paciente $idGerado salvo: ${_nomeController.text}');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Prosseguir para Avaliação de Sucesso'),
            ),
          ],
        ),
      ),
    );
  }
}
