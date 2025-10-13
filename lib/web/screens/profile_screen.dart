import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nucleo_casa_decor_android/web/models/client.dart';
import 'package:nucleo_casa_decor_android/web/services/client_provider.dart';
import 'package:nucleo_casa_decor_android/web/widgets/animated_card.dart';

class ProfileScreenClients extends ConsumerStatefulWidget {
  const ProfileScreenClients({super.key});

  @override
  ConsumerState<ProfileScreenClients> createState() => _ProfileScreenClientsState();
}

class _ProfileScreenClientsState extends ConsumerState<ProfileScreenClients>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Client> _getFilteredClients(List<Client> clients) {
    switch (_selectedFilter) {
      case 'top':
        final sorted = [...clients]..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
        return sorted.take(10).toList();
      case 'recent':
        return clients.where((client) {
          final hasRecentTransaction = client.transactions.any(
            (tx) => DateTime.now().difference(tx.date).inDays <= 30,
          );
          return hasRecentTransaction;
        }).toList();
      default:
        return clients;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientProvider);
    final filteredClients = _getFilteredClients(clients);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, isDesktop),
              const SizedBox(height: 32),
              _buildStatsOverview(clients, theme, isDesktop),
              const SizedBox(height: 32),
              _buildFilterSection(theme),
              const SizedBox(height: 24),
              _buildClientsList(filteredClients, theme, isDesktop, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDesktop) {
    return GradientCard(
      gradientColors: [
        theme.colorScheme.tertiary,
        theme.colorScheme.tertiary.withValues(alpha: 0.8),
      ],
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👤 Perfil dos Clientes',
                  style: (isDesktop ? theme.textTheme.headlineMedium : theme.textTheme.titleLarge)
                      ?.copyWith(color: theme.colorScheme.onTertiary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Visualize e gerencie informações dos arquitetos cadastrados',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onTertiary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.onTertiary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group_rounded,
              size: isDesktop ? 48 : 32,
              color: theme.colorScheme.onTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(List<Client> clients, ThemeData theme, bool isDesktop) {
    final totalPoints = clients.fold<double>(0, (sum, client) => sum + client.totalPoints);
    final avgPoints = clients.isNotEmpty ? totalPoints / clients.length : 0;
    final activeClients =
        clients.where((client) {
          return client.transactions.any((tx) => DateTime.now().difference(tx.date).inDays <= 30);
        }).length;

    final stats = [
      _StatCard(
        title: 'Total de Clientes',
        value: clients.length.toString(),
        icon: Icons.people_rounded,
        color: theme.colorScheme.primary,
        subtitle: 'Arquitetos cadastrados',
      ),
      _StatCard(
        title: 'Clientes Ativos',
        value: activeClients.toString(),
        icon: Icons.trending_up_rounded,
        color: Colors.green,
        subtitle: 'Últimos 30 dias',
      ),
      _StatCard(
        title: 'Média de Pontos',
        value: avgPoints.toStringAsFixed(1),
        icon: Icons.stars_rounded,
        color: theme.colorScheme.tertiary,
        subtitle: 'Por cliente',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 1.5 : 3,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: AnimatedCard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: stat.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(stat.icon, size: isDesktop ? 32 : 24, color: stat.color),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      stat.value,
                      style: (isDesktop
                              ? theme.textTheme.headlineMedium
                              : theme.textTheme.headlineSmall)
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      stat.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    final filters = [
      const _FilterOption(id: 'all', label: 'Todos', icon: Icons.list_rounded),
      const _FilterOption(id: 'top', label: 'Top 10', icon: Icons.emoji_events_rounded),
      const _FilterOption(id: 'recent', label: 'Ativos', icon: Icons.schedule_rounded),
    ];

    return Row(
      children: [
        Text(
          'Filtros:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  filters.map((filter) {
                    final isSelected = _selectedFilter == filter.id;
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        selected: isSelected,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              filter.icon,
                              size: 16,
                              color:
                                  isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              filter.label,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.primary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilter = filter.id;
                            });
                          }
                        },
                        backgroundColor: theme.colorScheme.surface,
                        selectedColor: theme.colorScheme.primary,
                        checkmarkColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientsList(List<Client> clients, ThemeData theme, bool isDesktop, bool isTablet) {
    if (clients.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum cliente encontrado',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📋 Lista de Clientes (${clients.length})',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        if (isDesktop || isTablet)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isDesktop ? 2.5 : 2,
            ),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              return _buildClientCard(clients[index], theme, index);
            },
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildClientCard(clients[index], theme, index),
              );
            },
          ),
      ],
    );
  }

  Widget _buildClientCard(Client client, ThemeData theme, int index) {
    final lastTransaction =
        client.transactions.isNotEmpty
            ? client.transactions.reduce((a, b) => a.date.isAfter(b.date) ? a : b)
            : null;

    final totalAmount = client.transactions.fold<double>(0, (sum, tx) => sum + tx.amount);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: AnimatedCard(
              onTap: () => _showClientDetails(client, theme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          client.name.split(' ').map((e) => e[0]).take(2).join(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              client.cpfCnpj,
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildClientStat(
                          icon: Icons.receipt_rounded,
                          label: 'Transações',
                          value: client.transactions.length.toString(),
                          theme: theme,
                        ),
                      ),
                      Expanded(
                        child: _buildClientStat(
                          icon: Icons.monetization_on_rounded,
                          label: 'Volume Total',
                          value: 'R\$ ${(totalAmount / 1000).toStringAsFixed(0)}k',
                          theme: theme,
                        ),
                      ),
                      if (lastTransaction != null)
                        Expanded(
                          child: _buildClientStat(
                            icon: Icons.schedule_rounded,
                            label: 'Última Compra',
                            value: _formatDate(lastTransaction.date),
                            theme: theme,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClientStat({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showClientDetails(Client client, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.3,
            expand: false,
            builder:
                (context, scrollController) =>
                    _buildClientDetailsSheet(client, theme, scrollController),
          ),
    );
  }

  Widget _buildClientDetailsSheet(
    Client client,
    ThemeData theme,
    ScrollController scrollController,
  ) {
    final sortedTransactions = [...client.transactions]..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  client.name.split(' ').map((e) => e[0]).take(2).join(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      client.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        client.totalPoints.toStringAsFixed(1),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Pontos Totais',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${client.transactions.length}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      Text(
                        'Transações',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Histórico de Transações',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: sortedTransactions.length,
              itemBuilder: (context, index) {
                final transaction = sortedTransactions[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.green, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _formatDate(transaction.date),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+${transaction.pointsEarned.toStringAsFixed(1)} pts',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'R\$ ${transaction.amount.toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hoje';
    } else if (diff.inDays == 1) {
      return 'Ontem';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _StatCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });
}

class _FilterOption {
  final String id;
  final String label;
  final IconData icon;

  const _FilterOption({required this.id, required this.label, required this.icon});
}
