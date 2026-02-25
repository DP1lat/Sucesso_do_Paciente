import 'package:flutter/material.dart';
import 'package:sdp_markesy/data/database/db_helper.dart';

class AvaliacaoSucessoScreen extends StatefulWidget {
  final int pacienteId;
  final Map<String, dynamic>? dadosAntigos;

  const AvaliacaoSucessoScreen({
    super.key,
    required this.pacienteId,
    this.dadosAntigos,
  });

  @override
  State<AvaliacaoSucessoScreen> createState() => _AvaliacaoSucessoScreenState();
}

class _AvaliacaoSucessoScreenState extends State<AvaliacaoSucessoScreen> {
  bool _fechouPacote = false;
  String _especialidade = 'Fisioterapia';
  String _formaPagamento = 'À vista';
  String _tipoPagamento = 'Crédito';

  late TextEditingController _profissionalController;
  late TextEditingController _obsController;
  late TextEditingController _valorController;
  late TextEditingController _sessoesController;

  @override
  void initState() {
    super.initState();
    
    _profissionalController = TextEditingController(text: widget.dadosAntigos?['profissional'] ?? '');
    _obsController = TextEditingController(text: widget.dadosAntigos?['observacoes'] ?? '');
    _valorController = TextEditingController(text: widget.dadosAntigos?['valor']?.toString() ?? '');
    _sessoesController = TextEditingController(text: widget.dadosAntigos?['num_sessoes']?.toString() ?? '');

    if (widget.dadosAntigos != null) {
      _fechouPacote = widget.dadosAntigos!['fechou_pacote'] == 1;
      _especialidade = widget.dadosAntigos!['especialidade'] ?? 'Fisioterapia';
      _formaPagamento = widget.dadosAntigos!['forma_pagamento'] ?? 'À vista';
      _tipoPagamento = widget.dadosAntigos!['tipo_pagamento'] ?? 'Crédito';
    }
  }

  @override
  void dispose() {
    _profissionalController.dispose();
    _obsController.dispose();
    _valorController.dispose();
    _sessoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.dadosAntigos != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Avaliação' : 'Avaliação de Sucesso')),
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
              title: Text(_fechouPacote ? 'Sim, pacote fechado!' : 'Não fechou ainda'),
              value: _fechouPacote,
              activeThumbColor: Colors.green,
              onChanged: (value) => setState(() => _fechouPacote = value),
            ),

            if (_fechouPacote) ...[
              const Divider(height: 40),
              DropdownButtonFormField<String>(
                value: _especialidade,
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
                      decoration: const InputDecoration(labelText: 'Nº de sessões', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _valorController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Valor total (R\$)', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _profissionalController,
                decoration: const InputDecoration(labelText: 'Nome do Profissional', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _tipoPagamento,
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
                decoration: const InputDecoration(labelText: 'Observações Adicionais', border: OutlineInputBorder()),
              ),

              const SizedBox(height: 16),
              const Text('Forma de Pagamento:'),
              Row(
                children: [
                  Radio<String>(
                    value: 'À vista',
                    groupValue: _formaPagamento,
                    onChanged: (value) => setState(() => _formaPagamento = value!),
                  ),
                  const Text('À vista'),
                  Radio<String>(
                    value: 'Parcelado',
                    groupValue: _formaPagamento,
                    onChanged: (value) => setState(() => _formaPagamento = value!),
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

                if (isEditing) {
                  // Lógica de Atualização
                  await DbHelper.atualizarAvaliacao(widget.pacienteId, novaAvaliacao);
                } else {
                  // Lógica de Inserção
                  await DbHelper.inserirAvaliacao(novaAvaliacao);
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'Avaliação atualizada!' : 'Dados registrados!')),
                  );
                  // Volta para o histórico
                  Navigator.popUntil(context, (route) => route.isFirst); 
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: Text(isEditing ? 'SALVAR ALTERAÇÕES' : 'FINALIZAR E SINCRONIZAR'),
            ),
          ],
        ),
      ),
    );
  }
}