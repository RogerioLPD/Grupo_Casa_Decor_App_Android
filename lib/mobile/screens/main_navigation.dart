import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/mobile/screens/home_mobile.dart';
import 'package:nucleo_casa_decor_android/mobile/screens/transactions_screen.dart';
import 'package:nucleo_casa_decor_android/shared/screens/companies_screen.dart';
import 'package:nucleo_casa_decor_android/shared/screens/profile_screen.dart';
import 'package:nucleo_casa_decor_android/shared/screens/rewards_screen.dart';
import 'package:nucleo_casa_decor_android/shared/services/specifier_controller.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late SpecifierController controller;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    controller = SpecifierController(); // Cria o controller uma vez

    _screens = [
      HomeMobileScreen(controller: controller), // Passa o controller aqui
      TransactionsScreen(controller: controller), // E aqui também
      const CompaniesScreen(),
      RewardsScreen(controller: controller),
      ProfileScreen(controller: controller),
    ];

    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    controller.dispose(); // Não esqueça de liberar o controller
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withAlpha(130), // alpha 0.51*255 ~ 130
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: theme.colorScheme.surface,
            selectedItemColor: theme.colorScheme.secondary,
            unselectedItemColor: theme.colorScheme.onSurface.withAlpha(153), // 0.6*255 ~153
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: 'Extrato',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business_outlined),
                activeIcon: Icon(Icons.business),
                label: 'Empresas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.card_giftcard_outlined),
                activeIcon: Icon(Icons.card_giftcard),
                label: 'Prêmios',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
