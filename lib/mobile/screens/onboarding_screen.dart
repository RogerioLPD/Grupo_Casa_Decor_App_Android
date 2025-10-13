import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/shared/screens/authgate.dart';
import 'package:nucleo_casa_decor_android/shared/screens/login_especificador.dart';
import 'package:nucleo_casa_decor_android/shared/screens/register_especificador.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      image: 'assets/images/parceiros.png',
      title: 'Especifique em lojas parceiras do Grupo Casa Decor',
    ),
    OnboardingData(image: 'assets/images/rewards.png', title: 'Acumule Pontos'),
    OnboardingData(image: 'assets/images/awards.png', title: 'Troque seus pontos por experiências'),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onGetStarted() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthGate()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondary.withAlpha(204), // alpha ~0.8
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return OnboardingPage(
                      data: _pages[index],
                      isLastPage: index == _pages.length - 1,
                      onNext: _nextPage,
                      onGetStarted: _onGetStarted,
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: size.width * 0.01),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            _currentPage == index
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.isLastPage,
    required this.onNext,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.all(size.width * 0.06),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Imagem
          Container(
            width: double.infinity,
            height: size.height * 0.5, // Reduzido de 0.6 para 0.5 para melhor ajuste
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                data.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.image_not_supported,
                      size: size.width * 0.15,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: size.height * 0.04),

          // Título
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: size.height * 0.05),

          // Botão ou setinha
          if (isLastPage)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginEspecificador()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Login',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterEspecificador()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Cadastrar',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: onNext,
              child: Container(
                width: size.width * 0.15,
                height: size.width * 0.15,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withAlpha(76),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: size.width * 0.06,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final String title;

  OnboardingData({required this.image, required this.title});
}
