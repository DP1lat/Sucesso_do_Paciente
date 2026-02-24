import 'package:flutter/material.dart';
import 'package:sdp_markesy/data/database/db_helper.dart';

class AvaliacaoSucessoScreen extends StatefulWidget {
  final int pacienteId;

  const AvaliacaoSucessoScreen({super.key, required this.pacienteId});

  @override
  State<AvaliacaoSucessoScreen> createState() => _AvaliacaoSucessoScreenState();
}

class _AvaliacaoSucessoScreenState extends State<AvaliacaoSucessoScreen> {
  bool _fechouPacote = false;
  String _especialidade = 'Fisioterapia';
  String _formaPagamento = 'À vista';
  String _tipoPagamento = 'Crédito';
  final _profissionalController = TextEditingController();
  final _obsController = TextEditingController();
  final _valorController = TextEditingController();
  final _sessoesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliação de Sucesso')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'O Paciente fechou o Tratamento?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            SwitchListTile(
              title: Text(
                _fechouPacote ? 'Sim, pacote fechado!' : 'Não fechou ainda',
              ),
              value: _fechouPacote,
              activeThumbColor: Colors.green,
              onChanged: (value) => setState(() => _fechouPacote = value),
            ),

            if (_fechouPacote) ...[
              const Divider(height: 40),
              DropdownButtonFormField<String>(
                initialValue: _especialidade,
                decoration: const InputDecoration(labelText: 'Especialidade'),
                items: ['Fisioterapia', 'Nutrição', 'Psicologia'].map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (value) => setState(() => _especialidade = value!),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _sessoesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nº de sessões',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _valorController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Valor total (R\$)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _profissionalController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Profissional',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _tipoPagamento,
                decoration: const InputDecoration(labelText: 'Tipo de Pagamento'),
                items: ['Dinheiro', 'Crédito', 'Débito', 'Pix'].map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (value) => setState(() => _tipoPagamento = value!),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _obsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações Adicionais',
                  border: OutlineInputBorder(),
                ),
              ),

              const Text('Forma de Pagamento:'),

              Row(
                children: [
                  Radio<String>(
                    value: 'À vista',
                    groupValue: _formaPagamento,
                    onChanged: (value) =>
                        setState(() => _formaPagamento = value!),
                  ),
                  const Text('À vista'),
                  Radio<String>(
                    value: 'Parcelado',
                    groupValue: _formaPagamento,
                    onChanged: (value) =>
                        setState(() => _formaPagamento = value!),
                  ),
                  const Text('Parcelado'),
                ],
              ),
            ],

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                final novaAvaliacao = {
                  'paciente_id': widget.pacienteId,
                  'fechou_pacote': _fechouPacote ? 1 : 0,
                  'profissional': _profissionalController.text,
                  'especialidade': _especialidade,
                  'num_sessoes': int.tryParse(_sessoesController.text) ?? 0,
                  'forma_pagamento': _formaPagamento,
                  'tipo_pagamento': _tipoPagamento,
                  'valor': double.tryParse(_valorController.text) ?? 0.0,
                  'data_avaliacao': DateTime.now().toIso8601String(),
                  'observacoes': _obsController.text,
                };

                await DbHelper.inserirAvaliacao(novaAvaliacao);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dados de sucesso registrados!'),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Finalizar e Sincronizar'),
            ),
          ],
        ),
      ),
    );
  }
}
