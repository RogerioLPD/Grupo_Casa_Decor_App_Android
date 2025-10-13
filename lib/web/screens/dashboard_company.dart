import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/shared/services/list_report_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:nucleo_casa_decor_android/web/models/user_report.dart';
import 'package:nucleo_casa_decor_android/web/widgets/animated_card.dart';
import 'package:intl/intl.dart';

class DashboardCompany extends StatefulWidget {
  const DashboardCompany({super.key});

  @override
  State<DashboardCompany> createState() => _DashboardCompanyState();
}

class _DashboardCompanyState extends State<DashboardCompany> {
  final List<UserReport> _userReports = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserReportsWithEmpresas();
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(theme, isDesktop),
          const SizedBox(height: 32),
          _buildRecentTransactions(theme, isDesktop),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, bool isDesktop) {
    return GradientCard(
      gradientColors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
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
                              color: theme.colorScheme.onPrimary, // cor do texto normal
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

  /// 🔹 Agora exibe dados reais vindos da API
  Widget _buildRecentTransactions(ThemeData theme, bool isDesktop) {
    if (_userReports.isEmpty) {
      return Center(
        child: Text('Nenhuma transação encontrada.', style: theme.textTheme.bodyMedium),
      );
    }

    final recentReports = [..._userReports]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final lastFive = recentReports.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📊 Transações Recentes',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        AnimatedCard(
          child: Column(
            children:
                lastFive.asMap().entries.map((entry) {
                  final index = entry.key;
                  final report = entry.value;

                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 200 + (index * 100)),
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
                            index != lastFive.length - 1
                                ? Border(
                                  bottom: BorderSide(
                                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                                  ),
                                )
                                : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report.userName,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                /* Text(
                              report.favoriteStores.isNotEmpty
                                  ? report.favoriteStores.first
                                  : 'Empresa desconhecida',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),*/
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                report.companySegment ?? 'Não informado',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM/yyyy').format(report.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });
}
