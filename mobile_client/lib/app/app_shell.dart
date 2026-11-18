import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/guide/page_guides.dart';
import 'package:mobile_client/core/settings/settings_controller.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBody: false,
      
      // Integrated Top Bar with matching partial bottom separator
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(58),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: colorScheme.surface,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                l10n.app_title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
              ),
              actions: [
                IconButton(
                  tooltip: l10n.guide_tooltip,
                  // Tour of the page that is open right now.
                  onPressed: () =>
                      startGuideForTab(context, navigationShell.currentIndex),
                  icon: const Icon(Icons.question_mark),
                ),
                const _MoreMenu(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Divider(
                height: 1,
                thickness: 0.8,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),

      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (v.abs() < 300) return;
          final rtl = Directionality.of(context) == TextDirection.rtl;
          final target = navigationShell.currentIndex + ((rtl ? v > 0 : v < 0) ? 1 : -1);
          if (target >= 0 && target < 4) navigationShell.goBranch(target);
        },
        child: navigationShell,
      ),

      // Integrated Bottom Bar matching the top style
      bottomNavigationBar: _buildIntegratedBottomBar(context),
    );
  }

  Widget _buildIntegratedBottomBar(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final items = [
      (
        Icons.article_outlined,
        Icons.article,
        l10n.shell_navBar_note_view,
      ),
      (
        Icons.lightbulb_outline,
        Icons.lightbulb,
        l10n.shell_navBar_thought_view,
      ),
      (
        Icons.task_alt_outlined,
        Icons.task_alt,
        l10n.shell_navBar_task_view,
      ),
      (
        Icons.checklist_outlined,
        Icons.checklist,
        l10n.shell_navBar_checklist_view,
      ),
    ];

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Divider(
                height: 1,
                thickness: 0.8,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final isSelected = currentIndex == index;
                  final item = items[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _onItemTapped(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.$2 : item.$1,
                            size: 20,
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Text(
                              item.$3,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreMenu extends StatelessWidget {
  const _MoreMenu();

  @override
  Widget build(BuildContext context) {
    final settings = getIt<SettingsController>();
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final device = MediaQuery.platformBrightnessOf(context);

    final itemStyle = MenuItemButton.styleFrom(
      minimumSize: const Size(190, 52),
      padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 20, 0),
      foregroundColor: cs.onSurface,
      iconColor: cs.primary,
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    );

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final dark = settings.isDark(device);
        return MenuAnchor(
          alignmentOffset: const Offset(0, 4),
          style: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerHigh),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            shadowColor: WidgetStatePropertyAll(
              cs.shadow.withValues(alpha: 0.35),
            ),
            elevation: const WidgetStatePropertyAll(10),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          menuChildren: [
            MenuItemButton(
              style: itemStyle,
              closeOnActivate: false, // watch the theme change
              leadingIcon: _MenuIcon(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: Tween(begin: 0.5, end: 1.0).animate(anim),
                    child: ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                  ),
                  child: Icon(
                    dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    key: ValueKey(dark),
                    size: 20,
                  ),
                ),
              ),
              onPressed: () => settings.toggleBrightness(device),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                
                child: Align(
                  alignment: AlignmentGeometry.centerStart,
                  child: Text(
                    dark ? l10n.menu_light_mode : l10n.menu_dark_mode,
                    key: ValueKey(dark),
                  ),
                ),
              ),
            ),
            MenuItemButton(
              style: itemStyle,
              leadingIcon: const _MenuIcon(
                child: Icon(Icons.settings_rounded, size: 20),
              ),
              onPressed: () => context.push('/settings'),
              child: Text(l10n.settings_title),
            ),
          ],
          builder: (context, controller, _) => IconButton(
            tooltip: l10n.menu_more,
            onPressed: () =>
                controller.isOpen ? controller.close() : controller.open(),
            icon: const Icon(Icons.more_vert),
          ),
        );
      },
    );
  }
}

class _MenuIcon extends StatelessWidget {
  const _MenuIcon({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.7),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15),
      ),
      child: IconTheme(
        data: IconThemeData(color: cs.onPrimaryContainer),
        child: child,
      ),
    );
  }
}
