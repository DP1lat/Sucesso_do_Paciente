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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico da Clínica'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
            tooltip: 'Gerar Relátorio Geral',
            onPressed: () async {
              final lista = await DbHelper.buscarResumoPaciente(_criterioOrdenacao, filtro: _filtroNome);
              await PdfServices.gerarRelatorioPacientes(lista);
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar por',
            onSelected: (String novoCriterio) {
              setState(() {
                _criterioOrdenacao = novoCriterio;
                _refreshKey = UniqueKey();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'p.id DESC', child: Text('Mais recentes')),
              const PopupMenuItem<String>(value: 'nome ASC', child: Text('Nome (A-Z)')),
              const PopupMenuItem<String>(value: 'valor DESC', child: Text('Maior Valor')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar paciente por nome...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _filtroNome = '';
                            _refreshKey = UniqueKey();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _filtroNome = value;
                  _refreshKey = UniqueKey();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              key: _refreshKey,
              future: DbHelper.buscarResumoPaciente(_criterioOrdenacao, filtro: _filtroNome),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
                }

                final lista = snapshot.data ?? [];

                if (lista.isEmpty) {
                  return const Center(child: Text('Nenhum paciente encontrado.'));
                }

                return ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final item = lista[index];
                    bool fechou = item['fechou_pacote'] == 1;
                    final tipoPag = item['tipo_pagamento']?.toString() ?? '';
                    final formaPag = item['forma_pagamento']?.toString() ?? '';
                    final parcelas = item['num_parcelas']?.toString() ?? '';

                    String textoPagamento = '';
                    if (tipoPag.isNotEmpty && tipoPag != 'null') textoPagamento += tipoPag;
                    if (formaPag.isNotEmpty && formaPag != 'null') {
                      textoPagamento += (textoPagamento.isNotEmpty ? ' - ' : '') + formaPag;
                    }

                    if (parcelas.isNotEmpty && parcelas != '0' && parcelas != '1' && parcelas != 'null') {
                      textoPagamento += '(${parcelas}x)';
                    }

                    if (textoPagamento.trim().isEmpty) textoPagamento = '-';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ExpansionTile(
                        leading: Icon(Icons.circle, color: fechou ? Colors.green : Colors.red, size: 16),
                        title: Text(item['nome'] ?? 'Sem nome', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Avaliação: ${_formatarData(item['data_avaliacao'])}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                _buildInfoRow(Icons.phone, 'Telefone', item['telefone']),
                                _buildInfoRow(Icons.cake, 'Data de Nascimento', (item['data_nascimento'] == null || item['data_nascimento'] == '0') ? 'Não informada' : item['data_nascimento']),
                                const SizedBox(height: 16),
                                _buildInfoRow(Icons.person, 'Profissional', item['profissional']),
                                _buildInfoRow(Icons.medical_services, 'Especialidade', item['especialidade']),
                                _buildInfoRow(Icons.payments, 'Valor', 'R\$ ${item['valor']?.toStringAsFixed(2) ?? '0.00'}'),
                                _buildInfoRow(Icons.calendar_month, 'Sessões', item['num_sessoes']?.toString() ?? '-'),
                                _buildInfoRow(Icons.credit_card, 'Pagamento', textoPagamento),
                                const SizedBox(height: 10),
                                const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Text(item['observacoes'] ?? 'Nenhuma observação.', style: const TextStyle(fontStyle: FontStyle.italic)),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () async {
                                        await PdfServices.gerarFichaPaciente(item);
                                      },
                                      icon: const Icon(Icons.print, color: Colors.blue),
                                      label: const Text('Imprimir', style: TextStyle(color: Colors.blue)),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () async {
                                        await Navigator.push(context, MaterialPageRoute(builder: (context) => CadastroPacienteScreen(pacienteParaEditar: item)));
                                        setState(() {
                                          _refreshKey = UniqueKey();
                                        });
                                      },
                                      icon: const Icon(Icons.edit, color: Colors.orange),
                                      label: const Text('Editar', style: TextStyle(color: Colors.orange)),
                                    ),
                                    if (Sessao.isAdmin) ...[
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () => _confirmarExclusao(context, item['id'], item['nome']),
                                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                                        label: const Text('Excluir', style: TextStyle(color: Colors.red)),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value?.toString() ?? 'N/A'),
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
