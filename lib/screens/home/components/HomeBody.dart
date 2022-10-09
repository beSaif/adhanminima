import 'package:adhanminima/Screens/home/Components/Background.dart';
import 'package:adhanminima/Screens/home/Components/TimeLeft.dart';
import 'package:adhanminima/Screens/home/Components/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:adhanminima/screens/home/components/panelWidget.dart';
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({Key? key}) : super(key: key);

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final panelController = PanelController();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      constraints: const BoxConstraints.expand(),
      decoration: appBackground(),
      child: FutureBuilder(
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return loadingIndicator();
        }
        return SlidingUpPanel(
          controller: panelController,
          parallaxEnabled: true,
          parallaxOffset: .6,
          color: Colors.transparent,
          body: TimeLeft(),
          panelBuilder: (controller) => PanelWidget(
            controller: controller,
            panelController: panelController,
          ),
        );
      }),
    );
  }
}
