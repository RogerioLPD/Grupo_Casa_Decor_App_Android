import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:nucleo_casa_decor_android/features/reports/data/models/user_report.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfExportService {
  static final Map<String, pw.ImageProvider> _pdfImageCache = {};

  static String _formatPoints(double points) {
    if (points == points.roundToDouble()) {
      return NumberFormat.decimalPattern('pt_BR').format(points.round());
    }

    return NumberFormat.decimalPatternDigits(
      locale: 'pt_BR',
      decimalDigits: 2,
    ).format(points);
  }

  static Future<void> precachePdfImage(String? imageSource) async {
    await _resolvePdfImage(imageSource);
  }

  // ==============================
  // PDF simples: lista de usuários
  // ==============================
  static Future<void> exportUserReportsPdf(
    List<Map<String, dynamic>> userReports,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Lista de Arquitetos Cadastrados',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headers: ['Nome', 'E-mail', 'CNPJ', 'CPF'],
                data:
                    userReports
                        .map(
                          (item) => [
                            item['nome'] ?? '',
                            item['email'] ?? '',
                            item['cnpj']?.isNotEmpty == true
                                ? item['cnpj']
                                : '-',
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
  static Future<void> exportEmpresasPdf(
    List<Map<String, dynamic>> empresas,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Lista de Empresas Cadastradas',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
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
  static Future<void> exportUserReportsProfessionalPdf(
    List<UserReport> reports,
  ) async {
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
                child: pw.TableHelper.fromTextArray(
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
                  border: pw.TableBorder.all(
                    color: PdfColors.grey400,
                    width: 0.5,
                  ),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.blue900,
                  ),
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
    final sortedReports = [...reports]..sort((a, b) {
      final dateComparison = b.createdAt.compareTo(a.createdAt);
      if (dateComparison != 0) {
        return dateComparison;
      }

      return b.id.compareTo(a.id);
    });

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
                child: pw.TableHelper.fromTextArray(
                  headers: [
                    'Empresa',
                    'Arquiteto',
                    'Pontos',
                    'Compras',
                    'Valor Total',
                    'Data da Compra',
                  ],
                  data:
                      sortedReports
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
                  border: pw.TableBorder.all(
                    color: PdfColors.grey400,
                    width: 0.5,
                  ),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.blue900,
                  ),
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

  static Future<void> exportCompanyDashboardPdf(
    List<UserReport> reports,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final sortedReports = [...reports]..sort((a, b) {
      final dateComparison = b.createdAt.compareTo(a.createdAt);
      if (dateComparison != 0) {
        return dateComparison;
      }

      return b.id.compareTo(a.id);
    });
    final rows =
        sortedReports
            .map(
              (report) => [
                report.companySegment?.trim().isNotEmpty == true
                    ? report.companySegment!.trim()
                    : 'Não informado',
                report.userName.trim().isNotEmpty
                    ? report.userName.trim()
                    : 'Não informado',
                dateFormat.format(report.createdAt),
              ],
            )
            .toList();

    pw.Widget buildHeader() {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 8),
        color: PdfColors.blue900,
        width: double.infinity,
        child: pw.Center(
          child: pw.Text(
            'Grupo Casa Decor',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ),
      );
    }

    pw.Widget buildTableRow(
      String segment,
      String specifierName, {
      String purchaseDate = '',
      bool isHeader = false,
    }) {
      final backgroundColor = isHeader ? PdfColors.blue900 : PdfColors.white;
      final textColor = isHeader ? PdfColors.white : PdfColors.grey900;

      pw.Widget cell(String text, int flex) {
        return pw.Expanded(
          flex: flex,
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
            ),
            child: pw.Text(
              text,
              style: pw.TextStyle(
                fontSize: isHeader ? 11 : 10,
                fontWeight:
                    isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
        );
      }

      return pw.Container(
        color: backgroundColor,
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            cell(segment, 1),
            cell(specifierName, 2),
            cell(purchaseDate, 1),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build:
            (context) => [
              buildHeader(),
              pw.SizedBox(height: 8),
              pw.Text(
                'Listagem de Transações',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 16),
              if (rows.isEmpty)
                pw.Text(
                  'Nenhuma transação encontrada.',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey800,
                  ),
                )
              else ...[
                buildTableRow(
                  'Seguimento',
                  'Nome do Especificador',
                  purchaseDate: 'Data da Compra',
                  isHeader: true,
                ),
                ...rows.map(
                  (row) => buildTableRow(row[0], row[1], purchaseDate: row[2]),
                ),
              ],
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'listagem_transacoes_empresa.pdf',
    );
  }

  static Future<void> exportCompanyStatementPdf(
    List<UserReport> reports, {
    required String companyName,
    String? companyLogo,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final logoImage = await _resolvePdfImage(companyLogo);
    final sortedReports = [...reports]..sort((a, b) {
      final dateComparison = b.createdAt.compareTo(a.createdAt);
      if (dateComparison != 0) {
        return dateComparison;
      }

      return b.id.compareTo(a.id);
    });
    final rows =
        sortedReports
            .map(
              (report) => [
                dateFormat.format(report.createdAt),
                report.userName.trim().isNotEmpty
                    ? report.userName.trim()
                    : 'Não informado',
                report.companySegment?.trim().isNotEmpty == true
                    ? report.companySegment!.trim()
                    : 'Não informado',
                currencyFormat.format(report.totalSpent),
                _formatPoints(
                  report.launchedPoints ?? (report.totalSpent / 1000),
                ),
              ],
            )
            .toList();

    pw.Widget buildHeader() {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: PdfColors.blue900,
        width: double.infinity,
        child: pw.Row(
          children: [
            pw.Container(
              width: 46,
              height: 46,
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              padding: const pw.EdgeInsets.all(4),
              child: pw.Image(logoImage, fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(width: 12),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Grupo Casa Decor',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  companyName,
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build:
            (context) => [
              buildHeader(),
              pw.SizedBox(height: 8),
              pw.Text(
                'Extrato da Empresa',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 16),
              if (rows.isEmpty)
                pw.Text(
                  'Nenhuma transação encontrada.',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey800,
                  ),
                )
              else
                pw.TableHelper.fromTextArray(
                  headers: [
                    'Data',
                    'Nome do Especificador',
                    'Seguimento',
                    'Valor da Compra',
                    'Pontos Lançados',
                  ],
                  data: rows,
                  border: pw.TableBorder.all(
                    color: PdfColors.grey400,
                    width: 0.5,
                  ),
                  headerStyle: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.blue900,
                  ),
                  cellStyle: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey900,
                  ),
                  cellPadding: const pw.EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 5,
                  ),
                  oddRowDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey100,
                  ),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(70),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(1.2),
                    3: const pw.FixedColumnWidth(92),
                    4: const pw.FixedColumnWidth(90),
                  },
                  cellAlignments: {
                    0: pw.Alignment.center,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.centerLeft,
                    3: pw.Alignment.centerRight,
                    4: pw.Alignment.centerRight,
                  },
                  headerAlignments: {
                    0: pw.Alignment.center,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.centerLeft,
                    3: pw.Alignment.centerRight,
                    4: pw.Alignment.centerRight,
                  },
                ),
            ],
      ),
    );

    final pdfBytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'extrato_empresa.pdf',
    );
  }

  static Future<pw.ImageProvider> _resolvePdfImage(String? imageSource) async {
    final source = imageSource?.trim();
    if (source != null && source.isNotEmpty) {
      final cachedImage = _pdfImageCache[source];
      if (cachedImage != null) {
        return cachedImage;
      }

      try {
        if (source.startsWith('http://') || source.startsWith('https://')) {
          final image = await networkImage(source);
          _pdfImageCache[source] = image;
          return image;
        }

        final normalizedBase64 =
            source.contains(',') ? source.split(',').last : source;
        final image = pw.MemoryImage(base64Decode(normalizedBase64));
        _pdfImageCache[source] = image;
        return image;
      } catch (_) {
        // Fallback para a logo do Grupo Casa Decor quando a empresa não tem imagem válida.
      }
    }

    const fallbackKey = 'assets/images/Grupo.png';
    final cachedFallback = _pdfImageCache[fallbackKey];
    if (cachedFallback != null) {
      return cachedFallback;
    }

    final logoBytes = await rootBundle.load('assets/images/Grupo.png');
    final image = pw.MemoryImage(logoBytes.buffer.asUint8List());
    _pdfImageCache[fallbackKey] = image;
    return image;
  }
}
