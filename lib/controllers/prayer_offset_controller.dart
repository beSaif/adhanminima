import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart';

class PrayerOffsetController extends GetxController {
  final RxMap<Prayer, int> prayerOffsets = <Prayer, int>{
    Prayer.fajr: 0,
    Prayer.sunrise: 0,
    Prayer.dhuhr: 0,
    Prayer.asr: 0,
    Prayer.maghrib: 0,
    Prayer.isha: 0,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    loadPrayerOffsets();
  }

  Future<void> loadPrayerOffsets() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedOffsets = <Prayer, int>{};
    for (var prayer in prayerOffsets.keys) {
      loadedOffsets[prayer] = prefs.getInt('prayerOffset_${prayer.name}') ?? 0;
    }
    prayerOffsets.assignAll(loadedOffsets);
  }

  Future<void> savePrayerOffsets() async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in prayerOffsets.entries) {
      await prefs.setInt('prayerOffset_${entry.key.name}', entry.value);
    }
  }

  void setOffset(Prayer prayer, int offset) {
    prayerOffsets[prayer] = offset;
    savePrayerOffsets();
    update();
  }

  void setAllOffsets(Map<Prayer, int> newOffsets) {
    prayerOffsets.assignAll(newOffsets);
    savePrayerOffsets();
    update();
  }
}
