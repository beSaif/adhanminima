import 'package:adhanminima/Model/all_data.dart';
import 'package:get/get.dart';

class PrayerDataController extends GetxController {
  late AllData allData;

  void updateAllData(AllData _allData) {
    allData = _allData;
  }
}
