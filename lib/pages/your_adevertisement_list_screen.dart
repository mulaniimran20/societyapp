import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:societyapp/pages/edit_your_advertisement.dart';
import 'package:societyapp/pojo_classes/constant.dart';
import 'package:societyapp/pojo_classes/login_user_details.dart';
import 'package:societyapp/pojo_classes/url_for_api.dart';
import 'package:societyapp/pojo_classes/get_network_data.dart';
import 'package:societyapp/widgets/reusable_card.dart';
import 'package:toast/toast.dart';

URLForApi urlForApi = URLForApi();
GetNetworkData getNetworkData = GetNetworkData();

class YourAdvertisementsListScreen extends StatelessWidget {
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

  var userContactNumber;
  var userEmailIdForRazor;
  var userIdLoginPerson;

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
      getLoginUserDetails();
      getAllAdvertisementList();
    });
  }

  void getLoginUserDetails() async {
    var loginUrl = urlForApi.loginUrl;

    Map map = {
      "user_mobile_number": userMobileNumber,
      "user_password": userPassword
    };

    HttpClientResponse httpClientResponse =
        await getNetworkData.getNetworkDataUsingPostMethod(loginUrl, map);
    if (httpClientResponse.statusCode == 200) {
      String reply = await httpClientResponse.transform(utf8.decoder).join();
      var response = jsonDecode(reply);
      if (response['errmsg'] == null) {
        Toast.show(response['msg'], context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else {
        setState(() {
          loginUserDetails = LoginUserDetails(
            response['society_user_list_name'],
            response['society_user_list_contact_number'],
            response['society_user_list_flat_number'],
            response['society_user_list_email_id'],
            response['society_user_list_photo'],
            response['society_user_list_emergency_contact_number'],
            response['society_table_society_name'],
            response['society_table_society_address'],
            response['society_table_society_logo'],
            response['society_wing_name'],
            int.parse(response['society_wing_id']),
            response['society_chairman_name'],
            response['society_chairman_address'],
            response['society_chairman_contact_no'],
            response['society_chairman_email_id'],
            response['society_chairman_emamergncy_contact'],
            int.parse(response['society_table_id']),
          );
          userContactNumber = response['society_user_list_contact_number'];
          userEmailIdForRazor = response['society_user_list_email_id'];
          userSocietyId = int.parse(response['society_table_id']);
          userIdLoginPerson = int.parse(response['loginUserId']);
        });
      }
    } else {
      Toast.show(
        "Request failed with status: ${httpClientResponse.statusCode}, please try again after some time",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
    }
  }

  void getAllAdvertisementList() async {
    var allAdvertisementListFetchUrl = urlForApi.userUploadedAdvertisementList;

    Map mapAllAdvertisementList = {
      "societyId": userSocietyId,
      "userId": loginUserId
    };

    HttpClientResponse httpClientResponseForAllAdvertisementList =
        await getNetworkData.getNetworkDataUsingPostMethod(
            allAdvertisementListFetchUrl, mapAllAdvertisementList);

    if (httpClientResponseForAllAdvertisementList.statusCode == 200) {
      String replyForAllAdvertisementList =
          await httpClientResponseForAllAdvertisementList
              .transform(utf8.decoder)
              .join();
      var responseForAllAdvertisementList =
          jsonDecode(replyForAllAdvertisementList);

      if (responseForAllAdvertisementList['msg'] == "success") {
        List<Widget> listWidgetForListview = [];
        if (responseForAllAdvertisementList['loop'] > 0) {
          for (int sn = 0; sn < responseForAllAdvertisementList['loop']; sn++) {
            int society_wise_advertisement_id = int.parse(
                responseForAllAdvertisementList['data'][sn]
                    ['society_wise_advertisement_id']);

            var society_wise_advertisement_name =
                responseForAllAdvertisementList['data'][sn]
                    ['society_wise_advertisement_name'];
            var society_wise_advertisement_image_url =
                urlForApi.baseUrlForImages +
                    responseForAllAdvertisementList['data'][sn]
                        ['society_wise_advertisement_image_url'];
            var society_wise_advertisement_short_description =
                responseForAllAdvertisementList['data'][sn]
                    ['society_wise_advertisement_short_description'];

            var society_wise_advertisement_given_date_time =
                responseForAllAdvertisementList['data'][sn]
                    ['society_wise_advertisement_given_date_time'];

            Widget reusableCardForSingleAdDisplay;
            if (sn % 2 == 0) {
              reusableCardForSingleAdDisplay = ReusableCard(
                color: reusableCardColor,
                onTapGestureFunction: () {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditYourAdvertisement(
                                adid: society_wise_advertisement_id,
                                societyIdPassed: userSocietyId,
                                userIdPassed: userIdLoginPerson,
                              )),
                    );
                  });
                },
                newheight: 100.0,
                cardChild: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            child: FadeInImage.assetNetwork(
                              placeholder: "assets/loading1.gif",
                              image: society_wise_advertisement_image_url,
                              height: 110.0,
                              width: 150.0,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: <Widget>[
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "$society_wise_advertisement_name",
                                    style: textStyleAdvertisementCardHeading,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "$society_wise_advertisement_short_description",
                                    style:
                                        textStyleAdvertisementCardDescription,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else {
              reusableCardForSingleAdDisplay = ReusableCard(
                color: reusableCardColor,
                onTapGestureFunction: () {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditYourAdvertisement(
                                adid: society_wise_advertisement_id,
                                societyIdPassed: userSocietyId,
                                userIdPassed: userIdLoginPerson,
                              )),
                    );
                  });
                },
                newheight: 100.0,
                cardChild: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: <Widget>[
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "$society_wise_advertisement_name",
                                    style: textStyleAdvertisementCardHeading,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "$society_wise_advertisement_short_description",
                                    style:
                                        textStyleAdvertisementCardDescription,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            child: FadeInImage.assetNetwork(
                              placeholder: "assets/loading1.gif",
                              image: society_wise_advertisement_image_url,
                              height: 110.0,
                              width: 150.0,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            listWidgetForListview.add(reusableCardForSingleAdDisplay);
            if (sn == (responseForAllAdvertisementList['loop'] - 1)) {
              setState(() {
                societyMaintainancePageDetailsWidget = ListView(
                  children: listWidgetForListview,
                );
              });
            }
          }
        } else {
          Widget reusableCardForSingleAdDisplay = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ReusableCard(
                color: reusableCardColor,
                newheight: 150.0,
                cardChild: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Flexible(
                                child: Center(
                                  child: Text(
                                    "Currently none of your advertise is live right now, please give advertise first.",
                                    style: textStyleAdvertisementCardForNoAdMsg,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
          setState(() {
            societyMaintainancePageDetailsWidget =
                reusableCardForSingleAdDisplay;
          });
        }
      }
    } else {
      Toast.show(
        "Request failed with status: ${httpClientResponseForAllAdvertisementList.statusCode}, please try again after some time",
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
