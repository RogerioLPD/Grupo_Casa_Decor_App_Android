import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/web/widgets/animated_section.dart';

class BenefitsSection extends StatelessWidget {
  const BenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 20, vertical: 100),
      color: theme.colorScheme.surface,
      child: AnimatedSection(
        child: Column(
          children: [
            // Section Title
            Text(
              'BENEFÍCIOS EXCLUSIVOS',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Vantagens Premium para Arquitetos',
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),

            // Benefits Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount =
                    constraints.maxWidth > 900
                        ? 2
                        : constraints.maxWidth > 600
                        ? 2
                        : 1;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _BenefitCard(
                      icon: Icons.loyalty,
                      title: 'Pontos por Compra',
                      description:
                          'Acumule pontos a cada compra realizada em nossas lojas parceiras.',
                      color: theme.colorScheme.primary,
                    ),
                    _BenefitCard(
                      icon: Icons.card_giftcard,
                      title: 'Prêmios Exclusivos',
                      description:
                          'Resgate produtos únicos, ferramentas profissionais e experiências.',
                      color: theme.colorScheme.secondary,
                    ),
                    /* _BenefitCard(
                      icon: Icons.discount,
                      title: 'Descontos Especiais',
                      description:
                          'Acesso a descontos progressivos baseados no seu nível de pontuação.',
                      color: theme.colorScheme.tertiary,
                    ),
                    _BenefitCard(
                      icon: Icons.event,
                      title: 'Eventos VIP',
                      description: 'Convites para lançamentos, palestras e workshops exclusivos.',
                      color: theme.colorScheme.primary,
                    ),
                    _BenefitCard(
                      icon: Icons.support_agent,
                      title: 'Suporte Premium',
                      description: 'Atendimento prioritário e consultoria especializada.',
                      color: theme.colorScheme.secondary,
                    ),
                    _BenefitCard(
                      icon: Icons.trending_up,
                      title: 'Crescimento Profissional',
                      description:
                          'Acesso a conteúdos e ferramentas para desenvolvimento da carreira.',
                      color: theme.colorScheme.tertiary,
                    ),*/
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  State<_BenefitCard> createState() => _BenefitCardState();
}

class _BenefitCardState extends State<_BenefitCard> with SingleTickerProviderStateMixin {
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
      end: 0.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:
                      _isHovered
                          ? widget.color.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.08),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: Offset(0, _isHovered ? 10 : 5),
                ),
              ],
              border: Border.all(
                color:
                    _isHovered
                        ? widget.color.withValues(alpha: 0.3)
                        : theme.colorScheme.outline.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Container
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [widget.color, widget.color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  widget.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
