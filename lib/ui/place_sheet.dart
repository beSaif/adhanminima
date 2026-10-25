import 'package:flutter/material.dart';

import '../services/location_service.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// Lets the user pick a place by GPS or by searching for a city.
Future<SavedPlace?> showPlaceSheet(
  BuildContext context, {
  bool offerCurrentLocation = true,
  LocationService? service,
}) {
  return showModalBottomSheet<SavedPlace>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _PlaceSheet(
      service: service ?? LocationService(),
      offerCurrentLocation: offerCurrentLocation,
    ),
  );
}

class _PlaceSheet extends StatefulWidget {
  const _PlaceSheet({
    required this.service,
    required this.offerCurrentLocation,
  });

  final LocationService service;
  final bool offerCurrentLocation;

  @override
  State<_PlaceSheet> createState() => _PlaceSheetState();
}

class _PlaceSheetState extends State<_PlaceSheet> {
  final _query = TextEditingController();
  List<SavedPlace>? _results;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() task) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await task();
    } on LocationFailure catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong. Check your connection and try again.';
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _search() async {
    final q = _query.text.trim();
    if (q.isEmpty) return;
    await _run(() async {
      _results = await widget.service.search(q);
      if (_results!.isEmpty) {
        _error =
            'No places found for “$q”. Check the spelling or your connection.';
      }
    });
  }

  Future<void> _useCurrent() => _run(() async {
    final place = await widget.service.currentPlace();
    if (mounted) Navigator.pop(context, place);
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        28,
        0,
        28,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choose a location',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 16),
          if (widget.offerCurrentLocation)
            OutlinedButton.icon(
              onPressed: _busy ? null : _useCurrent,
              icon: const Icon(Icons.near_me_outlined, size: 18),
              label: const Text('Use my current location'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.text,
                side: const BorderSide(color: AppColors.outline),
                minimumSize: const Size.fromHeight(50),
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontFamily: 'InterTight',
                  fontSize: 15,
                ),
              ),
            ),
          if (widget.offerCurrentLocation) const SizedBox(height: 12),
          TextField(
            controller: _query,
            autofocus: !widget.offerCurrentLocation,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search for a city',
              hintStyle: const TextStyle(color: AppColors.secondary),
              filled: true,
              fillColor: AppColors.navBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                tooltip: 'Search',
                onPressed: _busy ? null : _search,
                icon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.tertiary,
                ),
              ),
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          if (_error case final error?)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                error,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.tertiary,
                  height: 1.4,
                ),
              ),
            ),
          if (_results case final results? when !_busy)
            for (final place in results)
              InkWell(
                onTap: () => Navigator.pop(context, place),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 52),
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: Text(
                    place.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
