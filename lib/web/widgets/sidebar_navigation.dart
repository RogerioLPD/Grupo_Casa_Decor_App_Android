import 'package:flutter/material.dart';

class SidebarNavigation extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const SidebarNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<SidebarNavigation> createState() => _SidebarNavigationState();
}

class _SidebarNavigationState extends State<SidebarNavigation> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      index: 0,
    ),
    NavigationItem(
      icon: Icons.business_rounded,
      label: 'Empresas',
      index: 1,
    ),
    NavigationItem(
      icon: Icons.card_giftcard_rounded,
      label: 'Prêmios',
      index: 2,
    ),
    NavigationItem(
      icon: Icons.analytics_rounded,
      label: 'Relatórios',
      index: 3,
    ),
    NavigationItem(
      icon: Icons.analytics_rounded,
      label: 'Relatórios Empresas',
      index: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      _navigationItems.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 200 + (index * 50)),
        vsync: this,
      ),
    );

    _animations = _animationControllers
        .map((controller) => Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutBack,
            )))
        .toList();

    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: _buildNavigationItems(theme),
          ),
          _buildFooter(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.home_work_rounded,
              color: theme.colorScheme.onPrimary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Grupo Casa Decor',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Sistema de Pontuação',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItems(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _navigationItems.length,
      itemBuilder: (context, index) {
        final item = _navigationItems[index];
        final isSelected = widget.selectedIndex == item.index;

        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset((1 - _animations[index].value) * 100, 0),
              child: Opacity(
                opacity: _animations[index].value,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => widget.onItemTapped(item.index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item.icon,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item.label,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onPrimaryContainer,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
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

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Divider(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'v1.0.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final int index;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}
