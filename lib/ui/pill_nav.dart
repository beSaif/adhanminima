import 'package:flutter/material.dart';

import '../theme.dart';

class PillNavItem {
  const PillNavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Bottom navigation from the Sun Arc design: a dark pill whose selected
/// segment is a light pill with an icon and label.
class PillNav extends StatelessWidget {
  const PillNav({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<PillNavItem> items;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.navBackground,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          for (final (i, item) in items.indexed)
            Expanded(
              child: _Segment(
                item: item,
                selected: i == selected,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final PillNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        // Background, label colour and icon share one progress value so the
        // label never sits dark-on-dark mid-transition.
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: selected ? 1 : 0),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          builder: (context, t, _) {
            final color = Color.lerp(
              AppColors.secondary,
              AppColors.background,
              t,
            );
            return Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.text.withValues(alpha: t),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRect(
                    child: Align(
                      widthFactor: t,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(item.icon, size: 18, color: color),
                      ),
                    ),
                  ),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      color: color,
                      fontWeight: t > 0.5 ? FontWeight.w600 : FontWeight.w400,
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
