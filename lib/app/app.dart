import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nucleo_casa_decor_android/app/routes.dart';
import 'package:nucleo_casa_decor_android/core/theme/app_theme.dart';
import 'package:nucleo_casa_decor_android/features/admin/presentation/pages/admin_home_page.dart';
import 'package:nucleo_casa_decor_android/features/auth/presentation/pages/login_page.dart';
import 'package:nucleo_casa_decor_android/features/auth/presentation/pages/specifier_registration_page.dart';
import 'package:nucleo_casa_decor_android/features/company/presentation/pages/company_home_page.dart';
import 'package:nucleo_casa_decor_android/features/landing/presentation/pages/landing_page.dart';
import 'package:nucleo_casa_decor_android/features/legal/presentation/pages/privacy_policy_page.dart';
import 'package:nucleo_casa_decor_android/features/legal/presentation/pages/terms_conditions_page.dart';
import 'package:nucleo_casa_decor_android/features/onboarding/presentation/pages/splash_page.dart';
import 'package:nucleo_casa_decor_android/features/reports/presentation/pages/ranking_page.dart';
import 'package:nucleo_casa_decor_android/features/specifier/presentation/pages/specifier_navigation_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grupo Casa Decor',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
      initialRoute: kIsWeb ? Routes.home : Routes.splashscreen,
      onGenerateRoute: _onGenerateRoute,
      debugShowCheckedModeBanner: false,
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    return Routes.fadeThrough(settings, (context) {
      return switch (settings.name) {
        Routes.home => const HomeLandingPage(),
        Routes.splashscreen => const SplashScreen(),
        Routes.main_navigation => const MainNavigation(),
        Routes.login => const LoginScreen(),
        Routes.registerEspecificador => const RegisterEspecificador(),
        Routes.terms => const TermsConditionsPage(),
        Routes.privacy => const PrivacyPolicyPage(),
        Routes.homeAdm => const HomePageAdm(),
        Routes.homeCompany => const HomeScreenCompany(),
        Routes.rank => const ReleasesPage1(),
        _ => const SizedBox.shrink(),
      };
    });
  }
}
