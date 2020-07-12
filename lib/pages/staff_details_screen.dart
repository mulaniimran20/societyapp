import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:societyapp/pojo_classes/constant.dart';
import 'package:societyapp/pojo_classes/url_for_api.dart';
import 'package:societyapp/pojo_classes/get_network_data.dart';
import 'package:toast/toast.dart';
import 'package:societyapp/widgets/contact_details_card.dart';

URLForApi urlForApi = URLForApi();
GetNetworkData getNetworkData = GetNetworkData();

class StaffDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Society App"),
        centerTitle: true,
      ),
      body: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int societyId = 0;

  Widget emergencyScreenDetailsWidget = Container(
    width: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset("assets/tenor.gif"),
      ],
    ),
  );

  Future<bool> getLoginDetailsSharedPreference() async {
    final SharedPreferences prefs = await _prefs;
    societyId = prefs.getInt("userSocietyId") ?? 0;
    setState(() {
      getEmergencyPageDetails();
    });
  }

  void getEmergencyPageDetails() async {
    String urlForStaffDetailsList = urlForApi.staffDetailsUrl;
    Map mapSocietyId = {"societyId": societyId};

    HttpClientResponse httpClientResponseForEmergencyContactListUrl =
        await getNetworkData.getNetworkDataUsingPostMethod(
            urlForStaffDetailsList, mapSocietyId);

    emergencyScreenDetailsWidget = ListView();
    List<Widget> list = [];

    if (httpClientResponseForEmergencyContactListUrl.statusCode == 200) {
      String reply = await httpClientResponseForEmergencyContactListUrl
          .transform(utf8.decoder)
          .join();
      var response = jsonDecode(reply);
      if (response['msg'] != "success") {
        Toast.show(response['msg'], context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else {
        for (int i = 0; i < response['loop']; i++) {
          Widget contactCard = ContactDetailsCard(
            cardUserContactNumber: response['data'][0]
                ['staff_contact_list_staff_contact_number'],
            cardUserName: response['data'][0]['staff_contact_list_staff_name'],
            cardUserEmailId: response['data'][0]
                ['staff_contact_list_staff_email_id'],
            cardUserPost: response['data'][0]
                ['staff_contact_list_staff_position'],
            color: reusableCardColor,
            cardWithImage: false,
            imageUrl: response['data'][0]['staff_contact_list_staff_photo_url'],
          );

          list.add(contactCard);

          if (i == (response['loop'] - 1)) {
            setState(() {
              emergencyScreenDetailsWidget = ListView(
                children: list,
              );
            });
          }
        }
      }
    } else {
      Toast.show(
        "Request failed with status: ${httpClientResponseForEmergencyContactListUrl.statusCode}, please try again after some time",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
    }

    setState(() {
      emergencyScreenDetailsWidget = ListView(
        children: list,
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoginDetailsSharedPreference();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: emergencyScreenDetailsWidget,
    );
  }
}
