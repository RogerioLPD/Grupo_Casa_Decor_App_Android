import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/mobile/models/transaction.dart';
import 'package:nucleo_casa_decor_android/shared/services/releases_controller.dart';
import 'package:nucleo_casa_decor_android/shared/services/specifier_controller.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  final SpecifierController controller;

  const TransactionsScreen({super.key, required this.controller});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Future<List<PointTransaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();

    _transactionsFuture = ReleasesController().fetchTransactions();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    // Inicializa os streams do controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.initValues();
    });
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
        title: Text(
          'Extrato de Pontos',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- Saldo Total ---
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withAlpha(80),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<double>(
                  stream: widget.controller.pointsController.stream,
                  initialData: widget.controller.pointsController.valueOrNull ?? 0.0,
                  builder: (context, snapshot) {
                    final points = snapshot.data ?? 0.0;
                    final displayPoints = ((points * 100).truncate() / 100).toStringAsFixed(2);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saldo Total',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withAlpha(200),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$displayPoints pts',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Icon(
                  Icons.account_balance_wallet,
                  size: 40,
                  color: theme.colorScheme.onPrimary.withAlpha(200),
                ),
              ],
            ),
          ),

          // --- Lista de Transações ---
          Expanded(
            child: FutureBuilder<List<PointTransaction>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final transactions = snapshot.data ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];

                    // Animação para cada item
                    final animationValue = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(index * 0.05, 1.0, curve: Curves.easeOut),
                      ),
                    );

                    return AnimatedBuilder(
                      animation: animationValue,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - animationValue.value)),
                          child: Opacity(
                            opacity: animationValue.value,
                            child: TransactionCard(transaction: transaction),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final PointTransaction transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEarned = transaction.type == TransactionType.earned;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isEarned
                          ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                          : theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isEarned ? Icons.store : Icons.remove,
                  color: isEarned ? theme.colorScheme.secondary : theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transaction.companyName} • ${DateFormat('dd/MM/yyyy').format(transaction.date)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isEarned ? '+' : '-'}${transaction.valor} pts',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isEarned ? theme.colorScheme.secondary : theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
