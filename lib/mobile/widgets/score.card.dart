import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/shared/services/specifier_controller.dart';
import 'package:nucleo_casa_decor_android/mobile/models/transaction.dart';
import 'package:nucleo_casa_decor_android/shared/services/releases_controller.dart';

class ScoreCard extends StatefulWidget {
  final SpecifierController controller;

  const ScoreCard({super.key, required this.controller});

  @override
  State<ScoreCard> createState() => _ScoreCardState();
}

class _ScoreCardState extends State<ScoreCard> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  final ReleasesController _releasesController = ReleasesController();

  double _todayPoints = 0.0; // ✅ agora é double

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _rotationController = AnimationController(duration: const Duration(seconds: 20), vsync: this);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _rotationController, curve: Curves.linear));

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();

    widget.controller.initValues();

    _loadTodayPoints();
  }

  Future<void> _loadTodayPoints() async {
    try {
      List<PointTransaction> transactions = await _releasesController.fetchTransactions();
      final now = DateTime.now();

      final todayTransactions = transactions.where(
        (t) => t.date.year == now.year && t.date.month == now.month && t.date.day == now.day,
      );

      // ✅ fold agora com double
      final totalTodayPoints = todayTransactions.fold<double>(0.0, (sum, t) => sum + t.points);

      if (mounted) {
        setState(() {
          _todayPoints = totalTodayPoints;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao carregar pontos do dia: $e");
      }
      // Opcional: você pode tratar erro aqui para mostrar mensagem na UI, etc.
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<double>(
      stream: widget.controller.pointsController.stream,
      builder: (context, snapshot) {
        final totalPoints = snapshot.data ?? 0.0;
        final formattedPoints = double.parse(
          totalPoints.toStringAsFixed(2),
        ); // ✅ Garante 2 casas decimais
        final userLevel = _getUserLevel(formattedPoints);

        final todayPoints = _todayPoints;

        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.secondary.withAlpha(204), // alpha ~0.8
                    ],
                    //begin: Alignment.topLeft,
                    //end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha(77), // alpha ~0.3
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: theme.colorScheme.secondary.withAlpha(51), // alpha ~0.2
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sua Pontuação',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onPrimary.withAlpha(230),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  totalPoints.toStringAsFixed(2),
                                  style: theme.textTheme.displayMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'pontos',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary.withAlpha(204),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            AnimatedBuilder(
                              animation: _rotationAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotationAnimation.value * 2 * 3.14159,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.onPrimary.withAlpha(51),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.colorScheme.onPrimary.withAlpha(77),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.stars,
                                      size: 40,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onPrimary.withAlpha(38),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.colorScheme.onPrimary.withAlpha(51)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    color: theme.colorScheme.secondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Nível $userLevel',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '+$todayPoints hoje',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  int _getUserLevel(double totalPoints) {
    if (totalPoints >= 1000) return 5;
    if (totalPoints >= 750) return 4;
    if (totalPoints >= 500) return 3;
    if (totalPoints >= 250) return 2;
    return 1;
  }
}
