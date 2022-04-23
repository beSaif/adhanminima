import 'package:adhanminima/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:android_intent/android_intent.dart';

// remove --no-sound-null-safety from Preference>Settings  Flutter run additional args
void main() {
  debugRepaintTextRainbowEnabled = false;
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
