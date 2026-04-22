import 'package:flutter/material.dart';
import 'package:sdp_markesy/data/database/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:sdp_markesy/main.dart';
import 'package:sdp_markesy/ui/screens/historico_paciente_screen.dart';
import 'package:sdp_markesy/utils/formatters.dart';

class AvaliacaoSucessoScreen extends StatefulWidget {
  final int pacienteId;
  final Map<String, dynamic>? dadosAntigos;

  const AvaliacaoSucessoScreen({super.key, required this.pacienteId, this.dadosAntigos});

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

  int _sessoesSelecionada = 1;
  int _parcelasSelecionada = 1;
  final List<int> _opcoesParcelas = List.generate(12, (index) => index + 1);

  String? _motivoSelecionado;
  final List<String> _opcoesMotivo = ['Preço / Valor', 'Horário incompatível', 'Distância / Localização', 'Vai pensar / Pesquisando', 'Problemas de Saúde / Internação', 'Outro'];

  String? _origemSelecionada;
  final List<String> _opcoesOrigem = ['Indicação de Terceiros', 'Pesquisa no Google', 'Instagram / Facebook', 'Passou na frente da clínica', 'Parceria / Convênio', 'Outro'];

  @override
  void initState() {
    super.initState();

    _profissionalController = TextEditingController(text: widget.dadosAntigos?['profissional'] ?? '');
    _obsController = TextEditingController(text: widget.dadosAntigos?['observacoes'] ?? '');

    double valorInicial = double.tryParse(widget.dadosAntigos?['valor'].toString() ?? '0.0') ?? 0.0;
    _valorController = TextEditingController(
      text: NumberFormat.currency(locale: 'pt_BR', symbol: '').format(valorInicial).trim(),
    );

    if (widget.dadosAntigos != null) {
      _fechouPacote = widget.dadosAntigos!['fechou_pacote'] == 1;

      String esp = widget.dadosAntigos!['especialidade'] ?? 'Fisioterapia';
      _especialidade = ['Fisioterapia', 'Nutrição', 'Psicologia'].contains(esp) ? esp : 'Fisioterapia';

      String fp = widget.dadosAntigos!['forma_pagamento'] ?? 'À vista';
      _formaPagamento = ['À vista', 'Parcelado'].contains(fp) ? fp : 'À vista';

      String tp = widget.dadosAntigos!['tipo_pagamento'] ?? 'Crédito';
      _tipoPagamento = ['Dinheiro', 'Crédito', 'Débito', 'Pix'].contains(tp) ? tp : 'Crédito';

      int sessoes = widget.dadosAntigos!['num_sessoes'] ?? 1;
      _sessoesSelecionada = (sessoes >= 1 && sessoes <= 10) ? sessoes : 1;

      int parcelas = widget.dadosAntigos!['num_parcelas'] ?? 2;
      _parcelasSelecionada = _opcoesParcelas.contains(parcelas) ? parcelas : 2;

      _motivoSelecionado = widget.dadosAntigos!['motivo_nao_fechamento'];

      String org = widget.dadosAntigos!['origem'] ?? 'Indicação de Terceiros';
      _origemSelecionada = _opcoesOrigem.contains(org) ? org : 'Indicação de Terceiros';
    }
  }

  @override
  void dispose() {
    _profissionalController.dispose();
    _obsController.dispose();
    _valorController.dispose();
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
            const Text('O Paciente fechou o Tratamento?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            SwitchListTile(
              title: Text(_fechouPacote ? 'Sim, pacote fechado!' : 'Não fechou, apenas Avaliação'),
              value: _fechouPacote,
              activeThumbColor: Colors.green,
              onChanged: (value) => setState(() => _fechouPacote = value),
            ),

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
                if (_fechouPacote) ...[
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _sessoesSelecionada,
                      decoration: const InputDecoration(labelText: 'Nº de sessões'),
                      items: List.generate(10, (i) => i + 1).map((e) {
                        return DropdownMenuItem(value: e, child: Text('$e sessões'));
                      }).toList(),
                      onChanged: (value) => setState(() => _sessoesSelecionada = value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],

                Expanded(
                  child: TextField(
                    controller: _valorController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, MoedaInputFormatter()],
                    decoration: InputDecoration(labelText: _fechouPacote ? 'Valor do Pacote (R\$)' : 'Valor da Avaliação (R\$)', border: const OutlineInputBorder()),
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
              initialValue: _tipoPagamento,
              decoration: const InputDecoration(labelText: 'Tipo de Pagamento'),
              items: ['Dinheiro', 'Crédito', 'Débito', 'Pix'].map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _tipoPagamento = value!;
                  if (_tipoPagamento != 'Crédito') {
                    _parcelasSelecionada = 1;
                  }
                });
              },
            ),
            if (_tipoPagamento == 'Crédito') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _parcelasSelecionada,
                decoration: const InputDecoration(labelText: 'Quantidade de parcelas', border: OutlineInputBorder(), prefixIcon: Icon(Icons.credit_card)),
                items: _opcoesParcelas.map((int value) {
                  return DropdownMenuItem<int>(value: value, child: Text(value == 1 ? '1x (Á vista no Crédito)' : 'Parcelado em $value vezes'));
                }).toList(),
                onChanged: (novoValor) => setState(() => _parcelasSelecionada == novoValor!),
              ),
            ],
            const Divider(height: 40),

            DropdownButtonFormField<String>(
              initialValue: _origemSelecionada,
              decoration: const InputDecoration(
                labelText: 'Como o paciente conheceu a clínica?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.share_location)
              ),
              items: _opcoesOrigem.map((e) {
                return DropdownMenuItem( value: e, child: Text(e));
              }).toList(),
              onChanged: (value) => setState(() => _origemSelecionada = value!),
            ),
            const SizedBox(height: 16),

            if (_formaPagamento == 'Parcelado') ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _parcelasSelecionada,
                decoration: const InputDecoration(labelText: 'Quantidade de parcelas ', border: OutlineInputBorder(), prefixIcon: Icon(Icons.credit_card)),
                items: _opcoesParcelas.map((int value) {
                  return DropdownMenuItem<int>(value: value, child: Text('Parcelado em $value vezes'));
                }).toList(),
                onChanged: (novoValor) => setState(() => _parcelasSelecionada = novoValor!),
              ),
            ],
            const SizedBox(height: 16),

            if (!_fechouPacote) ...[
              DropdownButtonFormField<String>(
                initialValue: _motivoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Motivo por não ter fechado o pacote', 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cancel_outlined, color: Colors.red)
                ),
                items: _opcoesMotivo.map((motivo) {
                  return DropdownMenuItem(value: motivo, child: Text(motivo));
                }).toList(),
                onChanged: (value) => setState(() => _motivoSelecionado = value),
              ),
              const SizedBox(height: 16),
            ],

            TextField(
              controller: _obsController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Observações Adicionais', border: OutlineInputBorder()),
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                if (!_fechouPacote && _motivoSelecionado == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecione um motivo para o não fechamento.')));
                  return;
                }

                String valorLimpo = _valorController.text.replaceAll('.', '').replaceAll(',', '.');
                double valorFinal = double.tryParse(valorLimpo) ?? 0.0;
                String dataCorretaAvaliacao;

                if (isEditing && widget.dadosAntigos != null) {
                  dataCorretaAvaliacao = widget.dadosAntigos!['data_avaliacao'] ?? DateTime.now().toIso8601String();
                } else {
                  final dadosPaciente = await DbHelper.buscarPacientePorId(widget.pacienteId);
                  dataCorretaAvaliacao = dadosPaciente['data_avaliacao'] ?? DateTime.now().toIso8601String();
                }

                String formaPagamentoFinal = (_tipoPagamento == 'Crédito' && _parcelasSelecionada > 1) ? 'Parcelado' : 'À vista';

                final novaAvaliacao = {
                  'paciente_id': widget.pacienteId,
                  'fechou_pacote': _fechouPacote ? 1 : 0,
                  'profissional': _profissionalController.text,
                  'especialidade': _especialidade,
                  'num_sessoes': _fechouPacote ? _sessoesSelecionada : 0,
                  'forma_pagamento': formaPagamentoFinal,
                  'num_parcelas': _formaPagamento == 'Parcelado' ? _parcelasSelecionada : 1,
                  'tipo_pagamento': _tipoPagamento,
                  'valor': valorFinal,
                  'data_avaliacao': dataCorretaAvaliacao,
                  'observacoes': _obsController.text,
                  'motivo_nao_fechamento': _fechouPacote ? null : _motivoSelecionado,
                  'origem': _origemSelecionada,
                };

                if (isEditing) {
                  await DbHelper.atualizarAvaliacao(widget.pacienteId, novaAvaliacao);
                } else {
                  await DbHelper.inserirAvaliacao(novaAvaliacao);

                  LocalNotification notificacao = LocalNotification(
                    title: 'Cadastro Finalizado!',
                    body: _fechouPacote ? 'Paciente fechou pacote com sucesso!' : 'Avaliação registrada. Paciente não fechou pacote.',
                  );

                  notificacao.onClick = () {
                    navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => const HistoricoPacienteScreen()));
                  };
                  notificacao.show();
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Avaliação atualizada!' : 'Dados registrados!')));
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
