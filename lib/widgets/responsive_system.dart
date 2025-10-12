import 'package:flutter/material.dart';

/// Système de responsive design adaptatif pour JeuTaime
/// Gère automatiquement les layouts pour mobile, tablette et desktop
class ResponsiveSystem {
  
  // ============================================================================
  // BREAKPOINTS STANDARDS
  // ============================================================================
  
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;
  
  // ============================================================================
  // DÉTECTION DU TYPE D'ÉCRAN
  // ============================================================================
  
  /// Retourne le type d'écran actuel
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else if (width < largeDesktopBreakpoint) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }
  
  /// Vérifie si l'écran est mobile
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }
  
  /// Vérifie si l'écran est tablette
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }
  
  /// Vérifie si l'écran est desktop
  static bool isDesktop(BuildContext context) {
    return getScreenType(context) == ScreenType.desktop ||
           getScreenType(context) == ScreenType.largeDesktop;
  }
  
  /// Vérifie si l'écran est en mode paysage
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  // ============================================================================
  // VALEURS ADAPTATIVES
  // ============================================================================
  
  /// Retourne une valeur selon le type d'écran
  static T valueByScreen<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }
  
  /// Padding adaptatif selon l'écran
  static EdgeInsets adaptivePadding(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
      largeDesktop: const EdgeInsets.all(48),
    );
  }
  
  /// Nombre de colonnes adaptatif pour grilles
  static int adaptiveColumns(BuildContext context, {
    int? mobile,
    int? tablet,
    int? desktop,
    int? largeDesktop,
  }) {
    return valueByScreen(
      context: context,
      mobile: mobile ?? 1,
      tablet: tablet ?? 2,
      desktop: desktop ?? 3,
      largeDesktop: largeDesktop ?? 4,
    );
  }
  
  /// Largeur maximale du contenu
  static double maxContentWidth(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1200,
      largeDesktop: 1400,
    );
  }
  
  /// Taille de texte adaptative
  static double adaptiveFontSize(BuildContext context, double baseSize) {
    final scaleFactor = valueByScreen(
      context: context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
      largeDesktop: 1.3,
    );
    return baseSize * scaleFactor;
  }
  
  // ============================================================================
  // WIDGETS ADAPTATIFS 
  // ============================================================================
  
  /// Layout adaptatif principal
  static Widget adaptiveLayout({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? largeDesktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        switch (getScreenType(context)) {
          case ScreenType.mobile:
            return mobile;
          case ScreenType.tablet:
            return tablet ?? mobile;
          case ScreenType.desktop:
            return desktop ?? tablet ?? mobile;
          case ScreenType.largeDesktop:
            return largeDesktop ?? desktop ?? tablet ?? mobile;
        }
      },
    );
  }
  
  /// Container avec largeur maximale centrée
  static Widget centeredContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? adaptivePadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxContentWidth(context),
          ),
          child: child,
        ),
      ),
    );
  }
  
  /// Grille responsive automatique
  static Widget adaptiveGrid({
    required BuildContext context,
    required List<Widget> children,
    int? mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
    int? largeDesktopColumns,
    double spacing = 16,
    double runSpacing = 16,
    EdgeInsets? padding,
  }) {
    final columns = adaptiveColumns(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
      largeDesktop: largeDesktopColumns,
    );
    
    return Padding(
      padding: padding ?? adaptivePadding(context),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: runSpacing,
          childAspectRatio: 1.0,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
  
  /// Liste ou grille selon l'écran
  static Widget adaptiveListOrGrid({
    required BuildContext context,
    required List<Widget> children,
    bool forceList = false,
    double spacing = 16,
    EdgeInsets? padding,
  }) {
    if (forceList || isMobile(context)) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding ?? adaptivePadding(context),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) => SizedBox(height: spacing),
      );
    }
    
    return adaptiveGrid(
      context: context,
      children: children,
      spacing: spacing,
      padding: padding,
    );
  }
  
  /// Navigation adaptative (bottom nav mobile, rail/sidebar desktop)
  static Widget adaptiveNavigation({
    required BuildContext context,
    required List<NavigationItem> items,
    required int currentIndex,
    required Function(int) onIndexChanged,
    required Widget body,
  }) {
    if (isMobile(context)) {
      return _buildMobileNavigation(
        items: items,
        currentIndex: currentIndex,
        onIndexChanged: onIndexChanged,
        body: body,
      );
    } else {
      return _buildDesktopNavigation(
        context: context,
        items: items,
        currentIndex: currentIndex,
        onIndexChanged: onIndexChanged,
        body: body,
      );
    }
  }
  
  /// Sidebar responsive (drawer mobile, permanent desktop)
  static Widget adaptiveSidebar({
    required BuildContext context,
    required Widget sidebar,
    required Widget body,
    double sidebarWidth = 280,
  }) {
    if (isMobile(context)) {
      return Scaffold(
        drawer: Drawer(child: sidebar),
        body: body,
      );
    } else {
      return Row(
        children: [
          SizedBox(
            width: sidebarWidth,
            child: sidebar,
          ),
          Expanded(child: body),
        ],
      );
    }
  }
  
  // ============================================================================
  // WIDGETS PRIVÉS
  // ============================================================================
  
  static Widget _buildMobileNavigation({
    required List<NavigationItem> items,
    required int currentIndex,
    required Function(int) onIndexChanged,
    required Widget body,
  }) {
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onIndexChanged,
        items: items
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: Icon(item.activeIcon ?? item.icon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
  
  static Widget _buildDesktopNavigation({
    required BuildContext context,
    required List<NavigationItem> items,
    required int currentIndex,
    required Function(int) onIndexChanged,
    required Widget body,
  }) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onIndexChanged,
            extended: isDesktop(context),
            destinations: items
                .map((item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.activeIcon ?? item.icon),
                      label: Text(item.label),
                    ))
                .toList(),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Types d'écrans supportés
enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Modèle pour éléments de navigation
class NavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String? route;

  const NavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.route,
  });
}

/// Mixins pour faciliter l'usage du responsive design
mixin ResponsiveMixin {
  
  ScreenType getScreenType(BuildContext context) =>
      ResponsiveSystem.getScreenType(context);
  
  bool isMobile(BuildContext context) =>
      ResponsiveSystem.isMobile(context);
  
  bool isTablet(BuildContext context) =>
      ResponsiveSystem.isTablet(context);
  
  bool isDesktop(BuildContext context) =>
      ResponsiveSystem.isDesktop(context);
  
  T valueByScreen<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) => ResponsiveSystem.valueByScreen(
    context: context,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
    largeDesktop: largeDesktop,
  );
  
  EdgeInsets adaptivePadding(BuildContext context) =>
      ResponsiveSystem.adaptivePadding(context);
  
  int adaptiveColumns(BuildContext context, {
    int? mobile,
    int? tablet,
    int? desktop,
    int? largeDesktop,
  }) => ResponsiveSystem.adaptiveColumns(
    context,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
    largeDesktop: largeDesktop,
  );
}

/// Widget helper pour construire des layouts responsives facilement
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = ResponsiveSystem.getScreenType(context);
        return builder(context, screenType);
      },
    );
  }
}

/// Widget pour colonnes adaptatives
class AdaptiveColumns extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? largeDesktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;

  const AdaptiveColumns({
    Key? key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.largeDesktopColumns,
    this.spacing = 16,
    this.runSpacing = 16,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveSystem.adaptiveGrid(
      context: context,
      children: children,
      mobileColumns: mobileColumns,
      tabletColumns: tabletColumns,
      desktopColumns: desktopColumns,
      largeDesktopColumns: largeDesktopColumns,
      spacing: spacing,
      runSpacing: runSpacing,
      padding: padding,
    );
  }
}

/// Widget pour du contenu centré avec largeur maximale
class CenteredContent extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const CenteredContent({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveSystem.centeredContainer(
      context: context,
      child: child,
      padding: padding,
    );
  }
}