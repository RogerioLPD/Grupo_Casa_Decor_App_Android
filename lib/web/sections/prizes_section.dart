import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/web/widgets/animated_section.dart';

class PrizesSection extends StatelessWidget {
  const PrizesSection({super.key});

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
              'PRÊMIOS EXCLUSIVOS',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Recompensas que Inspiram',
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Descubra uma seleção cuidadosa de prêmios pensados especialmente para arquitetos ambiciosos.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),

            // Featured Prize
            _FeaturedPrize(),

            const SizedBox(height: 60),

            // Expandable Grid
            const _ExpandablePrizesGrid(),
          ],
        ),
      ),
    );
  }
}

class _ExpandablePrizesGrid extends StatefulWidget {
  const _ExpandablePrizesGrid();

  @override
  State<_ExpandablePrizesGrid> createState() => _ExpandablePrizesGridState();
}

class _ExpandablePrizesGridState extends State<_ExpandablePrizesGrid>
    with SingleTickerProviderStateMixin {
  bool _showAllPrizes = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            constraints.maxWidth > 900
                ? 3
                : constraints.maxWidth > 600
                ? 2
                : 1;

        final prizesToShow =
            _showAllPrizes ? _prizes : _prizes.take(crossAxisCount * 2).toList(); // 2 linhas apenas

        return Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: prizesToShow.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemBuilder: (context, index) {
                  final prize = prizesToShow[index];
                  return _PrizeCard(
                    title: prize['title'],
                    description: prize['description'],
                    points: prize['points'],
                    imageAsset: prize['imageAsset'],
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showAllPrizes = !_showAllPrizes;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_showAllPrizes ? 'Ver menos' : 'Ver tudo'),
            ),
          ],
        );
      },
    );
  }
}

final List<Map<String, dynamic>> _prizes = [
  {
    'title': 'Curso de Projetos Luminotécnicos',
    'description': 'Essência da Luz:da ideia ao impacto',
    'points': '200 pontos',
    'imageAsset': 'assets/images/iluminotecnico.png',
  },
  {
    'title': 'Hotel Pulso - São Paulo',
    'description': 'Pulso Criativo:24h na Capital do Design',
    'points': '400 pontos',
    'imageAsset': 'assets/images/pulso.jpg',
  },
  {
    'title': 'Inhotim - Belo Horizonte',
    'description': 'Arte Viva: Um Mergulho Sensorial em Inhotim',
    'points': '500 pontos',
    'imageAsset': 'assets/images/Inhotim.jpg',
  },
  {
    'title': 'Hotel Fazenda Dona Carolina',
    'description': 'Campo & Conforto:Tradição com Elegância',
    'points': '600 pontos',
    'imageAsset': 'assets/images/donacarolina.jpg',
  },
  {
    'title': 'Brasília - Arquitetura e Design',
    'description': 'Brasília em Traço Contínuo: O Desenho de um Sonho Moderno',
    'points': '600 pontos',
    'imageAsset': 'assets/images/brasilia.jpg',
  },
  {
    'title': 'Rio de Janeiro',
    'description': 'Entre Morros e Mar:Inspiração Carioca',
    'points': '600 pontos',
    'imageAsset': 'assets/images/rio.jpg',
  },
  {
    'title': 'Ritz Barra de São Miguel',
    'description': 'Arquitetura Tropical: Um Roteiro à Luz do Sol',
    'points': '2,000 pontos',
    'imageAsset': 'assets/images/barrasm.jpg',
  },
  {
    'title': 'Santiago',
    'description': 'Entre Andes & Aquarelas:Essência Sul-Americana',
    'points': '800 pontos',
    'imageAsset': 'assets/images/santiago.jpg',
  },
  {
    'title': 'Mendoza',
    'description': 'Design & Degustação:Vinhos com História',
    'points': '1,000 pontos',
    'imageAsset': 'assets/images/mendoza.jpg',
  },
  {
    'title': 'Roma',
    'description': 'Clássico Eterno: Traços da Arquitetura Universal',
    'points': '1,900 pontos',
    'imageAsset': 'assets/images/roma.jpg',
  },
  {
    'title': 'Istambul',
    'description': 'Cúpulas & Contrastes:Inspiração entre Oriente e Ocidente',
    'points': '2,000 pontos',
    'imageAsset': 'assets/images/istambul.jpg',
  },
  {
    'title': 'Berlim',
    'description': 'Arquitetura da Liberdade:Um Encontro com o Design Moderno',
    'points': '2,200 pontos',
    'imageAsset': 'assets/images/berlim.jpg',
  },
];

class _FeaturedPrize extends StatefulWidget {
  @override
  State<_FeaturedPrize> createState() => _FeaturedPrizeState();
}

class _FeaturedPrizeState extends State<_FeaturedPrize> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left Content
                Expanded(
                  flex: isDesktop ? 6 : 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'PRÊMIO DESTAQUE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Carmel Charme Aquiraz - Ceará',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Essência do Refúgio:Charme e Design à Beira-Mar',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.stars, size: 20, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  '1,100 pontos',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Resgatar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Right Image (Desktop only)
                if (isDesktop) ...[
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/charme.jpg',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.white.withValues(alpha: 0.1),
                                child: const Icon(Icons.laptop_mac, size: 80, color: Colors.white),
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PrizeCard extends StatefulWidget {
  final String title;
  final String description;
  final String points;
  final String imageAsset;

  const _PrizeCard({
    required this.title,
    required this.description,
    required this.points,
    required this.imageAsset,
  });

  @override
  State<_PrizeCard> createState() => _PrizeCardState();
}

class _PrizeCardState extends State<_PrizeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
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
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:
                    _isHovered
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.08),
                blurRadius: _isHovered ? 15 : 8,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Image.asset(
                      widget.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                            child: Icon(
                              Icons.card_giftcard,
                              size: 60,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                    ),
                  ),
                ),
              ),

              // Content
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        widget.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Expanded(
                        child: Text(
                          widget.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Points and Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.points,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Resgatar',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
