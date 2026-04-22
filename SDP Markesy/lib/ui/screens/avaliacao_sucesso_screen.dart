import 'package:flutter/material.dart';
import 'package:sdp_markesy/data/database/db_helper.dart';
import 'package:sdp_markesy/ui/screens/home_screen.dart';
import 'package:sdp_markesy/utils/formatters.dart';

class AvaliacaoSucessoScreen extends StatefulWidget {
  final int pacienteId;
  final Map<String, dynamic>? dadosAntigos;

  const AvaliacaoSucessoScreen({super.key, required this.pacienteId, this.dadosAntigos});

  @override
  State<AvaliacaoSucessoScreen> createState() => _AvaliacaoSucessoScreenState();
}

class _AvaliacaoSucessoScreenState extends State<AvaliacaoSucessoScreen> {
  final Color primaryBlue = const Color(0xFF2441DE);

  bool _fechouPacote = false;
  bool _isLoading = false;

  String? _especialidade;
  String? _numSessoes = '1';
  final _valorController = TextEditingController(text: '0,00');
  final _profissionalController = TextEditingController();
  String? _tipoPagamento;
  String? _parcelas = '1';
  String? _origem;
  String? _motivoNaoFechamento;
  final _observacoesController = TextEditingController();

  final List<String> _especialidades = ['Fisioterapia', 'Pilates', 'RPG', 'Acupuntura', 'Osteopatia', 'Outro'];
  final List<String> _tiposPagamento = ['Dinheiro', 'Pix', 'Crédito', 'Débito', 'Boleto'];
  final List<String> _origens = ['Instagram', 'Indicação', 'Google', 'Fachada', 'Facebook', 'Outro'];
  final List<String> _motivos = ['Preço', 'Distância', 'Horário incompatível', 'Apenas pesquisa', 'Não gostou do método', 'Outro'];

  @override
  void initState() {
    super.initState();
    if (widget.dadosAntigos != null) {
      _fechouPacote = widget.dadosAntigos!['fechou_pacote'] == 1;
      _especialidade = widget.dadosAntigos!['especialidade'];
      _profissionalController.text = widget.dadosAntigos!['profissional'] ?? '';
      _tipoPagamento = widget.dadosAntigos!['tipo_pagamento'];
      _parcelas = widget.dadosAntigos!['num_parcelas']?.toString() ?? '1';
      _origem = widget.dadosAntigos!['origem'];
      _motivoNaoFechamento = widget.dadosAntigos!['motivo_nao_fechamento'];
      _observacoesController.text = widget.dadosAntigos!['observacoes'] ?? '';
      _numSessoes = widget.dadosAntigos!['num_sessoes']?.toString() ?? '1';

      if (widget.dadosAntigos!['valor'] != null) {
        double valor = widget.dadosAntigos!['valor'];
        _valorController.text = valor.toStringAsFixed(2).replaceAll('.', ',');
      }
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _profissionalController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _finalizarCadastro() async {
    if (!_fechouPacote && _motivoNaoFechamento == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecione o motivo de não ter fechado.')));
      return;
    }

    setState(() => _isLoading = true);

    double valorFinal = 0.0;
    try {
      String valorLimpo = _valorController.text.replaceAll('.', '').replaceAll(',', '.');
      valorFinal = double.parse(valorLimpo);
    } catch (_) {}

    final dadosAvaliacao = {
      'paciente_id': widget.pacienteId,
      'fechou_pacote': _fechouPacote ? 1 : 0,
      'especialidade': _especialidade,
      'num_sessoes': _fechouPacote ? int.tryParse(_numSessoes!) ?? 1 : 0,
      'valor': valorFinal,
      'profissional': _profissionalController.text.trim(),
      'tipo_pagamento': _tipoPagamento,
      'num_parcelas': int.tryParse(_parcelas!) ?? 1,
      'origem': _origem,
      'motivo_nao_fechamento': _fechouPacote ? null : _motivoNaoFechamento,
      'observacoes': _observacoesController.text.trim(),
    };

    await DbHelper.inserirAvaliacao(dadosAvaliacao);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paciente salvo com sucesso!')));
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- TOP BAR ---
                        Row(
                          children: [
                            Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ETAPA 2 DE 2', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryBlue, letterSpacing: 1.2)),
                                const SizedBox(height: 2),
                                const Text('Avaliação de Sucesso', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ],
                            )
                          ],
                        ),
                        
                        const SizedBox(height: 32),

                        // --- CARD 1: TOGGLE DE FECHAMENTO ---
                        _buildSectionCard(
                          icon: Icons.check_circle_outline,
                          iconColor: _fechouPacote ? Colors.green : primaryBlue,
                          title: 'O Paciente fechou o Tratamento?',
                          subtitle: 'Ative se o paciente fechou o pacote — campos adicionais serão exibidos.',
                          content: GestureDetector(
                            onTap: () => setState(() => _fechouPacote = !_fechouPacote),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: _fechouPacote ? Colors.white : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _fechouPacote ? primaryBlue : Colors.grey.shade300, width: _fechouPacote ? 1.5 : 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _fechouPacote ? 'Sim, pacote fechado!' : 'Não fechou, apenas Avaliação',
                                    style: TextStyle(fontWeight: FontWeight.w600, color: _fechouPacote ? Colors.black87 : Colors.grey.shade700),
                                  ),
                                  Switch(
                                    value: _fechouPacote,
                                    onChanged: (val) => setState(() => _fechouPacote = val),
                                    activeColor: primaryBlue,
                                    activeTrackColor: primaryBlue.withOpacity(0.2),
                                    inactiveThumbColor: Colors.grey.shade400,
                                    inactiveTrackColor: Colors.grey.shade300,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- CARD 2: DADOS DO ATENDIMENTO ---
                        _buildSectionCard(
                          icon: Icons.wallet_outlined,
                          iconColor: primaryBlue,
                          title: 'Dados do Atendimento',
                          subtitle: 'Especialidade, profissional e valores cobrados.',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Linha 1 (Muda dependendo se fechou)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdownField('Especialidade', Icons.medical_services_outlined, _especialidades, _especialidade, (val) => setState(() => _especialidade = val)),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _fechouPacote 
                                      ? _buildDropdownField('Nº de sessões', Icons.layers_outlined, List.generate(20, (i) => (i + 1).toString()), _numSessoes, (val) => setState(() => _numSessoes = val), suffix: 'sessão(ões)')
                                      : _buildTextField('Valor da Avaliação (R\$)', Icons.payments_outlined, _valorController, hint: '0,00', isCurrency: true),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              // Se fechou, o valor do pacote aparece aqui sozinho
                              if (_fechouPacote) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField('Valor do Pacote (R\$)', Icons.account_balance_wallet_outlined, _valorController, hint: '0,00', isCurrency: true),
                                    ),
                                    const SizedBox(width: 20),
                                    const Expanded(child: SizedBox()), // Espaço vazio para manter o layout como no print
                                  ],
                                ),
                                const SizedBox(height: 20),
                              ],

                              // Profissional
                              _buildTextField('Nome do Profissional', Icons.person_outline, _profissionalController, hint: 'Ex.: Aline'),
                              const SizedBox(height: 20),

                              // Linha Pagamento
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdownField('Tipo de Pagamento', Icons.credit_card_outlined, _tiposPagamento, _tipoPagamento, (val) => setState(() => _tipoPagamento = val)),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildDropdownField('Quantidade de parcelas', Icons.view_week_outlined, List.generate(12, (i) => (i + 1).toString()), _parcelas, (val) => setState(() => _parcelas = val), suffix: 'x'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- CARD 3: INFORMAÇÕES COMPLEMENTARES ---
                        _buildSectionCard(
                          icon: Icons.explore_outlined,
                          iconColor: primaryBlue,
                          title: 'Informações Complementares',
                          subtitle: 'Origem do paciente e observações da avaliação.',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDropdownField('Como o paciente conheceu a clínica?', Icons.explore_outlined, _origens, _origem, (val) => setState(() => _origem = val), hint: 'Selecione uma origem'),
                              
                              if (!_fechouPacote) ...[
                                const SizedBox(height: 20),
                                _buildDropdownField('Motivo por não ter fechado o pacote *', Icons.cancel_outlined, _motivos, _motivoNaoFechamento, (val) => setState(() => _motivoNaoFechamento = val), hint: 'Selecione um motivo', isRequired: true),
                              ],

                              const SizedBox(height: 20),
                              _buildLabel('Observações Adicionais', icon: Icons.description_outlined),
                              TextField(
                                controller: _observacoesController,
                                maxLines: 4,
                                decoration: _inputDecoration(hint: 'Anote informações relevantes da avaliação...'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // --- BOTTOM BAR FIXA ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Voltar', style: TextStyle(fontWeight: FontWeight.w600)),
                        style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _finalizarCadastro,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade400, // Tom de azul um pouco mais claro como no print
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.done_all, size: 20),
                                    SizedBox(width: 8),
                                    Text('Finalizar e Sincronizar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  ],
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGETS AUXILIARES
  // ===========================================================================

  Widget _buildSectionCard({required IconData icon, required Color iconColor, required String title, required String subtitle, required Widget content}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          content,
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {IconData? icon, bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: Colors.grey.shade600), const SizedBox(width: 6)],
          RichText(
            text: TextSpan(
              text: text,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontFamily: 'Segoe UI'),
              children: [
                if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
              ]
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {String? hint, bool isCurrency = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, icon: icon),
        TextField(
          controller: controller,
          keyboardType: isCurrency ? TextInputType.number : TextInputType.text,
          inputFormatters: isCurrency ? [MoedaInputFormatter()] : [],
          decoration: _inputDecoration(hint: hint),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, IconData icon, List<String> items, String? value, ValueChanged<String?> onChanged, {String? suffix, String? hint, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, icon: icon, isRequired: isRequired),
        DropdownButtonFormField<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          decoration: _inputDecoration(hint: hint),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(suffix != null ? '$item $suffix' : item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryBlue, width: 1.5)),
    );
  }
}