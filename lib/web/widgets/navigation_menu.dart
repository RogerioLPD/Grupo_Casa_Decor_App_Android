import 'package:flutter/material.dart';

class NavigationMenu extends StatefulWidget {
  final Function(int) onNavigate;
  final ScrollController scrollController;

  const NavigationMenu({
    super.key,
    required this.onNavigate,
    required this.scrollController,
  });

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isScrolled = false;
  bool _isMobileMenuOpen = false;

  final List<String> _menuItems = [
    'Início',
    'Sobre',
    'Como Funciona',
    'Parceiros',
    'Prêmios',
    'Contato',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final bool isScrolled = widget.scrollController.offset > 50;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

  void _toggleMobileMenu() {
    setState(() {
      _isMobileMenuOpen = !_isMobileMenuOpen;
    });
    if (_isMobileMenuOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 1050;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 80,
      decoration: BoxDecoration(
        color: _isScrolled ? theme.colorScheme.surface.withValues(alpha: 0.95) : Colors.transparent,
        boxShadow: _isScrolled
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Logo
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.home_work,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Grupo Casa Decor',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _isScrolled ? theme.colorScheme.onSurface : Colors.white,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Desktop Menu
              if (isDesktop) ...[
                Row(
                  children: _menuItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _MenuButton(
                        text: item,
                        onPressed: () => widget.onNavigate(index),
                        isScrolled: _isScrolled,
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                // Mobile Menu Button
                IconButton(
                  onPressed: _toggleMobileMenu,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isMobileMenuOpen ? Icons.close : Icons.menu,
                      key: ValueKey(_isMobileMenuOpen),
                      color: _isScrolled ? theme.colorScheme.onSurface : Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isScrolled;

  const _MenuButton({
    required this.text,
    required this.onPressed,
    required this.isScrolled,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: TextButton(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor:
                _isHovered ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            widget.text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: widget.isScrolled
                  ? (_isHovered ? theme.colorScheme.primary : theme.colorScheme.onSurface)
                  : (_isHovered ? theme.colorScheme.secondary : Colors.white),
              fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
