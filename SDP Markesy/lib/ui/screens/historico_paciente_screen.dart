import 'package:flutter/material.dart';
import 'package:sdp_markesy/ui/screens/cadastro_paciente_screen.dart';
import '../../data/database/db_helper.dart';

class HistoricoPacienteScreen extends StatefulWidget {
  const HistoricoPacienteScreen({super.key});

  @override
  State<HistoricoPacienteScreen> createState() =>
      _HistoricoPacienteScreenState();
}

class _HistoricoPacienteScreenState extends State<HistoricoPacienteScreen> {
  // Chave para forçar o FutureBuilder a recarregar a lista
  Key _refreshKey = UniqueKey();

  // Lógica de Exclusão com Confirmação
  void _confirmarExclusao(BuildContext context, int id, String nome) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Registro'),
        content: Text('Tem certeza que deseja apagar os dados de $nome?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await DbHelper.excluirPaciente(id);
              if (mounted) {
                Navigator.pop(ctx); // Fecha o alerta
                setState(() {
                  _refreshKey = UniqueKey(); // Atualiza a lista visualmente
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Registro removido com sucesso!'),
                  ),
                );
              }
            },
            child: const Text(
              'EXCLUIR AGORA',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico da Clínica')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        key: _refreshKey, // Atribuímos a chave aqui
        future: DbHelper.buscarResumoPaciente(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final lista = snapshot.data!;

          if (lista.isEmpty) {
            return const Center(
              child: Text('Nenhum paciente cadastrado no OneDrive.'),
            );
          }

          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final item = lista[index];
              bool fechou = item['fechou_pacote'] == 1;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  leading: Icon(
                    Icons.circle,
                    color: fechou ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  title: Text(
                    item['nome'] ?? 'Sem nome',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Avaliação: ${item['data_avaliacao']?.split('T')[0] ?? ''}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          Text(
                            'Profissional: ${item['profissional'] ?? 'N/A'}',
                          ),
                          Text(
                            'Especialidade: ${item['especialidade'] ?? 'N/A'}',
                          ),
                          Text(
                            'Valor: R\$ ${item['valor']?.toStringAsFixed(2) ?? '0.00'}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Observações: ${item['observacoes'] ?? 'Nenhuma'}',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CadastroPacienteScreen(
                                            pacienteParaEditar: item,
                                          ),
                                    ),
                                  );
                                  setState(() {
                                    _refreshKey = UniqueKey();
                                  });
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                label: const Text(
                                  'Editar',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () => _confirmarExclusao(
                                  context,
                                  item['id'],
                                  item['nome'],
                                ),
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  'Excluir',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
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
    );
  }
}
