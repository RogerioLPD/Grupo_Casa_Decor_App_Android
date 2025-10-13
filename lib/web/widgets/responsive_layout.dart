import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double sidebarWidth;
  final bool showSidebar;
  final VoidCallback? onMenuToggle;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.sidebarWidth = 280,
    this.showSidebar = true,
    this.onMenuToggle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 768;

        return Scaffold(
          body: Row(
            children: [
              if (showSidebar && !isSmallScreen)
                SizedBox(
                  width: sidebarWidth,
                  child: child,
                ),
              if (showSidebar && !isSmallScreen)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: child,
                      ),
                    ),
                  ),
                )
              else
                Expanded(child: child),
            ],
          ),
          drawer: isSmallScreen && showSidebar
              ? Drawer(
                  width: sidebarWidth,
                  child: child,
                )
              : null,
        );
      },
    );
  }
}

class BreakPoints {
  static const double mobile = 768;
  static const double tablet = 1110;
  static const double desktop = 1440;
}

extension ResponsiveExtension on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < BreakPoints.mobile;
  bool get isTablet =>
      MediaQuery.of(this).size.width >= BreakPoints.mobile &&
      MediaQuery.of(this).size.width < BreakPoints.tablet;
  bool get isDesktop => MediaQuery.of(this).size.width >= BreakPoints.desktop;
}
