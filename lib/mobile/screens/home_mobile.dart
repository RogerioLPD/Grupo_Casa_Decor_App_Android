import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nucleo_casa_decor_android/mobile/models/transaction.dart';
import 'package:nucleo_casa_decor_android/mobile/models/user_details.dart';
import 'package:nucleo_casa_decor_android/shared/services/releases_controller.dart';
import 'package:nucleo_casa_decor_android/shared/services/specifier_controller.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/recent_activity_card.dart';
import '../widgets/score.card.dart';

class HomeMobileScreen extends StatefulWidget {
  final SpecifierController controller;

  const HomeMobileScreen({super.key, required this.controller});

  @override
  State<HomeMobileScreen> createState() => _HomeMobileScreenState();
}

class _HomeMobileScreenState extends State<HomeMobileScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Future<List<PointTransaction>>? _transactionsFuture;

  @override
  void initState() {
    super.initState();

    widget.controller.initValues();

    _transactionsFuture = ReleasesController().fetchTransactions();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<UserDetails?>(
              stream: widget.controller.userController.stream,
              builder: (context, snapshot) {
                final nome =
                    snapshot.hasData
                        ? snapshot.data!.nome?.split(' ').first ?? 'Usuário'
                        : 'Usuário';
                return Text(
                  'Olá, $nome!',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                );
              },
            ),
            Text(
              'Bem-vindo ao Grupo Casa Decor',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(179),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: theme.colorScheme.primary),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _transactionsFuture = ReleasesController().fetchTransactions();
          });
          _animationController.reset();
          _animationController.forward();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScoreCard(controller: widget.controller),
                      const SizedBox(height: 24),
                      const QuickActionsCard(),
                      const SizedBox(height: 24),
                      Text(
                        'Atividade Recente',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<PointTransaction>>(
                        future: _transactionsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(child: Text('Erro: ${snapshot.error}'));
                          }

                          final transactions = snapshot.data ?? [];
                          transactions.sort((a, b) => b.date.compareTo(a.date));
                          final recentTransactions = transactions.take(3).toList();

                          return Column(
                            children:
                                recentTransactions.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final transaction = entry.value;

                                  return TweenAnimationBuilder<double>(
                                    duration: Duration(milliseconds: 300 + (index * 100)),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: Opacity(
                                          opacity: value,
                                          child: RecentActivityCard(
                                            transaction: transaction,
                                            index: index,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
