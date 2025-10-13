import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/web/widgets/animated_section.dart';

class PartnersSection extends StatelessWidget {
  const PartnersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 958;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 20, vertical: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.05),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: AnimatedSection(
        child: Column(
          children: [
            // Section Title
            Text(
              'LOJAS PARCEIRAS',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Rede de Parceiros Premium',
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Descubra nossa seleção exclusiva de lojas parceiras, escolhidas pela qualidade e excelência dos produtos oferecidos.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),

            // Partners Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount =
                    constraints.maxWidth > 1000
                        ? 4
                        : constraints.maxWidth > 800
                        ? 3
                        : constraints.maxWidth > 700
                        ? 2
                        : 1;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: _partnerStores.length,
                  itemBuilder: (context, index) {
                    final partner = _partnerStores[index];
                    return _PartnerCard(
                      name: partner['name'],
                      category: partner['category'],
                      points: partner['points'],
                      logo: partner['logo'],
                      color: partner['color'],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 60),

            // CTA Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.store),
                  const SizedBox(width: 8),
                  Text(
                    'Ver Todas as Lojas',
                    style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> _partnerStores = [
  {
    'name': 'Art Wood',
    'category': 'Móveis',
    'points': '+ pontos',
    'logo': 'assets/images/artwood.JPG',
    'color': const Color(0xFF2C5F41),
  },
  {
    'name': 'ABC da Contrução',
    'category': 'Acabamentos',
    'points': '+ pontos',
    'logo': 'assets/images/abc.JPG',
    'color': const Color(0xFFB8860B),
  },
  {
    'name': 'BS Ar-Condicionado',
    'category': 'Climatização',
    'points': '+ pontos',
    'logo': 'assets/images/bs.JPG',
    'color': const Color(0xFF6B4423),
  },
  {
    'name': 'Caetano Aluminox',
    'category': 'Acabamentos',
    'points': '+ pontos',
    'logo': 'assets/images/caetano.JPG',
    'color': const Color(0xFF2C5F41),
  },
  {
    'name': 'Artesano',
    'category': 'Revestimentos',
    'points': '+ pontos',
    'logo': 'assets/images/artesano.JPG',
    'color': const Color(0xFFB8860B),
  },
  {
    'name': 'Leds & Leds',
    'category': 'Iluminação',
    'points': '+ pontos',
    'logo': 'assets/images/leds.JPG',
    'color': const Color(0xFF6B4423),
  },
  {
    'name': 'Casa Design',
    'category': 'Móveis sob medida',
    'points': '+ pontos',
    'logo': 'assets/images/casat.JPG',
    'color': const Color(0xFF2C5F41),
  },
  {
    'name': 'MPAR',
    'category': 'Climatização',
    'points': '+ pontos',
    'logo': 'assets/images/mpar.JPG',
    'color': const Color(0xFF6B4423),
  },
  {
    'name': 'Sealy',
    'category': 'Colchões',
    'points': '+ pontos',
    'logo': 'assets/images/sealy.JPG',
    'color': const Color(0xFFB8860B),
  },
  {
    'name': 'Elevadores para Casa',
    'category': 'Mobilidade',
    'points': '+ pontos',
    'logo': 'assets/images/elevadores.JPG',
    'color': const Color(0xFF6B4423),
  },
  {
    'name': 'Auto Home',
    'category': 'Automação',
    'points': '+ pontos',
    'logo': 'assets/images/autohome.JPG',
    'color': const Color(0xFF2C5F41),
  },
  {
    'name': 'Steel Pro',
    'category': 'Engenharia',
    'points': '+ pontos',
    'logo': 'assets/images/steelpro.jpg',
    'color': const Color(0xFFB8860B),
  },
  {
    'name': 'Ecosol',
    'category': 'Aquecedores',
    'points': '+ pontos',
    'logo': 'assets/images/ecosol.jpg',
    'color': const Color(0xFF6B4423),
  },
  {
    'name': 'Fercimcal',
    'category': 'Ferragens',
    'points': '+ pontos',
    'logo': 'assets/images/ferci.jpg',
    'color': const Color(0xFFB8860B),
  },
  {
    'name': 'Dexter',
    'category': 'Locações',
    'points': '+ pontos',
    'logo': 'assets/images/Dexter.jpg',
    'color': const Color(0xFF2C5F41),
  },
  {
    'name': 'JMS',
    'category': 'Artefatos de Cimento',
    'points': '+ pontos',
    'logo': 'assets/images/jms.jpg',
    'color': const Color(0xFF6B4423),
  },
];

class _PartnerCard extends StatefulWidget {
  final String name;
  final String category;
  final String points;
  final String logo;
  final Color color;

  const _PartnerCard({
    required this.name,
    required this.category,
    required this.points,
    required this.logo,
    required this.color,
  });

  @override
  State<_PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends State<_PartnerCard> with SingleTickerProviderStateMixin {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight = constraints.maxHeight * 0.6;
            final contentHeight = constraints.maxHeight - imageHeight;

            return Container(
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
                children: [
                  // Logo
                  SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Image.asset(
                        widget.logo,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                              child: Icon(Icons.store, size: 60, color: theme.colorScheme.primary),
                            ),
                      ),
                    ),
                  ),

                  // Content
                  SizedBox(
                    height: contentHeight,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            widget.points,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
