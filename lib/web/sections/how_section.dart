import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/web/widgets/animated_section.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 20, vertical: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primaryContainer.withAlpha(25), theme.colorScheme.surface],
        ),
      ),
      child: AnimatedSection(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'COMO FUNCIONA',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Processo Simples em 4 Passos',
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            isDesktop ? _buildDesktopSteps(theme) : _buildMobileSteps(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSteps(ThemeData theme) {
    return Wrap(
      spacing: 20,
      runSpacing: 40,
      alignment: WrapAlignment.center,
      children: [
        _StepCard(
          step: 1,
          title: 'Cadastre-se',
          description:
              'Crie sua conta gratuita e comprove sua qualificação como arquiteto profissional.',
          icon: Icons.person_add,
          theme: theme,
        ),
        _StepCard(
          step: 2,
          title: 'Especifique nas Lojas',
          description: 'Especifique em lojas parceiras e apresente seu código de identificação.',
          icon: Icons.shopping_bag,
          theme: theme,
        ),
        _StepCard(
          step: 3,
          title: 'Acumule Pontos',
          description: 'Receba pontos automaticamente baseados no valor das suas especificações.',
          icon: Icons.stars,
          theme: theme,
        ),
        _StepCard(
          step: 4,
          title: 'Resgate Pontos',
          description: 'Troque seus pontos por experiências únicas.',
          icon: Icons.redeem,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildMobileSteps(ThemeData theme) {
    return Column(
      children: [
        _StepCard(
          step: 1,
          title: 'Cadastre-se',
          description:
              'Crie sua conta gratuita e comprove sua qualificação como arquiteto profissional.',
          icon: Icons.person_add,
          theme: theme,
          isMobile: true,
        ),
        const SizedBox(height: 30),
        _StepCard(
          step: 2,
          title: 'Compre nas Lojas',
          description:
              'Realize compras em nossas lojas parceiras e apresente seu código de identificação.',
          icon: Icons.shopping_bag,
          theme: theme,
          isMobile: true,
        ),
        const SizedBox(height: 30),
        _StepCard(
          step: 3,
          title: 'Acumule Pontos',
          description: 'Receba pontos automaticamente baseados no valor das suas compras.',
          icon: Icons.stars,
          theme: theme,
          isMobile: true,
        ),
        const SizedBox(height: 30),
        _StepCard(
          step: 4,
          title: 'Resgate Prêmios',
          description:
              'Troque seus pontos por produtos exclusivos, descontos ou experiências únicas.',
          icon: Icons.redeem,
          theme: theme,
          isMobile: true,
        ),
      ],
    );
  }
}

class _StepCard extends StatefulWidget {
  final int step;
  final String title;
  final String description;
  final IconData icon;
  final ThemeData theme;
  final bool isMobile;

  const _StepCard({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    required this.theme,
    this.isMobile = false,
  });

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Transform.rotate(
          angle: _rotateAnimation.value,
          child: Container(
            width: widget.isMobile ? double.infinity : 250,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: widget.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:
                      _isHovered
                          ? widget.theme.colorScheme.primary.withAlpha(50)
                          : Colors.black.withAlpha(20),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color:
                    _isHovered
                        ? widget.theme.colorScheme.primary.withAlpha(80)
                        : widget.theme.colorScheme.primary.withAlpha(30),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.theme.colorScheme.primary,
                        widget.theme.colorScheme.secondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.theme.colorScheme.primary.withAlpha(80),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${widget.step}',
                      style: widget.theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.theme.colorScheme.primaryContainer.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, size: 40, color: widget.theme.colorScheme.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: widget.theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: widget.theme.colorScheme.onSurface.withAlpha(180),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return widget.isMobile ? card : SizedBox(width: 250, child: card);
  }
}
