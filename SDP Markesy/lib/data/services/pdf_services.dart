import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class PdfServices {
  static Future<void> gerarRelatorioPacientes(List<Map<String, dynamic>> listaPacientes) async {
    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final fonteNormal = await PdfGoogleFonts.robotoRegular();
    final fonteNegrito = await PdfGoogleFonts.robotoBold();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: fonteNormal, bold: fonteNegrito),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Relatório de Pacientes e Tratamentos', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Markesý', style: pw.TextStyle(fontSize: 20, color: PdfColors.blue800)),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Gerado em: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}'),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              context: context,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              headerHeight: 30,
              cellHeight: 25,
              cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.center, 2: pw.Alignment.centerRight},
              headers: ['Paciente', 'Especialidade', 'Valor'],
              data: listaPacientes.map((paciente) {
                final nome = paciente['nome'] ?? 'Sem nome';
                final especialidade = paciente['especialidade'] ?? '--';
                final valorCru = double.tryParse(paciente['valor']?.toString() ?? '0') ?? 0.0;
                final valorFormatado = formatadorMoeda.format(valorCru);

                return [nome, especialidade, valorFormatado];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total Geral: ${formatadorMoeda.format(listaPacientes.fold(0.0, (total, item) => total + (double.tryParse(item['valor']?.toString() ?? '0') ?? 0.0)))}',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ];
        },
      ),
    );
    await _salvarEAbrirPdf(pdf, 'Relatorio_Markesy_${DateFormat('dd_MM_yyyy_HH_mm').format(DateTime.now())}.pdf');
    // await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save(), name: 'Relatório_Markesý_${DateFormat('dd/MM/yyyy').format(DateTime.now())}');
  }

  static Future<void> gerarFichaPaciente(Map<String, dynamic> paciente) async {
    final fonteNormal = await PdfGoogleFonts.robotoRegular();
    final fonteNegrito = await PdfGoogleFonts.robotoBold();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: fonteNormal, bold: fonteNegrito),
    );
    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final nome = paciente['nome'] ?? 'Nome não encontrado';
    final telefone = paciente['telefone'] ?? 'Não informado';
    final dataNasc = paciente['data_nascimento'] ?? 'Não informado';
    final especialidade = paciente['especialidade'] ?? 'Nenhuma avaliação';
    final profissional = paciente['profissional'] ?? '-';
    final numSessoes = paciente['num_sessoes'] ?? '-';
    final formaPagamento = paciente['form_pagamento'] ?? '-';
    final valorCru = double.tryParse(paciente['valor']?.toString() ?? '0') ?? 0.0;
    final valorFormatado = formatadorMoeda.format(valorCru);
    final observacoes = paciente['observacoes'] ?? 'Nenhuma Observação registrada';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('FICHA PACIENTE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Clínica Markesý', style: pw.TextStyle(fontSize: 16, color: PdfColors.blue800)),
                  ],
                ),
                pw.Text('Data: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
              ],
            ),
            pw.Divider(thickness: 2, color: PdfColors.blue800),
            pw.SizedBox(height: 20),
            pw.Text(
              'DADOS PESSOAIS',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Nome: $nome', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  pw.SizedBox(height: 5),
                  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Telefone: $telefone'), pw.Text('Data de Nascimento: $dataNasc')]),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'DETALHES DO TRATAMENTO',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Especialidade: $especialidade'), pw.Text('Profissional: $profissional')]),
                  pw.SizedBox(height: 10),
                  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Número de Sessões: $numSessoes'), pw.Text('Pagamento: $formaPagamento')]),
                  pw.SizedBox(height: 10),
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 5),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      'Valor Total: $valorFormatado',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'OBSERVAÇÕES CLÍNICAS',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
            ),
            pw.SizedBox(height: 10),
            pw.Text(observacoes, style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 40),
            pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Column(
                children: [
                  pw.Container(width: 250, height: 1, color: PdfColors.black),
                  pw.Text('Assinatura do Paciente / Responsável'),
                ],
              ),
            ),
          ];
        },
      ),
    );

    String nomeLimpo = nome.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

    await _salvarEAbrirPdf(pdf, 'Ficha_$nomeLimpo.pdf');
  }

  static Future<void> _salvarEAbrirPdf(pw.Document pdf, String nomeArquivo) async {
    final bytes = await pdf.save();

    final diretorio = await getApplicationDocumentsDirectory();

    final arquivo = File('${diretorio.path}/$nomeArquivo');
    await arquivo.writeAsBytes(bytes);

    Process.run('explorer', [arquivo.path]);
  }
}
