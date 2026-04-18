import 'package:flutter/material.dart';
import 'package:sdp_markesy/ui/screens/cadastro_paciente_screen.dart';
import 'package:sdp_markesy/ui/screens/login_screen.dart';
import '../../data/database/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:sdp_markesy/data/services/pdf_services.dart';

class HistoricoPacienteScreen extends StatefulWidget {
  const HistoricoPacienteScreen({super.key});

  @override
  State<HistoricoPacienteScreen> createState() => _HistoricoPacienteScreenState();
}

class _HistoricoPacienteScreenState extends State<HistoricoPacienteScreen> {
  Key _refreshKey = UniqueKey();
  String _criterioOrdenacao = 'p.id DESC';
  final _searchController = TextEditingController();
  String _filtroNome = '';
  
  int? _mesFiltro;
  final List<String> _nomesMeses = ['Todos', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];

  int? _statusFiltro; 

  int _paginaAtual = 1;
  final int _itensPorPagina = 10;

  void _confirmarExclusao(BuildContext context, int id, String nome) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Registro'),
        content: Text('Tem certeza que deseja apagar os dados de $nome?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await DbHelper.excluirPaciente(id);
              if (mounted) {
                Navigator.pop(ctx);
                setState(() {
                  _refreshKey = UniqueKey();
                  _paginaAtual = 1; 
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro removido com sucesso!')));
              }
            },
            child: const Text('EXCLUIR AGORA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Histórico da Clínica', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf_outlined, color: Colors.red.shade400),
            tooltip: 'Gerar Relatório Geral',
            onPressed: () async {
              final lista = await DbHelper.buscarResumoPaciente(_criterioOrdenacao, filtro: _filtroNome, mesFiltro: _mesFiltro);
              final listaFiltrada = lista.where((item) {
                if (_statusFiltro == null) return true;
                return item['fechou_pacote'] == _statusFiltro;
              }).toList();
              
              await PdfServices.gerarRelatorioPacientes(listaFiltrada);
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.black54),
            tooltip: 'Ordenar por',
            onSelected: (String novoCriterio) {
              setState(() {
                _criterioOrdenacao = novoCriterio;
                _paginaAtual = 1; 
                _refreshKey = UniqueKey();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'p.id DESC', child: Text('Mais recentes')),
              const PopupMenuItem<String>(value: 'nome ASC', child: Text('Nome (A-Z)')),
              const PopupMenuItem<String>(value: 'valor DESC', child: Text('Maior Valor')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Pesquisar paciente por nome...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryBlue)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _filtroNome = '';
                                    _paginaAtual = 1; 
                                    _refreshKey = UniqueKey();
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filtroNome = value;
                          _paginaAtual = 1; 
                          _refreshKey = UniqueKey();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 40,
                    child: DropdownButtonFormField<int?>(
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                      initialValue: _mesFiltro,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Todos os Meses')),
                        ...List.generate(12, (index) => DropdownMenuItem(value: index + 1, child: Text(_nomesMeses[index + 1])))
                      ],
                      onChanged: (val) {
                        setState(() {
                          _mesFiltro = val;
                          _paginaAtual = 1; 
                          _refreshKey = UniqueKey();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 40,
                    child: DropdownButtonFormField<int?>(
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                      initialValue: _statusFiltro,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Todos os Status')),
                        DropdownMenuItem(value: 1, child: Text('Fecharam Pacote')),
                        DropdownMenuItem(value: 0, child: Text('Apenas Avaliação')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _statusFiltro = val;
                          _paginaAtual = 1; 
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              key: _refreshKey,
              future: DbHelper.buscarResumoPaciente(_criterioOrdenacao, filtro: _filtroNome, mesFiltro: _mesFiltro),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));

                final listaDoBanco = snapshot.data ?? [];
                final listaFiltrada = listaDoBanco.where((item) {
                  if (_statusFiltro == null) return true;
                  return item['fechou_pacote'] == _statusFiltro;
                }).toList();
                
                final int totalPaginas = (listaFiltrada.length / _itensPorPagina).ceil();
                if (_paginaAtual > totalPaginas && totalPaginas > 0) _paginaAtual = totalPaginas;

                final int startIndex = (_paginaAtual - 1) * _itensPorPagina;
                final listaPaginada = listaFiltrada.skip(startIndex).take(_itensPorPagina).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Text(
                        '${listaFiltrada.length} paciente(s) encontrado(s)', 
                        style: TextStyle(fontWeight: FontWeight.w600, color: primaryBlue, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (listaFiltrada.isEmpty)
                      Expanded(child: Center(child: Text('Nenhum paciente encontrado para este filtro.', style: TextStyle(color: Colors.grey.shade600))))
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: listaPaginada.length, 
                          itemBuilder: (context, index) {
                            final item = listaPaginada[index];
                            bool fechou = item['fechou_pacote'] == 1;

                            final tipoPag = item['tipo_pagamento']?.toString() ?? '';
                            final formaPag = item['forma_pagamento']?.toString() ?? '';
                            final parcelas = item['num_parcelas']?.toString() ?? '';

                            String textoPagamento = '';
                            if (tipoPag.isNotEmpty && tipoPag != 'null') textoPagamento += tipoPag;
                            if (formaPag.isNotEmpty && formaPag != 'null') textoPagamento += (textoPagamento.isNotEmpty ? ' - ' : '') + formaPag;
                            if (parcelas.isNotEmpty && parcelas != '0' && parcelas != '1' && parcelas != 'null') textoPagamento += ' (${parcelas}x)';
                            if (textoPagamento.trim().isEmpty) textoPagamento = 'Não informado';

                            return Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: ExpansionTile(
                                shape: const RoundedRectangleBorder(side: BorderSide.none),
                                iconColor: Colors.black54,
                                collapsedIconColor: Colors.black54,
                                leading: Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 4.0),
                                  child: Icon(Icons.circle, color: fechou ? Colors.green : Colors.red, size: 10),
                                ),
                                title: Text(item['nome'] ?? 'Sem nome', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
                                subtitle: Text('Avaliação · ${_formatarData(item['data_avaliacao'])}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Table(
                                          border: TableBorder.symmetric(
                                            inside: BorderSide(color: Colors.grey.shade200, width: 1),
                                          ),
                                          children: [
                                            TableRow(
                                              children: [
                                                _buildCleanInfoItem(Icons.phone_outlined, 'Telefone', item['telefone']?.toString() ?? 'N/A'),
                                                _buildCleanInfoItem(Icons.cake_outlined, 'Data de Nascimento', (item['data_nascimento'] == null || item['data_nascimento'] == '0') ? 'N/A' : item['data_nascimento']),
                                              ]
                                            ),
                                            TableRow(
                                              children: [
                                                _buildCleanInfoItem(Icons.person_outline, 'Profissional', item['profissional']?.toString() ?? 'N/A'),
                                                _buildCleanInfoItem(Icons.medical_services_outlined, 'Especialidade', item['especialidade']?.toString() ?? 'N/A'),
                                              ]
                                            ),
                                            TableRow(
                                              children: [
                                                _buildCleanInfoItem(Icons.payments_outlined, 'Valor', 'R\$ ${item['valor']?.toStringAsFixed(2) ?? '0.00'}'),
                                                _buildCleanInfoItem(Icons.calendar_today_outlined, 'Sessões', item['num_sessoes']?.toString() ?? '0'),
                                              ]
                                            ),
                                            TableRow(
                                              children: [
                                                _buildCleanInfoItem(Icons.credit_card_outlined, 'Pagamento', textoPagamento),
                                                _buildCleanInfoItem(Icons.explore_outlined, 'Origem', item['origem'] ?? 'Não informada'),
                                              ]
                                            ),
                                          ],
                                        ),
                                        
                                        if (!fechou) ...[
                                          const Divider(height: 1),
                                          _buildCleanInfoItem(
                                            Icons.cancel_outlined, 
                                            'Motivo do Não Fechamento', 
                                            (item['motivo_nao_fechamento'] == null || item['motivo_nao_fechamento'].toString().trim().isEmpty) 
                                                ? 'Não informado' 
                                                : item['motivo_nao_fechamento'].toString(), 
                                            isFullWidth: true
                                          ),
                                        ],

                                        const Divider(height: 1),
                                        _buildCleanInfoItem(
                                          Icons.description_outlined, 
                                          'Observações', 
                                          (item['observacoes'] == null || item['observacoes'].toString().trim().isEmpty) 
                                              ? 'Nenhuma observação registrada.' 
                                              : item['observacoes'].toString(), 
                                          isFullWidth: true,
                                          isItalic: (item['observacoes'] == null || item['observacoes'].toString().trim().isEmpty)
                                        ),

                                        const SizedBox(height: 16),
                                        
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () async => await PdfServices.gerarFichaPaciente(item),
                                              icon: const Icon(Icons.print_outlined, size: 18, color: Colors.blueGrey),
                                              label: const Text('Imprimir', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton.icon(
                                              onPressed: () async {
                                                await Navigator.push(context, MaterialPageRoute(builder: (context) => CadastroPacienteScreen(pacienteParaEditar: item)));
                                                setState(() => _refreshKey = UniqueKey());
                                              },
                                              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blueGrey),
                                              label: const Text('Editar', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                                            ),
                                            if (Sessao.isAdmin) ...[
                                              const SizedBox(width: 8),
                                              TextButton.icon(
                                                onPressed: () => _confirmarExclusao(context, item['id'], item['nome']),
                                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                                label: const Text('Excluir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      
                    if (listaFiltrada.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, size: 20),
                              color: _paginaAtual > 1 ? primaryBlue : Colors.grey.shade400,
                              onPressed: _paginaAtual > 1 ? () => setState(() => _paginaAtual--) : null,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Página $_paginaAtual de ${totalPaginas == 0 ? 1 : totalPaginas}', 
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, size: 20),
                              color: _paginaAtual < totalPaginas ? primaryBlue : Colors.grey.shade400,
                              onPressed: _paginaAtual < totalPaginas ? () => setState(() => _paginaAtual++) : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanInfoItem(IconData icon, String label, String value, {bool isFullWidth = false, bool isItalic = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(
                  value, 
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: isItalic ? FontWeight.normal : FontWeight.w600, 
                    fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                    color: isItalic ? Colors.grey.shade500 : Colors.black87
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatarData(String? dataIso) {
    if (dataIso == null || dataIso.isEmpty) return 'Data não informada';
    try {
      DateTime data = DateTime.parse(dataIso);
      return DateFormat('dd/MM/yyyy').format(data);
    } catch (e) {
      var partes = dataIso.split('T')[0].split('-');
      if (partes.length == 3) return '${partes[2]}/${partes[1]}/${partes[0]}';
      return dataIso;
    }
  }
}