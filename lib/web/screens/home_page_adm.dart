import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nucleo_casa_decor_android/shared/screens/profile_screen.dart';
import 'package:nucleo_casa_decor_android/shared/services/rewards_controller.dart';
import 'package:nucleo_casa_decor_android/shared/services/specifier_controller.dart';
import 'package:nucleo_casa_decor_android/web/screens/company_registration_screen.dart';
import 'package:nucleo_casa_decor_android/web/screens/dashboard_screen.dart';
import 'package:nucleo_casa_decor_android/web/screens/prize_registration_screen.dart';
import 'package:nucleo_casa_decor_android/web/screens/report_company.dart';
import 'package:nucleo_casa_decor_android/web/screens/user_reports_screen.dart';
import 'package:nucleo_casa_decor_android/web/widgets/backup.dart';

// Controlador de página atual
final currentPageProvider = StateProvider<String>((ref) => 'home');

class HomePageAdm extends ConsumerStatefulWidget {
  const HomePageAdm({super.key});

  @override
  ConsumerState<HomePageAdm> createState() => _HomePageAdmState();
}

class _HomePageAdmState extends ConsumerState<HomePageAdm> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late SpecifierController controller;

  @override
  void initState() {
    super.initState();
    controller = SpecifierController();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildCurrentPage(String currentPage) {
    final rewardsController = RewardsController();
    switch (currentPage) {
      case 'home':
        return const DashboardScreen();
      case 'company':
        return const CompanyRegistrationScreen();
      case 'prizes':
        return PrizeRegistrationScreen(controller: rewardsController);
      case 'reports':
        return const UserReportsScreen();
      case 'reports1':
        return const CompanyReportsScreen();
      case 'profile':
        return ProfileScreen(controller: controller); // Substitua por sua tela de perfil
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(currentPageProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 768;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          drawer:
              isSmallScreen
                  ? Drawer(
                    child: AnimatedSideMenu(
                      currentPage: currentPage,
                      onPageSelected: (page) {
                        ref.read(currentPageProvider.notifier).state = page;
                        Navigator.pop(context); // Fecha o drawer no mobile
                      },
                    ),
                  )
                  : null,
          body: Row(
            children: [
              if (!isSmallScreen)
                AnimatedSideMenu(
                  currentPage: currentPage,
                  onPageSelected: (page) {
                    ref.read(currentPageProvider.notifier).state = page;
                  },
                ),
              Expanded(
                child: Column(
                  children: [
                    if (isSmallScreen) _buildMobileAppBar(currentPage),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Transform.scale(
                              scale: 0.95 + (0.05 * _fadeAnimation.value),
                              child: _buildCurrentPage(currentPage),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileAppBar(String currentPage) {
    final pageTitle =
        {
          'home': 'Dashboard',
          'company': 'Cadastro de Empresas',
          'prizes': 'Cadastro de Prêmios',
          'reports': 'Relatórios de Usuários',
          'profile': 'Perfil',
        }[currentPage] ??
        'Dashboard';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                pageTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
