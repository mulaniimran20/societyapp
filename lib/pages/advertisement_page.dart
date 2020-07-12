import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:societyapp/pages/all_advertisement_list_page.dart';
import 'package:societyapp/pages/common_notice_for_all_list.dart';
import 'package:societyapp/pages/give_your_add_page.dart';
import 'package:societyapp/pages/your_adevertisement_list_screen.dart';
import 'package:societyapp/pojo_classes/constant.dart';
import 'package:societyapp/pojo_classes/url_for_api.dart';
import 'package:societyapp/widgets/icon_content.dart';
import 'package:societyapp/widgets/reusable_card.dart';

URLForApi urlForApi = URLForApi();

class AdvertisementPage extends StatelessWidget {
  AdvertisementPage({this.userIdPassed, this.userSocietyId});

  final int userIdPassed;
  final int userSocietyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Society App"),
        centerTitle: true,
      ),
      body: MyApp(userIdPassed: userIdPassed, userSocietyId: userSocietyId),
    );
  }
}

class MyApp extends StatefulWidget {
  MyApp({this.userIdPassed, this.userSocietyId});

  final int userIdPassed;
  final int userSocietyId;

  @override
  _MyAppState createState() =>
      _MyAppState(userIdPassed: userIdPassed, userSocietyId: userSocietyId);
}

class _MyAppState extends State<MyApp> {
  _MyAppState({this.userIdPassed, this.userSocietyId});
  final int userIdPassed;
  final int userSocietyId;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              child: FadeInImage.assetNetwork(
                placeholder: "assets/loading1.gif",
                image: urlForApi.baseUrlForImages +
                    "images/advertisements/adssc.jpg",
                height: 200.0,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          ResponsiveGridRow(children: [
            ResponsiveGridCol(
              xs: 6,
              md: 6,
              child: ReusableCard(
                color: reusableCardColor,
                onTapGestureFunction: () {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AllAdvertisementListScreen()),
                    );
                  });
                },
                cardChild: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: IconContent(
                    textColor: iconTextColor,
                    sizeBoXHeight: 20.0,
                    textContent: "Advertisements",
                    icon: AssetImage("assets/ads.png"),
                    iconSizeHeight: 72.0,
                    iconSizeWidth: 72.0,
                  ),
                ),
              ),
            ), //all advetisements list
            ResponsiveGridCol(
              xs: 6,
              md: 6,
              child: ReusableCard(
                color: reusableCardColor,
                onTapGestureFunction: () {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GiveYourAddPage(
                                userIdPassed: userIdPassed,
                                societyIdPassed: userSocietyId,
                              )),
                    );
                  });
                },
                cardChild: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: IconContent(
                    textColor: iconTextColor,
                    sizeBoXHeight: 20.0,
                    textContent: "Give Your Advertisements",
                    icon: AssetImage("assets/ads.png"),
                    iconSizeHeight: 72.0,
                    iconSizeWidth: 72.0,
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 3,
              md: 3,
              child: Container(),
            ), // give your own advertisement option
            ResponsiveGridCol(
              xs: 6,
              md: 6,
              child: ReusableCard(
                color: reusableCardColor,
                onTapGestureFunction: () {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => YourAdvertisementsListScreen()),
                    );
                  });
                },
                cardChild: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: IconContent(
                    textColor: iconTextColor,
                    sizeBoXHeight: 20.0,
                    textContent: "Your Advertisements",
                    icon: AssetImage("assets/ads.png"),
                    iconSizeHeight: 72.0,
                    iconSizeWidth: 72.0,
                  ),
                ),
              ),
            ), // your advrtisements
          ]), // complete grid layout of all options
        ],
      ),
    );
  }
}
