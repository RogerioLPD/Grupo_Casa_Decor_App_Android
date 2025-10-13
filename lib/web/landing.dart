// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _benefitsKey = GlobalKey();
  final GlobalKey _partnersKey = GlobalKey();
  final GlobalKey _rewardsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            pinned: true,
            backgroundColor: theme.appBarTheme.backgroundColor,
            flexibleSpace: const AppBarContent(),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              HeroSection(key: _homeKey, fadeAnimation: _fadeAnimation),
              AboutSection(key: _aboutKey),
              BenefitsSection(key: _benefitsKey),
              PartnersSection(key: _partnersKey),
              RewardsSection(key: _rewardsKey),
              ContactSection(key: _contactKey),
            ]),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _scrollToSection(_homeKey),
        icon: const Icon(Icons.arrow_upward),
        label: const Text('Topo'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }
}

class AppBarContent extends StatelessWidget {
  const AppBarContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.architecture, size: 32, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Grupo Casa Decor',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (!isMobile) const NavigationMenu(),
          if (isMobile)
            IconButton(
              icon: Icon(Icons.menu, color: theme.colorScheme.primary),
              onPressed: () => _showMobileMenu(context),
            ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) => const MobileNavigationMenu());
  }
}

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final homePage = context.findAncestorStateOfType<_HomePageState>();

    return Row(
      children: [
        _NavButton('Início', () => homePage?._scrollToSection(homePage._homeKey)),
        _NavButton('Sobre', () => homePage?._scrollToSection(homePage._aboutKey)),
        _NavButton('Benefícios', () => homePage?._scrollToSection(homePage._benefitsKey)),
        _NavButton('Parceiros', () => homePage?._scrollToSection(homePage._partnersKey)),
        _NavButton('Prêmios', () => homePage?._scrollToSection(homePage._rewardsKey)),
        _NavButton('Contato', () => homePage?._scrollToSection(homePage._contactKey)),
      ],
    );
  }

  Widget _NavButton(String text, VoidCallback onPressed) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return TextButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
          ),
        );
      },
    );
  }
}

class MobileNavigationMenu extends StatelessWidget {
  const MobileNavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final homePage = context.findAncestorStateOfType<_HomePageState>();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MobileNavItem('🏠 Início', () {
            Navigator.pop(context);
            homePage?._scrollToSection(homePage._homeKey);
          }),
          _MobileNavItem('ℹ️ Sobre', () {
            Navigator.pop(context);
            homePage?._scrollToSection(homePage._aboutKey);
          }),
          _MobileNavItem('⭐ Benefícios', () {
            Navigator.pop(context);
            homePage?._scrollToSection(homePage._benefitsKey);
          }),
          _MobileNavItem('🤝 Parceiros', () {
            Navigator.pop(context);
            homePage?._scrollToSection(homePage._partnersKey);
          }),
          _MobileNavItem('🏆 Prêmios', () {
            Navigator.pop(context);
            homePage?._scrollToSection(homePage._rewardsKey);
          }),
          _MobileNavItem('📞 Contato', () {
            Navigator.pop(context);
            homePage?._scrollToSection(homePage._contactKey);
          }),
        ],
      ),
    );
  }

  Widget _MobileNavItem(String text, VoidCallback onPressed) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return ListTile(title: Text(text, style: theme.textTheme.titleMedium), onTap: onPressed);
      },
    );
  }
}

class HeroSection extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const HeroSection({super.key, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    return Container(
      height: screenSize.height * 0.9,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primaryContainer, theme.colorScheme.surface],
        ),
      ),
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'Grupo Casa Decor',
                    textStyle: theme.textTheme.displayLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                isRepeatingAnimation: false,
              ),
              const SizedBox(height: 24),
              AnimatedTextKit(
                animatedTexts: [
                  FadeAnimatedText(
                    'Acumule pontos e transforme suas compras em prêmios incríveis',
                    textStyle: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    duration: const Duration(milliseconds: 2000),
                  ),
                ],
                isRepeatingAnimation: false,
              ),
              const SizedBox(height: 32),
              Text(
                'Exclusivo para arquitetos. Compre em lojas parceiras, acumule pontos e troque por prêmios únicos. Transforme cada projeto em uma oportunidade de recompensa.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.person_add, color: theme.colorScheme.onPrimary),
                    label: Text(
                      'Cadastrar-se',
                      style: TextStyle(color: theme.colorScheme.onPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.play_arrow, color: theme.colorScheme.primary),
                    label: Text('Saiba Mais', style: TextStyle(color: theme.colorScheme.primary)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
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

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return AnimationLimiter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 80),
        child: Column(
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder:
                (widget) =>
                    SlideAnimation(horizontalOffset: 50.0, child: FadeInAnimation(child: widget)),
            children: [
              Text(
                'Sobre o Programa',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                'O Grupo Casa Decor é um programa de fidelidade exclusivo para arquitetos, criado para reconhecer e recompensar profissionais que confiam em nossos parceiros para seus projetos.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (isMobile)
                Column(children: _buildFeatureCards(context))
              else
                Row(children: _buildFeatureCards(context)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeatureCards(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return [
      const Expanded(
        child: FeatureCard(
          icon: Icons.architecture,
          title: 'Exclusivo para Arquitetos',
          description: 'Programa desenvolvido especialmente para profissionais da arquitetura',
        ),
      ),
      if (!isMobile) const SizedBox(width: 24),
      if (isMobile) const SizedBox(height: 24),
      const Expanded(
        child: FeatureCard(
          icon: Icons.stars,
          title: 'Sistema de Pontos',
          description: 'Acumule pontos a cada compra em lojas parceiras credenciadas',
        ),
      ),
      if (!isMobile) const SizedBox(width: 24),
      if (isMobile) const SizedBox(height: 24),
      const Expanded(
        child: FeatureCard(
          icon: Icons.card_giftcard,
          title: 'Prêmios Exclusivos',
          description: 'Troque seus pontos por prêmios únicos e experiências especiais',
        ),
      ),
    ];
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class BenefitsSection extends StatelessWidget {
  const BenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 80),
      child: AnimationLimiter(
        child: Column(
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder:
                (widget) =>
                    SlideAnimation(verticalOffset: 50.0, child: FadeInAnimation(child: widget)),
            children: [
              Text(
                'Benefícios Exclusivos',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 1 : 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: isMobile ? 4 : 3,
                children: const [
                  BenefitItem(
                    icon: Icons.local_offer,
                    title: 'Descontos Especiais',
                    description: 'Descontos exclusivos em produtos selecionados de parceiros',
                  ),
                  BenefitItem(
                    icon: Icons.event,
                    title: 'Eventos VIP',
                    description: 'Acesso prioritário a eventos e lançamentos do setor',
                  ),
                  BenefitItem(
                    icon: Icons.school,
                    title: 'Cursos e Workshops',
                    description: 'Participação gratuita em cursos de capacitação profissional',
                  ),
                  BenefitItem(
                    icon: Icons.business,
                    title: 'Networking',
                    description: 'Oportunidades de networking com outros profissionais',
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

class BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const BenefitItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: theme.colorScheme.secondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PartnersSection extends StatelessWidget {
  const PartnersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 80),
      child: AnimationLimiter(
        child: Column(
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder:
                (widget) =>
                    SlideAnimation(horizontalOffset: -50.0, child: FadeInAnimation(child: widget)),
            children: [
              Text(
                'Lojas Parceiras',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Compre em nossas lojas parceiras e acumule pontos automaticamente',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 2 : 4,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                children: const [
                  PartnerCard(
                    imageUrl:
                        'https://pixabay.com/get/g1df17a49a1cf6cf1b3f506aab6bc259d3861ac4d27d4cc30c5eced832a88182fdb5f255bf856009b95a8f36f7a4f3587cca7c92de1eac26a989204f44f05294a_1280.jpg',
                    name: 'Casa Móveis',
                    category: 'Móveis e Decoração',
                  ),
                  PartnerCard(
                    imageUrl:
                        'https://pixabay.com/get/ga5d0c4a8f9bb17fc2c18a6b8998b55ee211f5f0323df0c6d165e4230914ac6e34e0788c6649eca9980712ea07cc144cfe57e276e2b9137d64e19ff427b009971_1280.jpg',
                    name: 'Decor Premium',
                    category: 'Decoração Luxo',
                  ),
                  PartnerCard(
                    imageUrl:
                        'https://pixabay.com/get/g3afaf66e76d9b198c759f99cd1f216e7a3f375c9b0879210fe73fce377c19585af6bfc0928e05eb93acdad48c3a420c73b9e1cb659a3fed1333fc5e212f6fca6_1280.jpg',
                    name: 'Construmat',
                    category: 'Materiais de Construção',
                  ),
                  PartnerCard(
                    imageUrl:
                        'https://pixabay.com/get/g50e36901f6aee39bbca3b2f3b15cb6ddf771d53daa89a48a48bea725cfc9d69da03b25def359a469909d86a35fe29ab3d980f84ff5fc0233c2ca5852c8b8abde_1280.jpg',
                    name: 'Iluminação Arte',
                    category: 'Iluminação Especial',
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

class PartnerCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String category;

  const PartnerCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.store, size: 48, color: theme.colorScheme.primary),
                    ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RewardsSection extends StatelessWidget {
  const RewardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 80),
      child: AnimationLimiter(
        child: Column(
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder:
                (widget) =>
                    SlideAnimation(verticalOffset: 50.0, child: FadeInAnimation(child: widget)),
            children: [
              Text(
                'Catálogo de Prêmios',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Troque seus pontos por prêmios incríveis',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 1 : 3,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: isMobile ? 2.5 : 1.2,
                children: const [
                  RewardCard(
                    icon: Icons.weekend,
                    title: 'Móveis Exclusivos',
                    points: '5.000 pontos',
                    description: 'Peças únicas de design para seus projetos',
                  ),
                  RewardCard(
                    icon: Icons.flight,
                    title: 'Viagem Internacional',
                    points: '15.000 pontos',
                    description: 'Viagem para feiras de arquitetura no exterior',
                  ),
                  RewardCard(
                    icon: Icons.laptop_mac,
                    title: 'Equipamentos',
                    points: '8.000 pontos',
                    description: 'Tablets e notebooks para trabalho',
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

class RewardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String points;
  final String description;

  const RewardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.points,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: theme.colorScheme.secondary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                points,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: theme.colorScheme.primary,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 80),
      child: AnimationLimiter(
        child: Column(
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder:
                (widget) =>
                    SlideAnimation(verticalOffset: 30.0, child: FadeInAnimation(child: widget)),
            children: [
              Text(
                'Entre em Contato',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Pronto para começar a acumular pontos? Entre em contato conosco!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (isMobile)
                Column(children: _buildContactInfo(theme))
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildContactInfo(theme),
                ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.email, color: theme.colorScheme.primary),
                label: Text('Fale Conosco', style: TextStyle(color: theme.colorScheme.primary)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContactInfo(ThemeData theme) {
    return [
      ContactInfo(icon: Icons.phone, title: 'Telefone', info: '(11) 9999-9999', theme: theme),
      ContactInfo(
        icon: Icons.email,
        title: 'E-mail',
        info: 'contato@grupocasadecor.com.br',
        theme: theme,
      ),
      ContactInfo(icon: Icons.location_on, title: 'Endereço', info: 'São Paulo, SP', theme: theme),
    ];
  }
}

class ContactInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String info;
  final ThemeData theme;

  const ContactInfo({
    super.key,
    required this.icon,
    required this.title,
    required this.info,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Icon(icon, size: 32, color: theme.colorScheme.onPrimary),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            info,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
