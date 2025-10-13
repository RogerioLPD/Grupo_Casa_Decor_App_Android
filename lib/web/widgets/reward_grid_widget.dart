import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nucleo_casa_decor_android/mobile/models/reward.dart';
import 'package:nucleo_casa_decor_android/shared/services/rewards_controller.dart';

typedef OnDeleteCallback = void Function(RewardModel reward);

class RewardGridWidget extends StatefulWidget {
  final RewardsController controller;
  final double userPoints;
  final OnDeleteCallback? onDelete;

  const RewardGridWidget({
    super.key,
    required this.controller,
    required this.userPoints,
    this.onDelete,
  });

  @override
  State<RewardGridWidget> createState() => _RewardGridWidgetState();
}

class _RewardGridWidgetState extends State<RewardGridWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  List<RewardModel> _filteredRewards = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    widget.controller.fetchAwards().then((_) {
      _filteredRewards = widget.controller.awardsList.cast<RewardModel>().toList();
      _animationController.forward();
      setState(() {});
    });

    _searchController.addListener(() {
      _filterRewards(_searchController.text);
    });
  }

  void _filterRewards(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredRewards = widget.controller.awardsList.cast<RewardModel>().toList();
      });
    } else {
      setState(() {
        _filteredRewards =
            widget.controller.awardsList
                .cast<RewardModel>()
                .where(
                  (reward) =>
                      (reward.titulo ?? '').toLowerCase().contains(query.toLowerCase()) ||
                      (reward.descricao ?? '').toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      });
    }
    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (widget.controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (widget.controller.errorMessage.isNotEmpty) {
        return Center(child: Text(widget.controller.errorMessage.value));
      }
      if (_filteredRewards.isEmpty) {
        return const Center(child: Text('Nenhum prêmio encontrado.'));
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar prêmios...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredRewards.length,
              itemBuilder: (context, index) {
                final reward = _filteredRewards[index];
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final animationValue = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
                      ),
                    );

                    return Transform.scale(
                      scale: animationValue.value,
                      child: RewardCard(
                        reward: reward,
                        canRedeem: widget.userPoints >= (reward.pontos ?? 0),
                        onDelete: () async {
                          await widget.controller.deleteReward(reward);

                          setState(() {
                            _filteredRewards.remove(reward);
                            widget.controller.awardsList.remove(reward);
                          });

                          if (widget.onDelete != null) widget.onDelete!(reward);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class RewardCard extends StatelessWidget {
  final RewardModel reward;
  final bool canRedeem;
  final VoidCallback? onDelete;

  const RewardCard({super.key, required this.reward, required this.canRedeem, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: canRedeem ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap:
                canRedeem
                    ? () {
                      showDialog(
                        context: context,
                        builder: (context) => RewardDialog(reward: reward),
                      );
                    }
                    : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      reward.imagem1 ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.card_giftcard,
                            size: 32,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.titulo ?? '',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                canRedeem
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            reward.descricao ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  canRedeem
                                      ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: canRedeem ? theme.colorScheme.secondary : theme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${reward.pontos ?? 0} pts',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          canRedeem ? theme.colorScheme.onSecondary : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RewardDialog extends StatelessWidget {
  final RewardModel reward;

  const RewardDialog({super.key, required this.reward});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Resgatar Prêmio',
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Text('Este prêmio custará ${reward.pontos ?? 0} pontos.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Resgatar')),
      ],
    );
  }
}
