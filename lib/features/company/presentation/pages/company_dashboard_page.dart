import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nucleo_casa_decor_android/features/reports/data/services/report_service.dart';
import 'package:nucleo_casa_decor_android/features/reports/data/services/pdf_export_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:nucleo_casa_decor_android/features/reports/data/models/user_report.dart';
import 'package:nucleo_casa_decor_android/shared/presentation/widgets/animated_card.dart';
import 'package:intl/intl.dart';

class DashboardCompany extends StatefulWidget {
  const DashboardCompany({super.key});

  @override
  State<DashboardCompany> createState() => _DashboardCompanyState();
}

class _DashboardCompanyState extends State<DashboardCompany> {
  final List<UserReport> _userReports = [];
  final List<UserReport> _groupReports = [];
  String? _loggedCompanyName;
  String? _loggedCompanyLogo;
  DateTimeRange? _recentPeriod;
  DateTimeRange? _statementPeriod;
  bool _isLoading = false;
  bool _isGeneratingRecentPdf = false;
  bool _isGeneratingStatementPdf = false;
  String? _errorMessage;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );
  final NumberFormat _pointsFormat = NumberFormat.decimalPatternDigits(
    locale: 'pt_BR',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _fetchUserReportsWithEmpresas();
  }

  List<UserReport> get _sortedReports {
    return [..._groupReports]..sort((a, b) {
      final dateComparison = b.createdAt.compareTo(a.createdAt);
      if (dateComparison != 0) {
        return dateComparison;
      }

      return b.id.compareTo(a.id);
    });
  }

  List<UserReport> get _sortedCompanyReports {
    return [..._userReports]..sort((a, b) {
      final dateComparison = b.createdAt.compareTo(a.createdAt);
      if (dateComparison != 0) {
        return dateComparison;
      }

      return b.id.compareTo(a.id);
    });
  }

  List<UserReport> get _filteredReports {
    final selectedPeriod = _recentPeriod;
    if (selectedPeriod == null) {
      return _sortedReports;
    }

    final startDate = DateUtils.dateOnly(selectedPeriod.start);
    final endDate = DateUtils.dateOnly(selectedPeriod.end);

    return _sortedReports.where((report) {
      final createdAt = DateUtils.dateOnly(report.createdAt);
      return !createdAt.isBefore(startDate) && !createdAt.isAfter(endDate);
    }).toList();
  }

  List<UserReport> get _visibleReports {
    if (_recentPeriod == null) {
      return _sortedReports.take(5).toList();
    }

    return _filteredReports;
  }

  List<UserReport> get _companyStatementReports {
    final selectedPeriod = _statementPeriod;
    if (selectedPeriod == null) {
      return _sortedCompanyReports;
    }

    final startDate = DateUtils.dateOnly(selectedPeriod.start);
    final endDate = DateUtils.dateOnly(selectedPeriod.end);

    return _sortedCompanyReports.where((report) {
      final createdAt = DateUtils.dateOnly(report.createdAt);
      return !createdAt.isBefore(startDate) && !createdAt.isAfter(endDate);
    }).toList();
  }

  String get _periodLabel {
    final selectedPeriod = _recentPeriod;
    if (selectedPeriod == null) {
      return 'Filtrar período';
    }

    return '${_dateFormat.format(selectedPeriod.start)} - ${_dateFormat.format(selectedPeriod.end)}';
  }

  String get _statementPeriodLabel {
    final selectedPeriod = _statementPeriod;
    if (selectedPeriod == null) {
      return 'Filtrar período';
    }

    return '${_dateFormat.format(selectedPeriod.start)} - ${_dateFormat.format(selectedPeriod.end)}';
  }

  Future<void> _selectPeriod() async {
    final now = DateTime.now();
    final reports = _groupReports;
    final firstReportDate =
        reports.isEmpty
            ? DateTime(now.year - 5, 1, 1)
            : reports
                .map((report) => report.createdAt)
                .reduce((a, b) => a.isBefore(b) ? a : b);
    final firstDate = DateUtils.dateOnly(firstReportDate);
    final today = DateUtils.dateOnly(now);
    final defaultStartCandidate = DateUtils.dateOnly(
      now.subtract(const Duration(days: 30)),
    );
    final defaultStart =
        defaultStartCandidate.isBefore(firstDate)
            ? firstDate
            : defaultStartCandidate;
    final defaultEnd = today.isBefore(defaultStart) ? defaultStart : today;

    final range = await showDateRangePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      firstDate: firstDate,
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange:
          _recentPeriod ?? DateTimeRange(start: defaultStart, end: defaultEnd),
      builder: (context, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final pickerHeaderColor =
            theme.brightness == Brightness.dark
                ? colorScheme.secondary
                : colorScheme.primary;
        final pickerHeaderTextColor =
            theme.brightness == Brightness.dark
                ? colorScheme.onSecondary
                : colorScheme.onPrimary;

        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: colorScheme.surface,
              headerBackgroundColor: pickerHeaderColor,
              headerForegroundColor: pickerHeaderTextColor,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.onPrimary;
                }
                if (states.contains(WidgetState.disabled)) {
                  return colorScheme.onSurface.withValues(alpha: 0.38);
                }
                return colorScheme.onSurface;
              }),
              yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.onPrimary;
                }
                if (states.contains(WidgetState.disabled)) {
                  return colorScheme.onSurface.withValues(alpha: 0.38);
                }
                return colorScheme.onSurface;
              }),
              todayForegroundColor: WidgetStateProperty.all(
                colorScheme.secondary,
              ),
              rangePickerBackgroundColor: colorScheme.surface,
              rangePickerHeaderBackgroundColor: pickerHeaderColor,
              rangePickerHeaderForegroundColor: pickerHeaderTextColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range == null || !mounted) {
      return;
    }

    setState(() {
      _recentPeriod = range;
    });
  }

  Future<void> _selectStatementPeriod() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 10, 1, 1);
    final today = DateUtils.dateOnly(now);
    final defaultStartCandidate = DateUtils.dateOnly(
      now.subtract(const Duration(days: 30)),
    );
    final defaultStart =
        defaultStartCandidate.isBefore(firstDate)
            ? firstDate
            : defaultStartCandidate;
    final defaultEnd = today.isBefore(defaultStart) ? defaultStart : today;

    final range = await showDateRangePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      firstDate: firstDate,
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange:
          _statementPeriod ??
          DateTimeRange(start: defaultStart, end: defaultEnd),
      builder: (context, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final pickerHeaderColor =
            theme.brightness == Brightness.dark
                ? colorScheme.secondary
                : colorScheme.primary;
        final pickerHeaderTextColor =
            theme.brightness == Brightness.dark
                ? colorScheme.onSecondary
                : colorScheme.onPrimary;

        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: colorScheme.surface,
              headerBackgroundColor: pickerHeaderColor,
              headerForegroundColor: pickerHeaderTextColor,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.onPrimary;
                }
                if (states.contains(WidgetState.disabled)) {
                  return colorScheme.onSurface.withValues(alpha: 0.38);
                }
                return colorScheme.onSurface;
              }),
              yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.onPrimary;
                }
                if (states.contains(WidgetState.disabled)) {
                  return colorScheme.onSurface.withValues(alpha: 0.38);
                }
                return colorScheme.onSurface;
              }),
              todayForegroundColor: WidgetStateProperty.all(
                colorScheme.secondary,
              ),
              rangePickerBackgroundColor: colorScheme.surface,
              rangePickerHeaderBackgroundColor: pickerHeaderColor,
              rangePickerHeaderForegroundColor: pickerHeaderTextColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range == null || !mounted) {
      return;
    }

    setState(() {
      _statementPeriod = range;
    });
  }

  Future<void> _exportFilteredReportsPdf() async {
    if (_isGeneratingRecentPdf) {
      return;
    }

    final reports = _visibleReports;
    if (reports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nenhuma transação para exportar no período selecionado.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingRecentPdf = true;
    });

    try {
      await PdfExportService.exportCompanyDashboardPdf(reports);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao gerar PDF: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingRecentPdf = false;
        });
      }
    }
  }

  Future<void> _exportStatementPdf() async {
    if (_isGeneratingStatementPdf) {
      return;
    }

    final reports = _companyStatementReports;
    if (reports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nenhuma transação da empresa para exportar no período selecionado.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingStatementPdf = true;
    });
    await SchedulerBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 300));

    try {
      await PdfExportService.exportCompanyStatementPdf(
        reports,
        companyName: _loggedCompanyName ?? 'Empresa logada',
        companyLogo: _loggedCompanyLogo,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao gerar PDF: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingStatementPdf = false;
        });
      }
    }
  }

  Future<void> _fetchUserReportsWithEmpresas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reportService = ReportService(context: context);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          _errorMessage = 'Token não encontrado. Faça login novamente.';
          _isLoading = false;
        });
        return;
      }

      final loggedCompanyResponse = await http.get(
        Uri.parse('https://apicasadecor.com/api/usuario/1'),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      if (loggedCompanyResponse.statusCode != 200) {
        setState(() {
          _errorMessage = 'Não foi possível identificar a empresa logada.';
          _isLoading = false;
        });
        return;
      }

      final loggedCompanyData = jsonDecode(
        utf8.decode(loggedCompanyResponse.bodyBytes),
      );
      final String loggedCompanyId = loggedCompanyData['id']?.toString() ?? '';
      final String loggedCompanyName =
          loggedCompanyData['nome']?.toString() ?? 'Empresa logada';
      String? loggedCompanyLogo = loggedCompanyData['foto']?.toString();

      if (loggedCompanyId.isEmpty) {
        setState(() {
          _errorMessage = 'Empresa logada sem identificador válido.';
          _isLoading = false;
        });
        return;
      }

      // 🔹 Passo 1: Buscar empresas via ReportService
      final empresasResult = await reportService.fetchEmpresas();

      Map<String, dynamic> empresasMap = {};
      if (empresasResult != null && empresasResult['list'] != null) {
        for (var empresa in empresasResult['list']) {
          if (empresa['id'] != null) {
            empresasMap[empresa['id'].toString()] = empresa;
          }
        }
      }

      final loggedCompanyDetails = empresasMap[loggedCompanyId];
      loggedCompanyLogo =
          loggedCompanyLogo?.isNotEmpty == true
              ? loggedCompanyLogo
              : loggedCompanyDetails?['foto']?.toString();

      // 🔹 Passo 2: Buscar lista de compras
      final url = Uri.parse("https://apicasadecor.com/api/compra/");
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode != 200) {
        setState(() {
          _errorMessage = 'Erro ao buscar dados (${response.statusCode}).';
          _isLoading = false;
        });
        return;
      }

      final responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> rawList = jsonDecode(responseBody);

      final List<UserReport> groupReports = [];
      final List<UserReport> companyReports = [];
      int idx = 0;

      for (var item in rawList) {
        try {
          final espec = item['especificador'];
          final empresaData = item['empresa'];

          final String nome =
              (espec != null && espec['nome'] != null)
                  ? espec['nome']
                  : 'Desconhecido';

          // 🔹 Buscar empresa associada à compra
          String empresaId =
              empresaData != null && empresaData['id'] != null
                  ? empresaData['id'].toString()
                  : '';

          final empresaDetalhes = empresasMap[empresaId];

          // 🔹 Capturar o campo "seguimento"
          final String? seguimento =
              empresaDetalhes != null
                  ? (empresaDetalhes['seguimento'] ?? 'Não informado')
                  : 'Não informado';

          final dynamic rawValor = item['valor'];
          final double valorParsed =
              double.tryParse(rawValor?.toString() ?? '0') ?? 0.0;
          final double valorMultiplicado = valorParsed * 1000;

          idx++;
          final report = UserReport(
            id: idx.toString(),
            userId:
                espec != null && espec['id'] != null
                    ? espec['id'].toString()
                    : nome,
            userName: nome,
            userEmail:
                '${nome.toLowerCase().replaceAll(RegExp(r"\\s+"), ".")}@email.com',
            companyId: empresaId,
            companyEmail:
                empresaDetalhes != null
                    ? (empresaDetalhes['email'] ?? 'sem_email@empresa.com')
                    : 'sem_email@empresa.com',
            totalPoints: valorMultiplicado.toInt(),
            launchedPoints: valorParsed,
            usedPoints: 0,
            totalPurchases: 1,
            totalSpent: valorMultiplicado,
            favoriteStores: [
              if (empresaDetalhes != null && empresaDetalhes['nome'] != null)
                empresaDetalhes['nome']
              else if (empresaData != null && empresaData['nome'] != null)
                empresaData['nome'],
            ],
            lastActivity: DateTime.now(),
            joinDate: DateTime.now().subtract(const Duration(days: 90)),
            createdAt:
                item['criado_em'] != null
                    ? DateTime.parse(item['criado_em'])
                    : DateTime.now(),

            // 🆕 Novo campo com o "seguimento" da empresa
            companySegment: seguimento,
          );

          groupReports.add(report);
          if (empresaId == loggedCompanyId) {
            companyReports.add(report);
          }
        } catch (e) {
          debugPrint('Erro ao processar item: $e');
        }
      }

      setState(() {
        _loggedCompanyName = loggedCompanyName;
        _loggedCompanyLogo = loggedCompanyLogo;
        _groupReports
          ..clear()
          ..addAll(groupReports);
        _userReports
          ..clear()
          ..addAll(companyReports);
        _isLoading = false;
      });
      PdfExportService.precachePdfImage(loggedCompanyLogo);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados: $e';
        _isLoading = false;
      });
    }
  }

  String _formatPurchaseValue(UserReport report) {
    return _currencyFormat.format(report.totalSpent);
  }

  String _formatLaunchedPoints(UserReport report) {
    final points = report.launchedPoints ?? (report.totalSpent / 1000);
    if (points == points.roundToDouble()) {
      return NumberFormat.decimalPattern('pt_BR').format(points.round());
    }

    return _pointsFormat.format(points);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    final content = SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(theme, isDesktop),
          const SizedBox(height: 32),
          _buildRecentTransactions(theme, isDesktop),
          const SizedBox(height: 32),
          _buildCompanyStatement(theme, isDesktop),
        ],
      ),
    );

    return Stack(
      children: [
        content,
        if (_isGeneratingStatementPdf)
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(
                color: theme.colorScheme.surface.withValues(alpha: 0.35),
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, bool isDesktop) {
    return GradientCard(
      gradientColors: [
        theme.colorScheme.primary,
        theme.colorScheme.primary.withValues(alpha: 0.8),
      ],
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '🏆 ', // emoji
                        style: (isDesktop
                                ? theme.textTheme.headlineMedium
                                : theme.textTheme.titleLarge)
                            ?.copyWith(
                              color: Colors.amber[700], // dourado para o emoji
                            ),
                      ),
                      TextSpan(
                        text: 'Bem-vindo ao Grupo Casa Decor',
                        style: (isDesktop
                                ? theme.textTheme.headlineMedium
                                : theme.textTheme.titleLarge)
                            ?.copyWith(
                              color:
                                  theme
                                      .colorScheme
                                      .onPrimary, // cor do texto normal
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sistema de pontos para arquitetos e designers',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(height: 16),
                  Text(
                    '✨ Acumule pontos a cada compra e troque por prêmios incríveis',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: isDesktop ? 48 : 32,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(ThemeData theme, bool isDesktop) {
    if (_groupReports.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma transação encontrada.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final recentReports = _visibleReports;
    final hasSelectedPeriod = _recentPeriod != null;
    final actionColor =
        theme.brightness == Brightness.dark
            ? theme.colorScheme.secondary
            : theme.colorScheme.primary;
    final onActionColor =
        theme.brightness == Brightness.dark
            ? theme.colorScheme.onSecondary
            : theme.colorScheme.onPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '📊 Transações Recentes do Grupo',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _selectPeriod,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: actionColor,
                    side: BorderSide(color: actionColor),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text(_periodLabel),
                ),
                if (_recentPeriod != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _recentPeriod = null;
                      });
                    },
                    tooltip: 'Limpar período',
                    color: actionColor,
                    icon: const Icon(Icons.filter_alt_off_rounded),
                  ),
                ElevatedButton.icon(
                  onPressed:
                      recentReports.isEmpty || _isGeneratingRecentPdf
                          ? null
                          : _exportFilteredReportsPdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionColor,
                    foregroundColor: onActionColor,
                    disabledBackgroundColor: theme.colorScheme.onSurface
                        .withValues(alpha: 0.12),
                    disabledForegroundColor: theme.colorScheme.onSurface
                        .withValues(alpha: 0.38),
                  ),
                  icon:
                      _isGeneratingRecentPdf
                          ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: onActionColor,
                            ),
                          )
                          : const Icon(Icons.picture_as_pdf_rounded),
                  label: Text(
                    _isGeneratingRecentPdf ? 'Gerando...' : 'Gerar PDF',
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          hasSelectedPeriod
              ? '${recentReports.length} transação(ões) encontrada(s)'
              : 'Exibindo os ${recentReports.length} últimos registros por data',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedCard(
          child:
              recentReports.isEmpty
                  ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Nenhuma transação encontrada no período selecionado.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                  : Column(
                    children:
                        recentReports.asMap().entries.map((entry) {
                          final index = entry.key;
                          final report = entry.value;

                          return TweenAnimationBuilder<double>(
                            duration: Duration(
                              milliseconds: 200 + (index * 100),
                            ),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(20 * (1 - value), 0),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border:
                                    index != recentReports.length - 1
                                        ? Border(
                                          bottom: BorderSide(
                                            color: theme.colorScheme.outline
                                                .withValues(alpha: 0.2),
                                          ),
                                        )
                                        : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.shopping_cart_rounded,
                                      size: 20,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      report.userName,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        report.companySegment ??
                                            'Não informado',
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                      ),
                                      Text(
                                        _dateFormat.format(report.createdAt),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
        ),
      ],
    );
  }

  Widget _buildCompanyStatement(ThemeData theme, bool isDesktop) {
    if (_userReports.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma transação encontrada.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final visibleReports = _companyStatementReports;
    final hasSelectedPeriod = _statementPeriod != null;
    final actionColor =
        theme.brightness == Brightness.dark
            ? theme.colorScheme.secondary
            : theme.colorScheme.primary;
    final onActionColor =
        theme.brightness == Brightness.dark
            ? theme.colorScheme.onSecondary
            : theme.colorScheme.onPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '📊 Extrato da Empresa',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _selectStatementPeriod,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: actionColor,
                    side: BorderSide(color: actionColor),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text(_statementPeriodLabel),
                ),
                if (_statementPeriod != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _statementPeriod = null;
                      });
                    },
                    tooltip: 'Limpar período do extrato',
                    color: actionColor,
                    icon: const Icon(Icons.filter_alt_off_rounded),
                  ),
                ElevatedButton.icon(
                  onPressed:
                      visibleReports.isEmpty || _isGeneratingStatementPdf
                          ? null
                          : _exportStatementPdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionColor,
                    foregroundColor: onActionColor,
                    disabledBackgroundColor: theme.colorScheme.onSurface
                        .withValues(alpha: 0.12),
                    disabledForegroundColor: theme.colorScheme.onSurface
                        .withValues(alpha: 0.38),
                  ),
                  icon:
                      _isGeneratingStatementPdf
                          ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: onActionColor,
                            ),
                          )
                          : const Icon(Icons.picture_as_pdf_rounded),
                  label: Text(
                    _isGeneratingStatementPdf ? 'Gerando...' : 'Gerar PDF',
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_loggedCompanyName != null) ...[
          Text(
            _loggedCompanyName!,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          hasSelectedPeriod
              ? '${visibleReports.length} transação(ões) encontrada(s)'
              : 'Exibindo ${visibleReports.length} transação(ões) da empresa por data',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedCard(
          child:
              visibleReports.isEmpty
                  ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Nenhuma transação encontrada para esta empresa no período selecionado.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                  : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingTextStyle: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      dataTextStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      columns: const [
                        DataColumn(label: Text('Data')),
                        DataColumn(label: Text('Especificador')),
                        DataColumn(label: Text('Seguimento')),
                        DataColumn(
                          label: Text('Valor da Compra'),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text('Pontos Lançados'),
                          numeric: true,
                        ),
                      ],
                      rows:
                          visibleReports
                              .map(
                                (report) => DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        _dateFormat.format(report.createdAt),
                                      ),
                                    ),
                                    DataCell(Text(report.userName)),
                                    DataCell(
                                      Text(
                                        report.companySegment ??
                                            'Não informado',
                                      ),
                                    ),
                                    DataCell(
                                      Text(_formatPurchaseValue(report)),
                                    ),
                                    DataCell(
                                      Text(_formatLaunchedPoints(report)),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                    ),
                  ),
        ),
      ],
    );
  }
}

/*Widget _buildTopClients(List<Client> clients, ThemeData theme, bool isDesktop) {
    final sortedClients = [...clients]..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    final topClients = sortedClients.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏅 Top Clientes',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...topClients.asMap().entries.map((entry) {
          final index = entry.key;
          final client = entry.value;
          final colors = [Colors.amber, Colors.grey, Colors.orange];
          final icons = [Icons.emoji_events, Icons.star, Icons.workspace_premium];

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 150)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(30 * (1 - value), 0),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: AnimatedCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors[index].withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icons[index],
                        color: colors[index],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${client.transactions.length} transações',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${client.totalPoints.toStringAsFixed(1)} pts',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}*/
