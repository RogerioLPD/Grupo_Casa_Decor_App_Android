import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/shared/screens/login.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Container(
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
            theme.colorScheme.secondary.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/Fundo.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.transparent),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 20, vertical: 40),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  Expanded(
                    child: Row(
                      children: [
                        // Left Content
                        Expanded(
                          flex: isDesktop ? 6 : 10,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildAnimatedText(
                                    'GRUPO CASA DECOR',
                                    theme.textTheme.headlineSmall?.copyWith(
                                      color: theme.colorScheme.secondary,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    0,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildAnimatedText(
                                    'Sistema de\nPontuação Exclusivo',
                                    theme.textTheme.displayMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                                    200,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildAnimatedText(
                                    'Transforme suas compras em recompensas exclusivas.\nAcumule pontos em lojas parceiras e desbloqueie\num mundo de benefícios premium.',
                                    theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      height: 1.6,
                                    ),
                                    400,
                                  ),
                                  const SizedBox(height: 40),
                                  _buildAnimatedButton(600),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Right Content (Desktop only)
                        if (isDesktop) ...[
                          const SizedBox(width: 40),
                          Expanded(
                            flex: 4,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: _HeroImageWidget(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Scroll Indicator
                  _buildScrollIndicator(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedText(String text, TextStyle? style, int delay) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
          child: Opacity(opacity: _fadeAnimation.value, child: Text(text, style: style)),
        );
      },
    );
  }

  Widget _buildAnimatedButton(int delay) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Row(
              children: [
                _HeroButton(
                  text: 'Começar Agora',
                  isPrimary: true,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrollIndicator(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Role para descobrir',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 10 * (1 - _fadeAnimation.value)),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withValues(alpha: 0.7),
                size: 24,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HeroButton extends StatefulWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _HeroButton({required this.text, required this.isPrimary, required this.onPressed});

  @override
  State<_HeroButton> createState() => _HeroButtonState();
}

class _HeroButtonState extends State<_HeroButton> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut));
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
        _hoverController.forward();
      },
      onExit: (_) {
        _hoverController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isPrimary ? theme.colorScheme.secondary : Colors.transparent,
            foregroundColor: widget.isPrimary ? Colors.white : theme.colorScheme.secondary,
            side:
                widget.isPrimary ? null : BorderSide(color: theme.colorScheme.secondary, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: widget.isPrimary ? 8 : 0,
          ),
          child: Text(
            widget.text,
            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _HeroImageWidget extends StatefulWidget {
  @override
  State<_HeroImageWidget> createState() => _HeroImageWidgetState();
}

class _HeroImageWidgetState extends State<_HeroImageWidget> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(duration: const Duration(seconds: 3), vsync: this);
    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/logolanding.png',
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 450,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.home_work, size: 100, color: Colors.white),
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}
