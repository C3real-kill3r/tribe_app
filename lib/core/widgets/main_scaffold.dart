import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tribe/core/theme/theme_provider.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark 
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.05);
    
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _goBranch,
                backgroundColor: Colors.transparent,
                elevation: 0,
                indicatorColor: Colors.transparent,
                height: 56,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                destinations: [
                  NavigationDestination(
                    icon: Icon(
                      Icons.home_outlined,
                      size: 24,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    selectedIcon: Icon(
                      Icons.home,
                      size: 24,
                      color: accentColor,
                    ),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      size: 24,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    selectedIcon: Icon(
                      Icons.chat_bubble,
                      size: 24,
                      color: accentColor,
                    ),
                    label: 'Chat',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.track_changes_outlined,
                      size: 24,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    selectedIcon: Icon(
                      Icons.track_changes,
                      size: 24,
                      color: accentColor,
                    ),
                    label: 'Goals',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.photo_library_outlined,
                      size: 24,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    selectedIcon: Icon(
                      Icons.photo_library,
                      size: 24,
                      color: accentColor,
                    ),
                    label: 'Memories',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.person_outline,
                      size: 24,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    selectedIcon: Icon(
                      Icons.person,
                      size: 24,
                      color: accentColor,
                    ),
                    label: 'Profile',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.settings_outlined,
                      size: 24,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    selectedIcon: Icon(
                      Icons.settings,
                      size: 24,
                      color: accentColor,
                    ),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
