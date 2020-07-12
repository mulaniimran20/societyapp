import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:societyapp/pages/single_notice_details_screen.dart';
import 'package:societyapp/pojo_classes/constant.dart';
import 'package:societyapp/pojo_classes/login_user_details.dart';
import 'package:societyapp/pojo_classes/url_for_api.dart';
import 'package:societyapp/pojo_classes/get_network_data.dart';
import 'package:societyapp/widgets/reusable_card.dart';
import 'package:toast/toast.dart';
import 'package:societyapp/pages/ad_details_page.dart';
import 'package:flutter_html/flutter_html.dart';

URLForApi urlForApi = URLForApi();
GetNetworkData getNetworkData = GetNetworkData();

class CommonNoticeForAllScreen extends StatelessWidget {
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
  int loginUserId = 0;
  int societyId = 0;

  int totalAmountForPayment = 0;
  LoginUserDetails loginUserDetails;

  var userMobileNumber;
  var userPassword;
  int userSocietyId = 0;

  var tocalculatenextpaymentdate;
  var durationtocalcultenextpaymentdate;

  Widget societyMaintainancePageDetailsWidget = Container(
    width: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset("assets/loading1.gif"),
      ],
    ),
  );
  Widget societyMaintainanceHistoryDetailsWidget = Container();

  Future<bool> getLoginDetailsSharedPreference() async {
    final SharedPreferences prefs = await _prefs;
    loginUserId = prefs.getInt("userLoginId") ?? 0;
    userMobileNumber = prefs.getString("loginMobileNumber") ?? "";
    userPassword = prefs.getString("userPassword") ?? "";
    userSocietyId = prefs.getInt("userSocietyId") ?? 0;
    setState(() {
      getAllAdvertisementList();
    });
  }

  void getAllAdvertisementList() async {
    var commonNoticeForAllUrl = urlForApi.commonNoticeForAllUrl;

    Map mapAllCommonNoticeList = {"societyId": userSocietyId};

    HttpClientResponse httpClientResponseForAllCommonNotice =
        await getNetworkData.getNetworkDataUsingPostMethod(
            commonNoticeForAllUrl, mapAllCommonNoticeList);

    if (httpClientResponseForAllCommonNotice.statusCode == 200) {
      String replyForAllCommonNoticeList =
          await httpClientResponseForAllCommonNotice
              .transform(utf8.decoder)
              .join();
      var responseForAllCommonNoticeList =
          jsonDecode(replyForAllCommonNoticeList);

      if (responseForAllCommonNoticeList['msg'] == "success") {
        List<Widget> listWidgetForListview = [];

        if (responseForAllCommonNoticeList['loop'] > 0) {
          for (int sn = 0; sn < responseForAllCommonNoticeList['loop']; sn++) {
            int notice_id = int.parse(
                responseForAllCommonNoticeList['data'][sn]['notice_id']);

            var notice_title =
                responseForAllCommonNoticeList['data'][sn]['notice_title'];

            var notice_icon_url = urlForApi.baseUrlForImages +
                responseForAllCommonNoticeList['data'][sn]['notice_icon_url'];

            var notice_description_short =
                responseForAllCommonNoticeList['data'][sn]
                    ['notice_description_short'];

            Widget reusableCardForSingleAdDisplay;

            reusableCardForSingleAdDisplay = ReusableCard(
              color: reusableCardColor,
              onTapGestureFunction: () {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SingleNoticeDetailsScreen(
                              clickedNoticeId: notice_id,
                            )),
                  );
                });
              },
              newheight: 150.0,
              cardChild: Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          "$notice_title",
                          style: textStyleNoticeCardHeading,
                        ),
                      ),
                      Html(
                        data: "$notice_description_short",
                      ),
                    ],
                  ),
                ),
              ),
            );

            listWidgetForListview.add(reusableCardForSingleAdDisplay);
            if (sn == (responseForAllCommonNoticeList['loop'] - 1)) {
              setState(() {
                societyMaintainancePageDetailsWidget = ListView(
                  children: listWidgetForListview,
                );
              });
            }
          }
        } else {
          Widget reusableCardForSingleAdDisplay = ReusableCard(
            color: reusableCardColor,
            newheight: 100.0,
            cardChild: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                      "Currently no any advertisement available from your side, give advertise first..."),
                ),
              ],
            ),
          );
          listWidgetForListview = [reusableCardForSingleAdDisplay];
          setState(() {
            societyMaintainancePageDetailsWidget = ListView(
              children: listWidgetForListview,
            );
          });
        }
      }
    } else {
      Toast.show(
        "Request failed with status: ${httpClientResponseForAllCommonNotice.statusCode}, please try again after some time",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoginDetailsSharedPreference();
  }

  @override
  Widget build(BuildContext context) {
    return societyMaintainancePageDetailsWidget;
  }
}
