import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:societyapp/pages/loginscreen.dart';
import 'pojo_classes/constant.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Society',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'My Society'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Slide> slides = new List();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool visited = false;

  Future<bool> getSharedPreferenceValue() async {
    final SharedPreferences prefs = await _prefs;
    visited = prefs.getBool("counter") ?? false;
    if (visited) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {}
    return true;
  }

  Future<void> _setIntroSliderVisited() async {
    final SharedPreferences prefs = await _prefs;
    visited = true;

    setState(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );

      prefs.setBool("counter", visited).then((bool success) {
        return visited;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getSharedPreferenceValue();
    slides.add(
      new Slide(
        title: "My Society",
        styleTitle: textStyleForIntroSliderTitle,
        description:
            "It helps to conect society with each others and reduce your troubles...",
        styleDescription: textStyleForIntroSliderDescription,
        pathImage: "assets/society4.png",
        colorBegin: colorBeginForIntroSlider,
        colorEnd: colorEndForIntroSlider,
        directionColorBegin: Alignment.topRight,
        directionColorEnd: Alignment.bottomLeft,
      ),
    );
    slides.add(
      new Slide(
        title: "My Society",
        styleTitle: textStyleForIntroSliderTitle,
        description: "It helps to organize events and give your own ads...",
        styleDescription: textStyleForIntroSliderDescription,
        pathImage: "assets/society2.png",
        colorBegin: colorBeginForIntroSlider,
        colorEnd: colorEndForIntroSlider,
        directionColorBegin: Alignment.topRight,
        directionColorEnd: Alignment.bottomLeft,
      ),
    );
    slides.add(
      new Slide(
        title: "My Society",
        styleTitle: textStyleForIntroSliderTitle,
        description:
            "In this you are able to pay rent or society maintainance or light bill directly...",
        styleDescription: textStyleForIntroSliderDescription,
        pathImage: "assets/society5.png",
        colorBegin: colorBeginForIntroSlider,
        colorEnd: colorEndForIntroSlider,
        directionColorBegin: Alignment.topRight,
        directionColorEnd: Alignment.bottomLeft,
      ),
    );
    slides.add(
      new Slide(
        title: "My Society",
        styleTitle: textStyleForIntroSliderTitle,
        description:
            "Helps to get everything related society in single application...",
        styleDescription: textStyleForIntroSliderDescription,
        pathImage: "assets/society6.png",
        colorBegin: colorBeginForIntroSlider,
        colorEnd: colorEndForIntroSlider,
        directionColorBegin: Alignment.topRight,
        directionColorEnd: Alignment.bottomLeft,
      ),
    );
  }

  void onDonePress() {
    // Do what you want
    _setIntroSliderVisited();
  }

  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: colorOfNextButtonIntroSlider,
      size: 35.0,
    );
  }

  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      color: colorOfDoneButtonIntroSlider,
    );
  }

  Widget renderSkipBtn() {
    return Icon(
      Icons.skip_next,
      color: colorOfSkipButtonIntroSlider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      // List slides
      slides: this.slides,

      // Skip button
      renderSkipBtn: this.renderSkipBtn(),
      colorSkipBtn: colorOfBorderOfSkipButtonIntroSlider,
      highlightColorSkipBtn: colorOfHighlightOfSkipButtonIntroSlider,

      // Next button
      renderNextBtn: this.renderNextBtn(),

      // Done button
      renderDoneBtn: this.renderDoneBtn(),
      onDonePress: this.onDonePress,
      colorDoneBtn: colorOfBorderOfDoneButtonIntroSlider,
      highlightColorDoneBtn: colorOfHighlightOfDoneButtonIntroSlider,

      // Dot indicator
      colorDot: colorOfNormalDotsInIntroSlider,
      colorActiveDot: colorOfActiveDotsInIntroSlider,
      sizeDot: 13.0,

      // Show or hide status bar
      shouldHideStatusBar: true,
      backgroundColorAllSlides: colorBeginForIntroSlider,
    );
  }
}
