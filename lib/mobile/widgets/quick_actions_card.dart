import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nucleo_casa_decor_android/shared/services/rewards_controller.dart';
import 'package:nucleo_casa_decor_android/mobile/models/reward.dart';

class QuickActionsCard extends StatefulWidget {
  const QuickActionsCard({super.key});

  @override
  State<QuickActionsCard> createState() => _QuickActionsCardState();
}

class _QuickActionsCardState extends State<QuickActionsCard> with TickerProviderStateMixin {
  final RewardsController _controller = Get.put(RewardsController());
  late AnimationController _animationController;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pageController = PageController(viewportFraction: 0.75);

    _controller.fetchAwards().then((_) {
      if (mounted) {
        _animationController.forward();
        _startAutoScroll();
        setState(() {});
      }
    });
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (!mounted) return;
      final itemCount = _controller.awardsList.length;
      if (itemCount == 0) return;

      _currentPage = (_currentPage + 1) % itemCount;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Destaques para você',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: Obx(() {
            if (_controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = _controller.awardsList.cast<RewardModel>();

            if (items.isEmpty) {
              return const Center(child: Text('Nenhum destaque disponível.'));
            }

            return PageView.builder(
              controller: _pageController,
              itemCount: items.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final reward = items[index];
                final isActive = index == _currentPage;

                final scale = isActive ? 1.0 : 0.85;
                final opacity = isActive ? 1.0 : 0.6;

                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final animationValue = Tween<double>(begin: 0.9, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval((index * 0.1).clamp(0.0, 1.0), 1.0, curve: Curves.easeOut),
                      ),
                    );

                    return Transform.scale(
                      scale: scale * animationValue.value,
                      child: Opacity(
                        opacity: opacity,
                        child: GestureDetector(
                          onTap: () => _showRewardDetails(context, reward),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                if (isActive)
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      reward.imagem1 ?? '',
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Icon(
                                            Icons.card_giftcard,
                                            size: 32,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  reward.titulo ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '${reward.pontos!.toStringAsFixed(2)} pts',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
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
          }),
        ),
      ],
    );
  }

  void _showRewardDetails(BuildContext context, RewardModel reward) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              reward.titulo ?? 'Detalhes',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            content: Text(reward.descricao ?? 'Sem descrição disponível.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
            ],
          ),
    );
  }
}
