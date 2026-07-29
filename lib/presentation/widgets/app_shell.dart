// AppShell: hosts the StatefulShellRoute's navigation shell.
// Renders a Material 3 NavigationBar with adaptive icons.
//
// For tablets (width >= 600dp landscape), the same shell switches to
// NavigationRail automatically — see _buildLayout.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/build_context.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet && context.isLandscape;
    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            _buildRail(context),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _buildBar(context),
    );
  }

  Widget _buildBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (i) => navigationShell.goBranch(
        i,
        initialLocation: i == navigationShell.currentIndex,
      ),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.qr_code_2_outlined),
          selectedIcon: const Icon(Icons.qr_code_2),
          label: context.l10n.tabGenerator,
        ),
        NavigationDestination(
          icon: const Icon(Icons.camera_alt_outlined),
          selectedIcon: const Icon(Icons.camera_alt),
          label: context.l10n.tabScanner,
        ),
        NavigationDestination(
          icon: const Icon(Icons.swap_horiz),
          selectedIcon: const Icon(Icons.swap_horiz),
          label: context.l10n.converter_title,
        ),
        NavigationDestination(
          icon: const Icon(Icons.history_outlined),
          selectedIcon: const Icon(Icons.history),
          label: context.l10n.tabHistory,
        ),
        NavigationDestination(
          icon: const Icon(Icons.layers_outlined),
          selectedIcon: const Icon(Icons.layers),
          label: context.l10n.tabBatch,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: context.l10n.tabSettings,
        ),
      ],
    );
  }

  Widget _buildRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (i) => navigationShell.goBranch(
        i,
        initialLocation: i == navigationShell.currentIndex,
      ),
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.all(16),
        child: Icon(
          Icons.qr_code_2,
          size: 40,
          color: context.colors.primary,
        ),
      ),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.qr_code_2_outlined),
          selectedIcon: const Icon(Icons.qr_code_2),
          label: Text(context.l10n.tabGenerator),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.camera_alt_outlined),
          selectedIcon: const Icon(Icons.camera_alt),
          label: Text(context.l10n.tabScanner),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.swap_horiz),
          selectedIcon: const Icon(Icons.swap_horiz),
          label: Text(context.l10n.converter_title),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.history_outlined),
          selectedIcon: const Icon(Icons.history),
          label: Text(context.l10n.tabHistory),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.layers_outlined),
          selectedIcon: const Icon(Icons.layers),
          label: Text(context.l10n.tabBatch),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: Text(context.l10n.tabSettings),
        ),
      ],
    );
  }
}
