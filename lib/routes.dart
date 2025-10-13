// ignore_for_file: constant_identifier_names

import 'package:animations/animations.dart';
import 'package:flutter/widgets.dart';

class Routes {
  static const String home = "/";
  static const String splashscreen = "splashscreen";
  static const String main_navigation = "main_navigation";
  static const String login = "login";
  static const String registerEspecificador = "register";
  static const String terms = "terms";
  static const String privacy = "privacidade";
  static const String homeAdm = "homeadm";
  static const String homeCompany = "homecompany";
  static const String rank = "rank";

  static Route<T> fadeThrough<T>(RouteSettings settings, WidgetBuilder page, {int duration = 300}) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: Duration(milliseconds: duration),
      pageBuilder: (context, animation, secondaryAnimation) => page(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(animation: animation, child: child);
      },
    );
  }
}
