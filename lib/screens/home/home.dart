import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:adhan/adhan.dart';
import 'package:adhanminima/api/quranic_verse.dart';
import 'package:adhanminima/controllers/location_controller.dart';
import 'package:adhanminima/controllers/prayer_offset_controller.dart';
import 'package:adhanminima/screens/home/components/homeWidget.dart';
import 'package:adhanminima/screens/home/components/panelWidget.dart';
import 'package:adhanminima/screens/home/components/qiblaWidget.dart';
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<String> dotIndicatorIcons = [
    'assets/prayer_time_icon.png',
    'assets/qibla_icon.png',
  ];
  final panelController = PanelController();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String formattedDiff = "0";

  // Remove individual location variables - now handled by LocationController
  PrayerTimes? prayerTimes;
  Coordinates myCoordinates = Coordinates(0, 0);

  late Future<void> _future;
  late LocationController locationController;

  bool _showErrorAnim = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    locationController = Get.put(LocationController());
    Get.put(PrayerOffsetController());

    _future = _initializeData();
    _pageController.addListener(() {
      int page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    // Get location using LocationController
    Position? position = await locationController.getCurrentLocation();
    if (position == null) {
      throw Exception(locationController.error.isNotEmpty
          ? locationController.error
          : 'Unable to get location');
    }

    debugPrint(
        'Latitude: ${position.latitude}, Longitude: ${position.longitude}');

    // Get placemark using LocationController
    Placemark? place = await locationController.getPlacemark();
    if (place != null) {
      debugPrint('Place: ${place.name}');
    }

    myCoordinates = Coordinates(position.latitude, position.longitude);
    debugPrint('Coordinates: $myCoordinates');

    await _getPrayerTimes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: const AssetImage("assets/bg.jpg"),
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.35), BlendMode.dstATop),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder(
          future: _future,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingScreen();
            } else if (snapshot.hasError) {
              return _buildErrorScreen(snapshot.error);
            } else {
              return _buildMainWidget(context);
            }
          },
        ),
      ),
    );
  }

  _buildMainWidget(BuildContext context) {
    return SlidingUpPanel(
      maxHeight: 500,
      controller: panelController,
      parallaxEnabled: true,
      parallaxOffset: .65,
      color: Colors.transparent,
      backdropEnabled: true,
      // backdropTapClosesPanel: true,
      body: PageView(
        controller: _pageController,
        children: [
          HomeWidget(
            prayerTimes: prayerTimes!,
            place: locationController.currentPlacemark ??
                const Placemark(name: 'Unknown Location'), // Fallback placemark
          ),
          const QiblahCompass(),
        ],
      ),

      panel: PanelWidget(
        pageController: _pageController,
        currentPage: _currentPage,
        prayerTimes: prayerTimes!,
        panelController: panelController,
      ),
    );
  }

  Widget _buildLoadingScreen() {
    final int random = 0 + Random().nextInt(49 - 0);
    Quran verseOfTheDay = quranicVerses[random];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            verticalBox(20),
            Text(
              verseOfTheDay.verse,
              textAlign: TextAlign.center,
              style: cusTextStyle(18, FontWeight.w700),
            ),
            verticalBox(10),
            Text(
              "${verseOfTheDay.surah} ${verseOfTheDay.ayah}",
              style: cusTextStyle(16, FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  String _getFriendlyErrorMessage(Object? error) {
    final errorStr = error?.toString() ?? '';

    // First check if LocationController has a specific error message
    if (locationController.error.isNotEmpty) {
      return locationController.error;
    }

    // Fallback to manual parsing for other errors
    if (errorStr.contains('Location services are disabled')) {
      return 'Location services are turned off. Please enable them in your device settings.';
    } else if (errorStr.contains('Location permissions are denied')) {
      return 'Location permission denied. Please allow location access for this app.';
    } else if (errorStr.contains('permanently denied')) {
      return 'Location permission permanently denied. Please enable it from your device settings.';
    } else if (errorStr.contains('PlatformException') &&
        errorStr.contains('UNAVAILABLE')) {
      return 'Location service is currently unavailable. Please try again later or check your device settings.';
    } else if (errorStr.contains('Unable to get location')) {
      return 'Could not determine your location. Please check your internet connection and make sure location services are active.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Widget _buildErrorScreen(Object? error) {
    debugPrint('Error: $error');
    // Trigger animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_showErrorAnim) {
        setState(() {
          _showErrorAnim = true;
        });
      }
    });
    bool showDetails = false;
    return StatefulBuilder(
      builder: (context, setLocalState) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: AnimatedScale(
            scale: _showErrorAnim ? 1.0 : 0.8,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: _showErrorAnim ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                          color: Colors.redAccent.withOpacity(0.25),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 120,
                          child: Image.asset(
                            'assets/location-animation.json',
                            package: null,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 80,
                            ),
                          ),
                        ),
                        verticalBox(16),
                        Text(
                          'Oops! Something went wrong',
                          style: cusTextStyle(22, FontWeight.w800),
                          textAlign: TextAlign.center,
                        ),
                        verticalBox(10),
                        Text(
                          _getFriendlyErrorMessage(error),
                          style: cusTextStyle(16, FontWeight.w400)
                              .copyWith(color: Colors.redAccent.shade100),
                          textAlign: TextAlign.center,
                        ),
                        if (error != null) ...[
                          verticalBox(8),
                          Align(
                            alignment: Alignment.center,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                                foregroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                textStyle: cusTextStyle(14, FontWeight.w500),
                              ),
                              onPressed: () {
                                setLocalState(() {
                                  showDetails = !showDetails;
                                });
                              },
                              icon: Icon(
                                showDetails
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              label: Text(
                                showDetails ? 'Hide Details' : 'Show Details',
                                style:
                                    cusTextStyle(14, FontWeight.w500).copyWith(
                                  color: Colors.redAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: showDetails
                                ? Container(
                                    key: const ValueKey('details'),
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.redAccent
                                              .withOpacity(0.15)),
                                    ),
                                    child: Text(
                                      error.toString(),
                                      style: cusTextStyle(12, FontWeight.w400)
                                          .copyWith(color: Colors.white70),
                                      textAlign: TextAlign.left,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                        verticalBox(16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showErrorAnim = false;
                              // Use LocationController's retry method
                              _future = locationController
                                  .initializeLocation()
                                  .then((_) => _initializeData());
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            textStyle: cusTextStyle(16, FontWeight.w600),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getPrayerTimes() async {
    final params = CalculationMethod.karachi.getParameters()
      ..madhab = Madhab.shafi;
    prayerTimes = PrayerTimes.today(myCoordinates, params);

    if (prayerTimes?.nextPrayer().name == "none") {
      final now = DateTime.now();
      final tomorrow =
          DateComponents.from(DateTime(now.year, now.month, now.day + 1));
      prayerTimes = PrayerTimes(myCoordinates, tomorrow, params);
    }
  }
}
