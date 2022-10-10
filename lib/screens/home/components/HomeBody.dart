import 'package:adhanminima/API/api_services.dart';
import 'package:adhanminima/GetX/prayerdata.dart';
import 'package:adhanminima/Screens/home/Components/Background.dart';
import 'package:adhanminima/Screens/home/Components/TimeLeft.dart';
import 'package:adhanminima/Screens/home/Components/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:adhanminima/screens/home/components/panelWidget.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({Key? key}) : super(key: key);

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final panelController = PanelController();
  final PrayerDataController prayerDataController =
      Get.put(PrayerDataController(), permanent: false);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      constraints: const BoxConstraints.expand(),
      decoration: appBackground(),
      child: FutureBuilder(
          future: APIServices.determinePosition(context),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (!snapshot.hasData) {
              return loadingIndicator();
            }

            // Storing positions in Controller.
            prayerDataController.updatePosition(snapshot.data);

            return SlidingUpPanel(
              controller: panelController,
              parallaxEnabled: true,
              parallaxOffset: .6,
              color: Colors.transparent,
              body: const TimeLeft(),
              panelBuilder: (controller) => PanelWidget(
                controller: controller,
                panelController: panelController,
              ),
            );
          }),
    );
  }
}
