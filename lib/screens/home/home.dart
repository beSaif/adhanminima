import 'package:adhanminima/API/api_services.dart';
import 'package:adhanminima/Screens/home/Components/home_body.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    APIServices.determinePosition(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: HomeBody());
  }
}
