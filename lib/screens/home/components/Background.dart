import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

BoxDecoration appBackground() {
  return BoxDecoration(
      color: Colors.black,
      image: DecorationImage(
        image: const AssetImage("assets/bg.jpg"),
        colorFilter:
            ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.dstATop),
        fit: BoxFit.cover,
      ));
}
