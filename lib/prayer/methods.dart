import 'package:adhan/adhan.dart';

class MethodInfo {
  const MethodInfo(this.method, this.name, this.detail);

  final CalculationMethod method;
  final String name;
  final String detail;
}

/// Calculation methods offered in Settings, most widely used first.
const calculationMethods = [
  MethodInfo(CalculationMethod.karachi, 'Karachi', 'Fajr 18° · Isha 18°'),
  MethodInfo(
    CalculationMethod.muslim_world_league,
    'Muslim World League',
    'Fajr 18° · Isha 17°',
  ),
  MethodInfo(
    CalculationMethod.north_america,
    'North America (ISNA)',
    'Fajr 15° · Isha 15°',
  ),
  MethodInfo(
    CalculationMethod.umm_al_qura,
    'Umm al-Qura, Makkah',
    'Fajr 18.5° · Isha 90 min after Maghrib',
  ),
  MethodInfo(
    CalculationMethod.egyptian,
    'Egyptian General Authority',
    'Fajr 19.5° · Isha 17.5°',
  ),
  MethodInfo(
    CalculationMethod.turkey,
    'Turkey (Diyanet)',
    'Fajr 18° · Isha 17°',
  ),
  MethodInfo(
    CalculationMethod.moon_sighting_committee,
    'Moonsighting Committee',
    'Fajr 18° · Isha 18°',
  ),
  MethodInfo(CalculationMethod.dubai, 'Dubai', 'Fajr 18.2° · Isha 18.2°'),
  MethodInfo(CalculationMethod.kuwait, 'Kuwait', 'Fajr 18° · Isha 17.5°'),
  MethodInfo(
    CalculationMethod.qatar,
    'Qatar',
    'Fajr 18° · Isha 90 min after Maghrib',
  ),
  MethodInfo(CalculationMethod.singapore, 'Singapore', 'Fajr 20° · Isha 18°'),
  MethodInfo(CalculationMethod.tehran, 'Tehran', 'Fajr 17.7° · Isha 14°'),
];

MethodInfo methodInfo(CalculationMethod method) =>
    calculationMethods.firstWhere((m) => m.method == method);
