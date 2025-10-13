import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/web/widgets/animated_section.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1000;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 20, vertical: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.9),
            theme.colorScheme.secondary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: AnimatedSection(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Main CTA Section (Desktop: Text + Stats | Image)
              if (isDesktop)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left Column: Text + Stats
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PRONTO PARA COMEÇAR?',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Transforme Suas Compras\nem Recompensas Exclusivas',
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Junte-se a centenas de arquitetos que já descobriram o poder do nosso sistema de pontuação. Cadastre-se gratuitamente e comece a acumular pontos hoje mesmo.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                _CTAButton(
                                  text: 'Cadastrar Agora',
                                  isPrimary: true,
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 16),
                                _CTAButton(
                                  text: 'Falar com Consultor',
                                  isPrimary: false,
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: const Column(
                                children: [
                                  _StatItem(
                                    icon: Icons.people,
                                    number: '500+',
                                    label: 'Arquitetos Cadastrados',
                                  ),
                                  SizedBox(height: 24),
                                  _StatItem(
                                    icon: Icons.store,
                                    number: '50+',
                                    label: 'Lojas Parceiras',
                                  ),
                                  SizedBox(height: 24),
                                  _StatItem(
                                    icon: Icons.card_giftcard,
                                    number: '1000+',
                                    label: 'Prêmios Resgatados',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 60),

                      // Right Column: Image
                      Expanded(
                        flex: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset('assets/images/contato.jpg', fit: BoxFit.cover),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    // Mobile layout: Text + Stats + Image
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRONTO PARA COMEÇAR?',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Transforme Suas Compras\nem Recompensas Exclusivas',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Junte-se a centenas de arquitetos que já descobriram o poder do nosso sistema de pontuação. Cadastre-se gratuitamente e comece a acumular pontos hoje mesmo.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            _CTAButton(text: 'Cadastrar Agora', isPrimary: true, onPressed: () {}),
                            const SizedBox(width: 16),
                            _CTAButton(
                              text: 'Falar com Consultor',
                              isPrimary: false,
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        const _StatItem(
                          icon: Icons.people,
                          number: '500+',
                          label: 'Arquitetos Cadastrados',
                        ),
                        const SizedBox(height: 24),
                        const _StatItem(icon: Icons.store, number: '50+', label: 'Lojas Parceiras'),
                        const SizedBox(height: 24),
                        const _StatItem(
                          icon: Icons.card_giftcard,
                          number: '1000+',
                          label: 'Prêmios Resgatados',
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset('assets/images/contato.jpg', fit: BoxFit.contain),
                    ),
                  ],
                ),

              const SizedBox(height: 60),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© 2025 ComCode Fábrica de Softwares e Aplicativos. Todos os direitos reservados.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const Row(
                    children: [
                      _SocialButton(icon: Icons.facebook),
                      SizedBox(width: 12),
                      _SocialButton(icon: Icons.link),
                      SizedBox(width: 12),
                      _SocialButton(icon: Icons.email),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// As outras classes (_CTAButton, _StatItem, _SocialButton) permanecem como no seu código original.

class _CTAButton extends StatefulWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _CTAButton({required this.text, required this.isPrimary, required this.onPressed});

  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
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
        _controller.forward();
      },
      onExit: (_) {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isPrimary ? Colors.white : Colors.transparent,
            foregroundColor: widget.isPrimary ? theme.colorScheme.primary : Colors.white,
            side: widget.isPrimary ? null : const BorderSide(color: Colors.white, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;

  const _StatItem({required this.icon, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String info;

  const _ContactCard({required this.icon, required this.title, required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          info,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SocialButton extends StatefulWidget {
  final IconData icon;

  const _SocialButton({required this.icon});

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                _isHovered
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
