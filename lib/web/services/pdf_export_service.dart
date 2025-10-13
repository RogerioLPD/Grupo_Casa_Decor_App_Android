import 'package:nucleo_casa_decor_android/web/models/user_report.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfExportService {
  // ==============================
  // PDF simples: lista de usuários
  // ==============================
  static Future<void> exportUserReportsPdf(List<Map<String, dynamic>> userReports) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Lista de Arquitetos Cadastrados',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Nome', 'E-mail', 'CNPJ', 'CPF'],
                data:
                    userReports
                        .map(
                          (item) => [
                            item['nome'] ?? '',
                            item['email'] ?? '',
                            item['cnpj']?.isNotEmpty == true ? item['cnpj'] : '-',
                            item['cpf']?.isNotEmpty == true ? item['cpf'] : '-',
                          ],
                        )
                        .toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // ==============================
  // PDF simples: lista de empresas
  // ==============================
  static Future<void> exportEmpresasPdf(List<Map<String, dynamic>> empresas) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Lista de Empresas Cadastradas',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Nome', 'E-mail', 'CPF'],
                data:
                    empresas
                        .map(
                          (item) => [
                            item['nome'] ?? '',
                            item['email'] ?? '',
                            item['cpf']?.isNotEmpty == true ? item['cpf'] : '-',
                          ],
                        )
                        .toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // ==========================================
  // PDF profissional: relatório completo UserReport
  // ==========================================
  static Future<void> exportUserReportsProfessionalPdf(List<UserReport> reports) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho com nome da empresa
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                color: PdfColors.blue900,
                width: double.infinity,
                child: pw.Center(
                  child: pw.Text(
                    'Grupo Casa Decor',
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Relatório de Compras por Arquiteto',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 16),

              // Tabela detalhada
              pw.Expanded(
                child: pw.Table.fromTextArray(
                  headers: [
                    'Nome',
                    'Empresa',
                    'Pontos',
                    'Compras',
                    'Valor Total',
                    'Data da Compra',
                  ],
                  data:
                      reports
                          .map(
                            (report) => [
                              report.userName,
                              report.favoriteStores.join(', '),
                              (report.totalPoints ~/ 1000).toString(),
                              report.totalPurchases.toString(),
                              NumberFormat.currency(
                                locale: 'pt_BR',
                                symbol: 'R\$',
                              ).format(report.totalSpent),
                              dateFormat.format(report.createdAt),
                            ],
                          )
                          .toList(),
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                  cellHeight: 25,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.centerRight,
                    4: pw.Alignment.centerRight,
                    5: pw.Alignment.center,
                  },
                  headerAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.centerRight,
                    4: pw.Alignment.centerRight,
                    5: pw.Alignment.center,
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'relatorio_usuarios_profissional.pdf',
    );
  }

  static Future<void> exportCompanyPdf(List<UserReport> reports) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho com nome da empresa
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                color: PdfColors.blue900,
                width: double.infinity,
                child: pw.Center(
                  child: pw.Text(
                    'Grupo Casa Decor',
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Relatório Compras por Empresa',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 16),

              // Tabela detalhada
              pw.Expanded(
                child: pw.Table.fromTextArray(
                  headers: [
                    'Empresa',
                    'Arquiteto',
                    'Pontos',
                    'Compras',
                    'Valor Total',
                    'Data da Compra',
                  ],
                  data:
                      reports
                          .map(
                            (report) => [
                              report.favoriteStores.join(', '),
                              report.userName,
                              (report.totalPoints ~/ 1000).toString(),
                              report.totalPurchases.toString(),
                              NumberFormat.currency(
                                locale: 'pt_BR',
                                symbol: 'R\$',
                              ).format(report.totalSpent),
                              dateFormat.format(report.createdAt),
                            ],
                          )
                          .toList(),
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                  cellHeight: 25,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.centerRight,
                    4: pw.Alignment.centerRight,
                    5: pw.Alignment.center,
                  },
                  headerAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.centerRight,
                    4: pw.Alignment.centerRight,
                    5: pw.Alignment.center,
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'relatorio_empresas_profissional.pdf',
    );
  }
}
