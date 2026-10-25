import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'fill_scroll.dart';
import 'place_sheet.dart';

/// First run: asks where to calculate prayer times for.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.service});

  final LocationService? service;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final LocationService _service = widget.service ?? LocationService();
  bool _locating = false;
  LocationFailure? _failure;

  Future<void> _useLocation() async {
    setState(() {
      _locating = true;
      _failure = null;
    });
    try {
      final place = await _service.currentPlace();
      if (mounted) await AppScope.read(context).setPlace(place);
    } on LocationFailure catch (e) {
      _failure = e;
    } catch (_) {
      _failure = const LocationFailure(
        'Could not read your location. Try again, or choose a city.',
      );
    }
    if (mounted) setState(() => _locating = false);
  }

  Future<void> _chooseCity() async {
    final place = await showPlaceSheet(
      context,
      offerCurrentLocation: false,
      service: _service,
    );
    if (place != null && mounted) await AppScope.read(context).setPlace(place);
  }

  @override
  Widget build(BuildContext context) {
    final failure = _failure;
    return Scaffold(
      body: SafeArea(
        child: FillScroll(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Adhaan',
                style: TextStyle(fontSize: 15, color: AppColors.secondary),
              ),
              const Spacer(flex: 3),
              const Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.location_on_outlined,
                  size: 44,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Prayer times begin with where you are.',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w200,
                  height: 1.1,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Adhaan uses your location on this phone to work out '
                'today’s times and the direction of the Qibla. '
                'No account, no ads, no tracking.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  height: 1.5,
                  color: AppColors.tertiary,
                ),
              ),
              if (failure != null) ...[
                const SizedBox(height: 20),
                Text(
                  failure.message,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: AppColors.text,
                  ),
                ),
                if (failure.canOpenSettings)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () async {
                        if (!await Geolocator.openAppSettings()) {
                          await Geolocator.openLocationSettings();
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 44),
                      ),
                      child: const Text('Open settings'),
                    ),
                  ),
              ],
              const Spacer(flex: 4),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _locating ? null : _useLocation,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.text,
                  foregroundColor: AppColors.background,
                  disabledBackgroundColor: AppColors.tertiary,
                  minimumSize: const Size.fromHeight(54),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontFamily: 'InterTight',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: _locating
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                    : const Text('Use my location'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _locating ? null : _chooseCity,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: AppColors.outline),
                  minimumSize: const Size.fromHeight(54),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontFamily: 'InterTight',
                    fontSize: 16,
                  ),
                ),
                child: const Text('Choose a city instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
