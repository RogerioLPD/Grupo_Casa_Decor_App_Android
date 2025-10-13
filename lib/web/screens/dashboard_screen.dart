import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/shared/services/list_report_controller.dart';
import 'package:nucleo_casa_decor_android/web/models/user_report.dart';
import 'package:nucleo_casa_decor_android/web/services/pdf_export_service.dart';
import 'package:nucleo_casa_decor_android/web/widgets/responsive_layout.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  final List<UserReport> _userReports = [];
  List<dynamic> _especificadores = [];
  List<dynamic> _filteredEspecificadores = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _filteredEmpresas = [];

  List<dynamic> _empresas = [];
  ReportService? _userService;

  //bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchUserReports();
    _userService = ReportService(context: context);
    _carregarEspecificadores();
    _carregarEmpresas();
  }

  Future<void> _carregarEspecificadores() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _userService?.fetchEspecificadores();

    if (result != null && mounted) {
      final list = result['list'];

      // 🔹 Extrair apenas os campos desejados do array retornado pela API
      final List<Map<String, dynamic>> especificadoresExtraidos = [];

      for (var item in list) {
        especificadoresExtraidos.add({
          'email': item['email'] ?? '',
          'nome': item['nome'] ?? '',
          'cnpj': item['cnpj'] ?? '',
          'cpf': item['cpf'] ?? '',
        });
      }

      setState(() {
        _especificadores = especificadoresExtraidos;
        _filteredEspecificadores = especificadoresExtraidos; // inicializa o filtro
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _carregarEmpresas() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _userService?.fetchEmpresas();

    if (result != null && mounted) {
      final list = result['list'];

      // 🔹 Extrair apenas os campos desejados do array retornado pela API
      final List<Map<String, dynamic>> empresasExtraidas = [];

      for (var item in list) {
        empresasExtraidas.add({
          'email': item['email'] ?? '',
          'nome': item['nome'] ?? '',
          'cnpj': item['cnpj'] ?? '',
          'cpf': item['cpf'] ?? '',
        });
      }

      setState(() {
        _empresas = empresasExtraidas;
        _filteredEmpresas = empresasExtraidas; // inicializa o filtro
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
        _initializeAnimations();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados: $e';
        _isLoading = false;
      });
    }
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      4,
      (index) =>
          AnimationController(duration: Duration(milliseconds: 600 + (index * 100)), vsync: this),
    );

    _animations =
        _animationControllers
            .map(
              (controller) => Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic)),
            )
            .toList();

    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _animationControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildStatsOverview(),
            const SizedBox(height: 32),
            _buildUserReportsList(),
            const SizedBox(height: 32),
            _buildEmpresasList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _animations[0],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _animations[0].value) * 50),
          child: Opacity(
            opacity: _animations[0].value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Visão geral do sistema de pontuação Grupo Casa Decor',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsOverview() {
    final totalEmpresas = _empresas.length;
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

    // 🔹 Cálculo de "Empresas Ativas" (Empresas com pelo menos uma compra)
    final Set<String> emailsComCompra1 = {};
    for (var report in _userReports) {
      if (report.companyEmail.isNotEmpty) {
        emailsComCompra.add(report.companyEmail.toLowerCase());
      }
    }

    final stats = [
      StatCard(
        title: 'Total de Arquitetos',
        value: totalEspecificadores.toString(),
        icon: Icons.people_alt_rounded,
        color: Colors.blue,
      ),
      StatCard(
        title: 'Empresas Parceiras',
        value: totalEmpresas.toString(),
        icon: Icons.business_rounded,
        color: Colors.green,
      ),
      StatCard(
        title: 'Volume de Vendas',
        value: formatCurrency(totalSpent),
        icon: Icons.card_giftcard_rounded,
        color: Colors.orange,
      ),
      StatCard(
        title: 'Pontos Distribuídos',
        value: formatPoints(totalPoints),
        icon: Icons.star_outline_rounded,
        color: Colors.purple,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = context.isMobile;
        final crossAxisCount = isSmallScreen ? 2 : 4;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isSmallScreen ? 1.2 : 1.4,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _animations[1],
              builder: (context, child) {
                return Transform.scale(
                  scale: _animations[1].value,
                  child: _buildStatCard(stats[index]),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(StatCard stat) {
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
          Row(
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
            ],
          ),
          const SizedBox(height: 16),
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

  Widget _buildUserReportsList() {
    if (_isLoading) {
      return Container(
        width: double.infinity,
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

    if (_filteredEspecificadores.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('Nenhum especificador encontrado')),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Lista de Arquitetos Cadastrados',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
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
                      _filteredEspecificadores =
                          _especificadores.where((item) {
                            final nome = (item['nome'] ?? '').toLowerCase();
                            final email = (item['email'] ?? '').toLowerCase();
                            final searchLower = value.toLowerCase();
                            return nome.contains(searchLower) || email.contains(searchLower);
                          }).toList();
                    });
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: isMobile ? 12 : 32,
                      headingRowColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.9),
                      ),
                      columns: const [
                        DataColumn(label: Text('Nome')),
                        DataColumn(label: Text('E-mail')),
                        DataColumn(label: Text('CNPJ')),
                        DataColumn(label: Text('CPF')),
                      ],
                      rows:
                          _filteredEspecificadores.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text(item['nome'] ?? '')),
                                DataCell(Text(item['email'] ?? '')),
                                DataCell(
                                  Text(item['cnpj']?.isNotEmpty == true ? item['cnpj'] : '-'),
                                ),
                                DataCell(Text(item['cpf']?.isNotEmpty == true ? item['cpf'] : '-')),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpresasList() {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_empresas.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('Nenhuma empresa encontrada')),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Lista de Empresas Cadastradas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
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
                      _filteredEmpresas =
                          _empresas.where((item) {
                            final nome = (item['nome'] ?? '').toLowerCase();
                            final email = (item['email'] ?? '').toLowerCase();
                            final searchLower = value.toLowerCase();
                            return nome.contains(searchLower) || email.contains(searchLower);
                          }).toList();
                    });
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: isMobile ? 12 : 32,
                      headingRowColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.9),
                      ),
                      columns: const [
                        DataColumn(label: Text('Nome')),
                        DataColumn(label: Text('E-mail')),
                        DataColumn(label: Text('CNPJ')),
                      ],
                      rows:
                          _filteredEmpresas.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text(item['nome'] ?? '')),
                                DataCell(Text(item['email'] ?? '')),
                                DataCell(Text(item['cpf']?.isNotEmpty == true ? item['cpf'] : '-')),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class StatCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  StatCard({required this.title, required this.value, required this.icon, required this.color});
}

class ReportStat {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  ReportStat({required this.title, required this.value, required this.icon, required this.color});
}
