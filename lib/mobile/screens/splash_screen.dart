import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/mobile/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;

  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _backgroundOpacity;
  late Animation<Offset> _logoSlide;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Controladores de animação
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Animações
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _logoScale = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));

    _logoRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut));

    _backgroundOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack));
  }

  void _startSplashSequence() async {
    // Inicia as animações em sequência
    await Future.delayed(const Duration(milliseconds: 400));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _rotationController.forward();

    // Aguarda um pouco antes de navegar
    await Future.delayed(const Duration(milliseconds: 3000));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
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
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _logoController,
            _fadeController,
            _scaleController,
            _rotationController,
          ]),
          builder: (context, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animada
                  SlideTransition(
                    position: _logoSlide,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: RotationTransition(
                          turns: _logoRotation,
                          child: Container(
                            width: 350,
                            height: 350,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                /* BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),*/
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/Grupo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                    ),
                                    child: Icon(
                                      Icons.animation,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Texto animado
                  /*FadeTransition(
                    opacity: _backgroundOpacity,
                    child: Column(
                      children: [
                        Text(
                          'Animador',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A Nova Era da Criatividade Digital',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),*/
                  const SizedBox(height: 60),

                  // Indicador de carregamento animado
                  FadeTransition(
                    opacity: _backgroundOpacity,
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
                        ),
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
