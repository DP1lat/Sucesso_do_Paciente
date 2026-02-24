import 'package:flutter/material.dart';
import '../../data/database/db_helper.dart';

class HistoricoPacienteScreen extends StatelessWidget {
  const HistoricoPacienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico da Clínica')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DbHelper.buscarResumoPaciente(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final lista = snapshot.data!;

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
