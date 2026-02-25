import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sdp_markesy/data/database/db_helper.dart';
// import 'package:sdp_markesy/data/models/paciente_model.dart';
import 'package:sdp_markesy/ui/screens/historico_paciente_screen.dart';
import 'avaliacao_sucesso_screen.dart';

class CadastroPacienteScreen extends StatefulWidget {
  final Map<String, dynamic>? pacienteParaEditar;

  const CadastroPacienteScreen({super.key, this.pacienteParaEditar});

  @override
  State<CadastroPacienteScreen> createState() => _CadastroPacienteScreenState();
}

class _CadastroPacienteScreenState extends State<CadastroPacienteScreen> {
  final _nomeController = TextEditingController();
  final _anoController = TextEditingController();
  final _telefoneController = TextEditingController();
  DateTime _dataSelecionada = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.pacienteParaEditar != null) {
      _nomeController.text = widget.pacienteParaEditar!['nome'] ?? '';
      _anoController.text =
          widget.pacienteParaEditar!['ano_nascimento']?.toString() ?? '';
      _telefoneController.text = widget.pacienteParaEditar!['telefone'] ?? '';

      if (widget.pacienteParaEditar!['data_avaliacao'] != null) {
        _dataSelecionada = DateTime.parse(
          widget.pacienteParaEditar!['data_avaliacao'],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.pacienteParaEditar != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Paciente' : 'Novo Cadastro'),
      ),
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
                final dadosPaciente = {
                  'nome': _nomeController.text,
                  'ano_nascimento': int.tryParse(_anoController.text) ?? 0,
                  'telefone': _telefoneController.text,
                  'data_avaliacao': _dataSelecionada.toIso8601String(),
                };

                if (isEditing) {
                  await DbHelper.atualizarPaciente(
                    widget.pacienteParaEditar!['id'],
                    dadosPaciente,
                  );
                  if (mounted) {
                    bool? editarFinanceiro = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Dados Básicos Salvos'),
                        content: const Text(
                          'Deseja editar também os valores e detalhes da avaliação?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Não'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Sim, Editar Tudo'),
                          ),
                        ],
                      ),
                    );

                    if (mounted) {
                      if (editarFinanceiro == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AvaliacaoSucessoScreen(
                              pacienteId: widget.pacienteParaEditar!['id'],
                              dadosAntigos: widget.pacienteParaEditar,
                            ),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    }
                  }
                } else {
                  final idNovo = await DbHelper.inserirPaciente(dadosPaciente);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Paciente Cadastrado')),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AvaliacaoSucessoScreen(pacienteId: idNovo),
                      ),
                    );
                  }
                }

              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
              child: Text(
                isEditing ? 'SALVAR ALTERAÇÕES' : 'PROSSEGUIR PARA AVALIAÇÃO',
              ),
            ),

            if (!isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistoricoPacienteScreen(),
                  ),
                ),
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('VER HISTÓRICO'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(color: Colors.blue[700]!, width: 2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
