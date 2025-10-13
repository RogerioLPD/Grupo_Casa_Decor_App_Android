import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/shared/services/list_report_controller.dart';
import 'package:nucleo_casa_decor_android/web/services/pdf_export_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:nucleo_casa_decor_android/web/models/user_report.dart';
import 'package:nucleo_casa_decor_android/web/widgets/responsive_layout.dart';

class UserReportsScreen extends StatefulWidget {
  const UserReportsScreen({super.key});

  @override
  State<UserReportsScreen> createState() => _UserReportsScreenState();
}

class _UserReportsScreenState extends State<UserReportsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<AnimationController> _cardAnimationControllers = [];
  List<Animation<double>> _cardAnimations = [];

  final List<UserReport> _userReports = [];
  final String _selectedFilter = 'Todos';
  String _selectedMonth = 'Mês';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  ReportService? _userService;
  List<dynamic> _especificadores = [];
  bool _isLoading = true;

  final List<String> _filterOptions = ['Todos', 'Mais Ativos', 'Mais Pontos', 'Novos Usuários'];

  final List<String> _monthOptions = [
    'Mês',
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  //bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchUserReports();
    _userService = ReportService(context: context);
    _carregarEspecificadores();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  void _initializeCardAnimations() {
    for (var c in _cardAnimationControllers) c.dispose();

    _cardAnimationControllers = List.generate(
      _userReports.length,
      (index) =>
          AnimationController(duration: Duration(milliseconds: 400 + (index * 50)), vsync: this),
    );

    _cardAnimations =
        _cardAnimationControllers
            .map(
              (controller) => Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack)),
            )
            .toList();

    for (int i = 0; i < _cardAnimationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) _cardAnimationControllers[i].forward();
      });
    }
  }

  Future<void> _carregarEspecificadores() async {
    final result = await _userService?.fetchEspecificadores();

    if (result != null && mounted) {
      setState(() {
        _especificadores = result['list'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          _errorMessage = 'Token não encontrado. Faça login novamente.';
          _isLoading = false;
        });
        return;
      }

      final url = Uri.parse("https://apicasadecor.com/api/compra/");
      final headers = {'Authorization': token, 'Content-Type': 'application/json'};

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

      final List<UserReport> reports = [];
      int idx = 0;

      for (var item in rawList) {
        try {
          final espec = item['especificador'];
          final empresa = item['empresa'];
          final String nome =
              (espec != null && espec['nome'] != null) ? espec['nome'] : 'Desconhecido';

          final dynamic rawValor = item['valor'];
          final double valorParsed = double.tryParse(rawValor?.toString() ?? '0') ?? 0.0;
          final double valorMultiplicado = valorParsed * 1000;

          idx++;
          reports.add(
            UserReport(
              id: idx.toString(),
              userId: espec != null && espec['id'] != null ? espec['id'].toString() : nome,
              userName: nome,
              userEmail: '${nome.toLowerCase().replaceAll(RegExp(r"\\s+"), ".")}@email.com',
              companyEmail: '${nome.toLowerCase().replaceAll(RegExp(r"\\s+"), ".")}@email.com',
              totalPoints: valorMultiplicado.toInt(),
              usedPoints: 0,
              totalPurchases: 1,
              totalSpent: valorMultiplicado,
              favoriteStores: [if (empresa != null && empresa['nome'] != null) empresa['nome']],
              lastActivity: DateTime.now(),
              joinDate: DateTime.now().subtract(const Duration(days: 90)),
              createdAt:
                  item['criado_em'] != null ? DateTime.parse(item['criado_em']) : DateTime.now(),
            ),
          );
        } catch (e) {
          debugPrint('Erro ao processar item: $e');
        }
      }

      setState(() {
        _userReports.clear();
        _userReports.addAll(reports);
        _initializeCardAnimations();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserReportsWithEmpresas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          _errorMessage = 'Token não encontrado. Faça login novamente.';
          _isLoading = false;
        });
        return;
      }

      // 🔹 Passo 1: Buscar empresas via ReportService
      final reportService = ReportService(context: context);
      final empresasResult = await reportService.fetchEmpresas();

      Map<String, dynamic> empresasMap = {};
      if (empresasResult != null && empresasResult['list'] != null) {
        for (var empresa in empresasResult['list']) {
          if (empresa['id'] != null) {
            empresasMap[empresa['id'].toString()] = empresa;
          }
        }
      }

      // 🔹 Passo 2: Buscar lista de compras
      final url = Uri.parse("https://apicasadecor.com/api/compra/");
      final headers = {'Authorization': token, 'Content-Type': 'application/json'};

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

      final List<UserReport> reports = [];
      int idx = 0;

      for (var item in rawList) {
        try {
          final espec = item['especificador'];
          final empresaData = item['empresa'];

          final String nome =
              (espec != null && espec['nome'] != null) ? espec['nome'] : 'Desconhecido';

          // 🔹 Buscar empresa associada à compra
          String empresaId =
              empresaData != null && empresaData['id'] != null ? empresaData['id'].toString() : '';

          final empresaDetalhes = empresasMap[empresaId];

          // 🔹 Capturar o campo "seguimento"
          final String? seguimento =
              empresaDetalhes != null
                  ? (empresaDetalhes['seguimento'] ?? 'Não informado')
                  : 'Não informado';

          final dynamic rawValor = item['valor'];
          final double valorParsed = double.tryParse(rawValor?.toString() ?? '0') ?? 0.0;
          final double valorMultiplicado = valorParsed * 1000;

          idx++;
          reports.add(
            UserReport(
              id: idx.toString(),
              userId: espec != null && espec['id'] != null ? espec['id'].toString() : nome,
              userName: nome,
              userEmail: '${nome.toLowerCase().replaceAll(RegExp(r"\\s+"), ".")}@email.com',
              companyEmail:
                  empresaDetalhes != null
                      ? (empresaDetalhes['email'] ?? 'sem_email@empresa.com')
                      : 'sem_email@empresa.com',
              totalPoints: valorMultiplicado.toInt(),
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
                  item['criado_em'] != null ? DateTime.parse(item['criado_em']) : DateTime.now(),

              // 🆕 Novo campo com o "seguimento" da empresa
              companySegment: seguimento,
            ),
          );
        } catch (e) {
          debugPrint('Erro ao processar item: $e');
        }
      }

      setState(() {
        _userReports
          ..clear()
          ..addAll(reports);
        _initializeCardAnimations();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _cardAnimationControllers) controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<UserReport> get _filteredReports {
    var filtered =
        _userReports.where((report) {
          final nameMatch = report.userName.toLowerCase().contains(_searchQuery.toLowerCase());
          final emailMatch = report.userEmail.toLowerCase().contains(_searchQuery.toLowerCase());
          return nameMatch || emailMatch;
        }).toList();

    // Filtro de mês
    if (_selectedMonth != 'Mês') {
      final selectedIndex = _monthOptions.indexOf(_selectedMonth);
      filtered = filtered.where((report) => report.createdAt.month == selectedIndex).toList();
    }

    switch (_selectedFilter) {
      case 'Mais Ativos':
        filtered.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
        break;
      case 'Mais Pontos':
        filtered.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
        break;
      case 'Novos Usuários':
        filtered.sort((a, b) => b.joinDate.compareTo(a.joinDate));
        break;
      default:
        filtered.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    }

    return filtered;
  }

  String formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  String formatPoints(int totalPoints) {
    final points = totalPoints ~/ 1000;
    return points.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildStatsOverview(),
                  const SizedBox(height: 32),
                  _buildFiltersAndSearch(),
                  const SizedBox(height: 24),
                  _buildUserReportsList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relatórios de Arquitetos',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Acompanhe a atividade e desempenho dos arquitetos no programa',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    final totalEspecificadores = _especificadores.length;
    final totalPoints = _userReports.fold<int>(0, (sum, report) => sum + report.totalPoints);
    final totalSpent = _userReports.fold<double>(0, (sum, report) => sum + report.totalSpent);

    // 🔹 Cálculo de "Arquitetos Ativos" (especificadores com pelo menos uma compra)
    final Set<String> emailsComCompra = {};
    for (var report in _userReports) {
      if (report.userEmail.isNotEmpty) {
        emailsComCompra.add(report.userEmail.toLowerCase());
      }
    }
    final arquitetosComCompra = emailsComCompra.length;

    final stats = [
      ReportStat(
        title: 'Total de Arquitetos',
        value: totalEspecificadores.toString(),
        icon: Icons.people_alt_rounded,
        color: Colors.blue,
      ),
      ReportStat(
        title: 'Pontos Totais',
        value: formatPoints(totalPoints),
        icon: Icons.star_rounded,
        color: Colors.orange,
      ),
      ReportStat(
        title: 'Volume de Vendas',
        value: formatCurrency(totalSpent),
        icon: Icons.trending_up_rounded,
        color: Colors.green,
      ),
      // 🔹 Agora "Arquitetos Ativos" mostra a quantidade de especificadores que têm compra
      ReportStat(
        title: 'Arquitetos Ativos',
        value: arquitetosComCompra.toString(),
        icon: Icons.person_outline_rounded,
        color: Colors.purple,
      ),
    ];

    final isSmallScreen = context.isTablet;
    final crossAxisCount = isSmallScreen ? 2 : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isSmallScreen ? 1.3 : 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) => _buildStatCard(stats[index]),
    );
  }

  Widget _buildStatCard(ReportStat stat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat.icon, color: stat.color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            stat.value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            stat.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // 🔽 FILTRO DE MÊS ADICIONADO AQUI 🔽
  Widget _buildFiltersAndSearch() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou email...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          // Dropdown de mês
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: DropdownButton<String>(
              value: _selectedMonth,
              underline: const SizedBox(),
              items:
                  _monthOptions
                      .map((month) => DropdownMenuItem(value: month, child: Text(month)))
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value!;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          // Dropdown de filtros já existente
          /* Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: DropdownButton<String>(
              value: _selectedFilter,
              underline: const SizedBox(),
              items: _filterOptions
                  .map((filter) => DropdownMenuItem(value: filter, child: Text(filter)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _buildUserReportsList() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    final filteredReports = _filteredReports;

    if (filteredReports.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('Nenhum usuário encontrado')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed:
                    () => PdfExportService.exportUserReportsProfessionalPdf(_filteredReports),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Exportar PDF Completo'),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Nome')),
                DataColumn(label: Text('Empresa')),
                DataColumn(label: Text('Pontos')),
                DataColumn(label: Text('Compras')),
                DataColumn(label: Text('Valor Total')),
                DataColumn(label: Text('Data da Compra')),
              ],
              rows:
                  filteredReports
                      .map(
                        (report) => DataRow(
                          cells: [
                            DataCell(Text(report.userName)),
                            DataCell(Text(report.favoriteStores.join(', '))),
                            DataCell(Text(formatPoints(report.totalPoints))),
                            DataCell(Text(report.totalPurchases.toString())),
                            DataCell(Text(formatCurrency(report.totalSpent))),
                            DataCell(Text(DateFormat('dd/MM/yyyy').format(report.createdAt))),
                          ],
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportStat {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  ReportStat({required this.title, required this.value, required this.icon, required this.color});
}
