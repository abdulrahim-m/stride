import 'package:flutter/material.dart';
import 'package:mobile_client/core/guide/guide_target.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    required this.hint,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    required this.filterCount,
  });

  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final int filterCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: GuideTarget(
              id: 'search',
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: hint,
                  isDense: true,
                  filled: true,
                  // Explicitly bind fill color to theme so it interpolates smoothly
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (_, value, _) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              controller.clear();
                              onChanged('');
                            },
                          ),
                  ),
                  // Clean borders that respect the theme color scheme
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GuideTarget(
            id: 'filters',
            child: IconButton.filledTonal(
              tooltip: l10n.general_filters,
              onPressed: onFilterTap,
              icon: Badge(
                isLabelVisible: filterCount > 0,
                label: Text('$filterCount'),
                child: const Icon(Icons.filter_list),
              ),
            ),
          ),
        ],
      ),
    );
  }
}