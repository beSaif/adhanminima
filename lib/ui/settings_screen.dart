import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';

import '../prayer/methods.dart';
import '../prayer/prayer_schedule.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'fill_scroll.dart';
import 'place_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return FillScroll(
      padding: screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Settings', style: TextStyle(fontSize: 15)),
          const SizedBox(height: 28),
          const _SectionLabel('CALCULATION'),
          _ValueRow(
            label: 'Location',
            value: state.place?.label ?? '',
            onTap: () async {
              final place = await showPlaceSheet(context);
              if (place != null) await state.setPlace(place);
            },
          ),
          _ValueRow(
            label: 'Method',
            value: methodInfo(state.method).name,
            onTap: () => _pickMethod(context, state),
          ),
          Container(
            constraints: const BoxConstraints(minHeight: 56),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                const Expanded(child: Text('Asr', style: _rowStyle)),
                _Segmented<Madhab>(
                  label: 'Asr juristic method',
                  options: const {
                    Madhab.shafi: 'Shafi',
                    Madhab.hanafi: 'Hanafi',
                  },
                  selected: state.madhab,
                  onSelected: state.setMadhab,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const _SectionLabel('ADJUST, IN MINUTES'),
          for (final p in dailyPrayers)
            _OffsetRow(
              prayer: p,
              value: state.offsets[p] ?? 0,
              onChanged: (delta) => state.adjustOffset(p, delta),
            ),
          const SizedBox(height: 28),
          const _SectionLabel('NOTIFICATIONS'),
          SizedBox(
            height: 52,
            child: Row(
              children: [
                const Expanded(
                  child: Text('Alert at each prayer', style: _rowStyle),
                ),
                _Toggle(
                  label: 'Alert at each prayer',
                  value: state.notificationsEnabled,
                  onChanged: (on) async {
                    final ok = await state.setNotificationsEnabled(on);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Notifications are blocked. Allow them for Adhaan in system settings.',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const Spacer(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _pickMethod(BuildContext context, AppState state) async {
    final picked = await showModalBottomSheet<CalculationMethod>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Calculation method',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
              ),
            ),
            for (final m in calculationMethods)
              _MethodTile(
                info: m,
                selected: m.method == state.method,
                onTap: () => Navigator.pop(context, m.method),
              ),
          ],
        ),
      ),
    );
    if (picked != null) await state.setMethod(picked);
  }
}

const _rowStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w300);

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Semantics(
        header: true,
        child: Text(text, style: sectionLabelStyle),
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              Text(label, style: _rowStyle),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: _rowStyle.copyWith(color: AppColors.tertiary),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OffsetRow extends StatelessWidget {
  const _OffsetRow({
    required this.prayer,
    required this.value,
    required this.onChanged,
  });

  final Prayer prayer;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final name = prayer.label;
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.dividerFaint)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(name, style: _rowStyle)),
          _StepButton(
            symbol: '−',
            tooltip: '$name one minute earlier',
            onPressed: value > -AppState.maxOffset ? () => onChanged(-1) : null,
          ),
          SizedBox(
            width: 32,
            child: Text(
              value > 0 ? '+$value' : '$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontFeatures: tabularFigures,
                color: value == 0 ? AppColors.text : AppColors.accent,
              ),
            ),
          ),
          _StepButton(
            symbol: '+',
            tooltip: '$name one minute later',
            onPressed: value < AppState.maxOffset ? () => onChanged(1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.symbol,
    required this.tooltip,
    required this.onPressed,
  });

  final String symbol;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: tooltip,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onPressed,
        radius: 22,
        child: SizedBox(
          width: 44,
          height: 40,
          child: Center(
            child: Text(
              symbol,
              style: TextStyle(
                fontSize: 20,
                color: onPressed == null ? AppColors.tick : AppColors.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final MapEntry(key: value, value: text) in options.entries)
              Semantics(
                button: true,
                selected: value == selected,
                child: GestureDetector(
                  onTap: () => onSelected(value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    constraints: const BoxConstraints(
                      minWidth: 72,
                      minHeight: 32,
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: value == selected
                          ? AppColors.text
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: value == selected
                            ? FontWeight.w500
                            : FontWeight.w400,
                        color: value == selected
                            ? AppColors.background
                            : AppColors.tertiary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      toggled: value,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 50,
          height: 30,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? AppColors.accent : AppColors.tick,
            borderRadius: BorderRadius.circular(15),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? AppColors.background : AppColors.text,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.info,
    required this.selected,
    required this.onTap,
  });

  final MethodInfo info;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: selected
                            ? FontWeight.w500
                            : FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      info.detail,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: AppColors.accent,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
