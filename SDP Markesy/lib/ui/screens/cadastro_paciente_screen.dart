import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sdp_markesy/data/database/db_helper.dart';
import 'package:sdp_markesy/ui/screens/avaliacao_sucesso_screen.dart';
import 'package:sdp_markesy/ui/screens/historico_paciente_screen.dart';

class DataInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset < oldValue.selection.baseOffset) {
      return newValue;
    }
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 8) text = text.substring(0, 8);
    
    var formatted = '';
    for (var i = 0; i < text.length; i++) {
      formatted += text[i];
      if ((i == 1 || i == 3) && i != text.length - 1) {
        formatted += '/';
      }
    }
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CadastroPacienteScreen extends StatefulWidget {
  final Map<String, dynamic>? pacienteParaEditar;
  const CadastroPacienteScreen({super.key, this.pacienteParaEditar});

  @override
  State<CadastroPacienteScreen> createState() => _CadastroPacienteScreenState();
}

class _CadastroPacienteScreenState extends State<CadastroPacienteScreen> {
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _dataAvaliacaoController = TextEditingController();
  
  bool _isLoading = false;
  DateTime _dataSelecionada = DateTime.now();
  final Color primaryBlue = const Color(0xFF2441DE);

  @override
  void initState() {
    super.initState();
    _dataAvaliacaoController.text = DateFormat('dd/MM/yyyy').format(_dataSelecionada);

    if (widget.pacienteParaEditar != null) {
      _nomeController.text = widget.pacienteParaEditar!['nome'] ?? '';
      _telefoneController.text = widget.pacienteParaEditar!['telefone'] ?? '';
      _dataNascimentoController.text = widget.pacienteParaEditar!['data_nascimento'] ?? '';
      
      if (widget.pacienteParaEditar!['data_avaliacao'] != null) {
        try {
          _dataSelecionada = DateTime.parse(widget.pacienteParaEditar!['data_avaliacao']);
          _dataAvaliacaoController.text = DateFormat('dd/MM/yyyy').format(_dataSelecionada);
        } catch (e) {
          _dataAvaliacaoController.text = widget.pacienteParaEditar!['data_avaliacao'];
        }
      }
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
        _dataAvaliacaoController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _dataNascimentoController.dispose();
    _dataAvaliacaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarEAvancar() async {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o nome do paciente.')));
      return;
    }
    setState(() => _isLoading = true);
    final dadosPaciente = {
      'nome': _nomeController.text.trim(),
      'telefone': _telefoneController.text.trim(),
      'data_nascimento': _dataNascimentoController.text.trim(),
      'data_avaliacao': _dataSelecionada.toIso8601String(), 
    };

    int pacienteId;
    if (widget.pacienteParaEditar != null) {
      pacienteId = widget.pacienteParaEditar!['id'];
      await DbHelper.atualizarPaciente(pacienteId, dadosPaciente);
    } else {
      pacienteId = await DbHelper.inserirPaciente(dadosPaciente);
    }

    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AvaliacaoSucessoScreen(
            pacienteId: pacienteId,
            dadosAntigos: widget.pacienteParaEditar,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.pacienteParaEditar != null;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          Text(isEditing ? 'EDIÇÃO' : 'ETAPA 1 DE 2', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryBlue, letterSpacing: 1.2)),
                          const SizedBox(height: 2),
                          Text(isEditing ? 'Editar Cadastro' : 'Novo Cadastro', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: primaryBlue.withValues(alpha:0.1), borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.person, color: primaryBlue, size: 20),
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Informações do Paciente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                Text('Preencha os dados básicos.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildLabel('Nome Completo'),
                        TextField(controller: _nomeController, decoration: _inputDecoration(hint: 'Ex.: Maria da Silva')),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Data de Nascimento', icon: Icons.cake_outlined),
                                  TextField(
                                    controller: _dataNascimentoController,
                                    inputFormatters: [DataInputFormatter()],
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration(hint: 'DD/MM/AAAA'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Telefone / WhatsApp', icon: Icons.phone_outlined),
                                  TextField(controller: _telefoneController, decoration: _inputDecoration(hint: '(11) 90000-0000'), keyboardType: TextInputType.phone),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildLabel('Data da Avaliação', icon: Icons.calendar_today),
                        GestureDetector(
                          onTap: () => _selecionarData(context),
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _dataAvaliacaoController,
                              decoration: _inputDecoration(hint: 'Selecionar data').copyWith(
                                suffixIcon: Icon(Icons.edit_calendar, color: primaryBlue, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => const HistoricoPacienteScreen())),
                        icon: const Icon(Icons.history, size: 18),
                        label: const Text('Ver histórico'),
                        style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
                      ),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _salvarEAvancar,
                          style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: _isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Row(children: [Text('Prosseguir'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 18)]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: Colors.grey.shade600), const SizedBox(width: 6)],
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
      ]),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryBlue, width: 1.5)),
    );
  }
}