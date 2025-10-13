import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nucleo_casa_decor_android/shared/screens/profile_screen.dart';
import 'package:nucleo_casa_decor_android/shared/services/specifier_controller.dart';
import 'package:nucleo_casa_decor_android/web/screens/dashboard_company.dart';
import 'package:nucleo_casa_decor_android/web/screens/points_screen.dart';
import 'package:nucleo_casa_decor_android/web/widgets/animated_side_menu.dart';

final currentPageProvider = StateProvider<String>((ref) => 'home');

class HomeScreenCompany extends ConsumerStatefulWidget {
  const HomeScreenCompany({super.key});

  @override
  ConsumerState<HomeScreenCompany> createState() => _HomeScreenCompanyState();
}

class _HomeScreenCompanyState extends ConsumerState<HomeScreenCompany>
    with TickerProviderStateMixin {
  late AnimationController _pageTransitionController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late SpecifierController controller;

  @override
  void initState() {
    super.initState();
    controller = SpecifierController();
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageTransitionController, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pageTransitionController, curve: Curves.easeIn));

    _pageTransitionController.forward();
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    super.dispose();
  }

  void _onPageSelected(String page) {
    if (ref.read(currentPageProvider) != page) {
      _pageTransitionController.reset();
      ref.read(currentPageProvider.notifier).state = page;
      _pageTransitionController.forward();
    }
  }

  Widget _buildCurrentPage(String currentPage) {
    switch (currentPage) {
      case 'home':
        return const DashboardCompany();
      case 'points':
        return const PointsScreen();
      /*case 'profile1':
        return const ProfileScreenClients();*/
      case 'profile':
        return ProfileScreen(controller: controller);
      default:
        return const DashboardCompany();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(currentPageProvider);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Row(
        children: [
          // Side Menu
          if (isDesktop || isTablet)
            AnimatedSideMenu(currentPage: currentPage, onPageSelected: _onPageSelected),

          // Main Content
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                  child: _buildCurrentPage(currentPage),
                ),
              ),
            ),
          ),
        ],
      ),

      // Mobile Navigation
      drawer:
          screenWidth <= 768
              ? Drawer(
                child: AnimatedSideMenu(
                  currentPage: currentPage,
                  onPageSelected: (page) {
                    _onPageSelected(page);
                    Navigator.of(context).pop();
                  },
                ),
              )
              : null,

      // Mobile App Bar
      appBar:
          screenWidth <= 768
              ? AppBar(
                title: Text(
                  _getPageTitle(currentPage),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                elevation: 0,
                centerTitle: true,
              )
              : null,
    );
  }

  String _getPageTitle(String page) {
    switch (page) {
      case 'home':
        return 'Dashboard';
      case 'points':
        return 'Lançar Pontos';
      case 'profile1':
        return 'Perfil Clientes';
      case 'profile':
        return 'Perfil';
      default:
        return 'Grupo Casa Decor';
    }
  }
}
