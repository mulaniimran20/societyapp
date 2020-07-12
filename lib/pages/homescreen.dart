import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:societyapp/pages/advertisement_page.dart';
import 'package:societyapp/pages/electricity_bill_page.dart';
import 'package:societyapp/pages/give_your_add_page.dart';
import 'package:societyapp/pages/notice_board_screen.dart';
import 'package:societyapp/pages/your_adevertisement_list_screen.dart';
import 'package:societyapp/pojo_classes/constant.dart';
import 'package:societyapp/pojo_classes/url_for_api.dart';
import 'package:societyapp/pojo_classes/get_network_data.dart';
import 'package:toast/toast.dart';
import 'package:societyapp/pojo_classes/login_user_details.dart';
import 'package:societyapp/widgets/reusable_card.dart';
import 'package:societyapp/widgets/icon_content.dart';
import 'package:societyapp/pages/emergency_contact_screen.dart';
import 'package:societyapp/pages/staff_details_screen.dart';
import 'package:societyapp/pages/society_maintainace_screen.dart';
import 'package:societyapp/pages/all_advertisement_list_page.dart';
import 'package:societyapp/pages/ad_details_page.dart';

URLForApi urlForApi = URLForApi();
GetNetworkData getNetworkData = GetNetworkData();
BuildContext contextm;
String userContactNumber;
String userEmailIdForRazor;

final List<Map> imgList = [];

final List<Map> imgListTemp = [
  {
    "adid": 0,
    "urlForImage": "https://aarfaatechnovision.com/aarfaasociety/tenor.gif"
  }
];

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
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

  String userMobileNumber;
  String userPassword;
  int userSocietyId;
  String society_notice_board_banner;
  int userIdPassed;
  LoginUserDetails loginUserDetails;

  List<Widget> imageSliders = imgListTemp
      .map((item) => Container(
            child: GestureDetector(
              onTap: () {
                var adid = item['adid'];
              },
              child: Container(
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        FadeInImage.assetNetwork(
                          placeholder: 'assets/loading1.gif',
                          image: item['urlForImage'],
                          fit: BoxFit.cover,
                          width: 1000.0,
                          height: 150.0,
                        ),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          ))
      .toList();

  Future<bool> getLoginDetailsSharedPreference() async {
    final SharedPreferences prefs = await _prefs;
    userMobileNumber = prefs.getString("loginMobileNumber") ?? "";
    userPassword = prefs.getString("userPassword") ?? "";
    userSocietyId = prefs.getInt("userSocietyId") ?? 0;
    society_notice_board_banner =
        prefs.getString("society_notice_board_banner") ?? "";
    getLoginUserDetails();
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
          userIdPassed = int.parse(response['loginUserId']);
          userSocietyId = int.parse(response['society_table_id']);
          userMobileNumber = response['society_user_list_contact_number'];
          userEmailIdForRazor = response['society_user_list_email_id'];
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

    var sliderAdvertiseUrl = urlForApi.sliderAdvertiseUrl;
    Map mapForSliderAdvertise = {"societyId": userSocietyId};

    HttpClientResponse httpClientResponseSliderAds =
        await getNetworkData.getNetworkDataUsingPostMethod(
            sliderAdvertiseUrl, mapForSliderAdvertise);
    if (httpClientResponseSliderAds.statusCode == 200) {
      String reply =
          await httpClientResponseSliderAds.transform(utf8.decoder).join();
      var response = jsonDecode(reply);
      print(response);
      if (response['msg'] == "success") {
        for (int i = 0; i < response['loop']; i++) {
          int adid = response['data'][i]['society_wise_advertisement_id'];
          var urlForImage = urlForApi.baseUrlForImages +
              response['data'][i]['society_wise_advertisement_image_url'];
          Map admap = {"adid": adid, "urlForImage": urlForImage};
          imgList.add(admap);

          if (i == response['loop'] - 1) {
            setState(() {
              imageSliders = imgList
                  .map((item) => Container(
                        child: GestureDetector(
                          onTap: () {
                            var adid = item['adid'];

                            Navigator.push(
                              contextm,
                              MaterialPageRoute(
                                  builder: (contextm) => AdDetailsPage(
                                        clickedAdId: adid,
                                      )),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.all(5.0),
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                child: Stack(
                                  children: <Widget>[
                                    FadeInImage.assetNetwork(
                                      placeholder: 'assets/loading1.gif',
                                      image: item['urlForImage'],
                                      fit: BoxFit.cover,
                                      width: 1000.0,
                                      height: 150.0,
                                    ),
                                    Positioned(
                                      bottom: 0.0,
                                      left: 0.0,
                                      right: 0.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color.fromARGB(200, 0, 0, 0),
                                              Color.fromARGB(0, 0, 0, 0)
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ))
                  .toList();
            });
          }
        }
      } else {
        Toast.show("Network Error, Please try after sometime...", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoginDetailsSharedPreference();
  }

  @override
  Widget build(BuildContext context) {
    contextm = context;
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0),
        child: Column(
          children: <Widget>[
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 2.0,
                enlargeCenterPage: true,
              ),
              items: imageSliders,
            ), //for adverrtisement sliders
            ResponsiveGridRow(children: [
              ResponsiveGridCol(
                xs: 4,
                md: 3,
                child: ReusableCard(
                  color: reusableCardColor,
                  onTapGestureFunction: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EmergencyContactList()),
                      );
                    });
                  },
                  cardChild: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: IconContent(
                      textColor: iconTextColor,
                      sizeBoXHeight: 20.0,
                      textContent: "Emergency Contacts",
                      icon: AssetImage("assets/emergency.png"),
                      iconSizeHeight: 72.0,
                      iconSizeWidth: 72.0,
                    ),
                  ),
                ),
              ), // emergency contacts tab
              ResponsiveGridCol(
                xs: 4,
                md: 3,
                child: ReusableCard(
                  onTapGestureFunction: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StaffDetailsScreen()),
                      );
                    });
                  },
                  color: reusableCardColor,
                  cardChild: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: IconContent(
                      textColor: iconTextColor,
                      sizeBoXHeight: 20.0,
                      textContent: "Staff",
                      icon: AssetImage("assets/workers.png"),
                      iconSizeHeight: 72.0,
                      iconSizeWidth: 72.0,
                    ),
                  ),
                ),
              ), // staff details tab
              ResponsiveGridCol(
                xs: 4,
                md: 3,
                child: ReusableCard(
                  color: reusableCardColor,
                  onTapGestureFunction: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SocietyMaintainaceScreen()),
                      );
                    });
                  },
                  cardChild: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: IconContent(
                      textColor: iconTextColor,
                      sizeBoXHeight: 20.0,
                      textContent: "Society Maintainance",
                      icon: AssetImage("assets/man.png"),
                      iconSizeHeight: 72.0,
                      iconSizeWidth: 72.0,
                    ),
                  ),
                ),
              ), //Society Maintainance history and current details
              ResponsiveGridCol(
                xs: 4,
                md: 3,
                child: ReusableCard(
                  color: reusableCardColor,
                  onTapGestureFunction: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ElectricityBillPage(),
                        ),
                      );
                    });
                  },
                  cardChild: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: IconContent(
                      textColor: iconTextColor,
                      sizeBoXHeight: 5.0,
                      textContent: "Electricity Bill",
                      icon: AssetImage("assets/electricity.png"),
                      iconSizeHeight: 72.0,
                      iconSizeWidth: 72.0,
                    ),
                  ),
                ),
              ), // all electricity bill details and payment option
              ResponsiveGridCol(
                xs: 4,
                md: 3,
                child: ReusableCard(
                  color: reusableCardColor,
                  onTapGestureFunction: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdvertisementPage(
                            userIdPassed: userIdPassed,
                            userSocietyId: userSocietyId,
                          ),
                        ),
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
              /*ResponsiveGridCol(
                xs: 4,
                md: 3,
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
              ), // give your own advertisement option
              ResponsiveGridCol(
                xs: 4,
                md: 3,
                child: ReusableCard(
                  color: reusableCardColor,
                  onTapGestureFunction: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                YourAdvertisementsListScreen()),
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
              ),*/ // your advrtisements list and editing option
              ResponsiveGridCol(
                xs: 4,
                md: 3,
                child: ReusableCard(
                  color: reusableCardColor,
                  onTapGestureFunction: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoticeBoardScreen(
                            noticeboardimage: society_notice_board_banner,
                            userId: userIdPassed,
                            societyId: userSocietyId,
                          ),
                        ),
                      );
                    });
                  },
                  cardChild: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: IconContent(
                      textColor: iconTextColor,
                      sizeBoXHeight: 20.0,
                      textContent: "Notice Board",
                      icon: AssetImage("assets/furniture.png"),
                      iconSizeHeight: 72.0,
                      iconSizeWidth: 72.0,
                    ),
                  ),
                ),
              ), //notice board option for check all society notice and notice for single user
              ResponsiveGridCol(
                xs: 4,
                md: 3,
                child: ReusableCard(
                  color: reusableCardColor,
                  cardChild: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: IconContent(
                      textColor: iconTextColor,
                      sizeBoXHeight: 20.0,
                      textContent: "Give Your Event Invtation",
                      icon: AssetImage("assets/events.png"),
                      iconSizeHeight: 72.0,
                      iconSizeWidth: 72.0,
                    ),
                  ),
                ),
              ), //give your event invitation or ticket option
              ResponsiveGridCol(
                xs: 4,
                md: 3,
                child: ReusableCard(
                  color: reusableCardColor,
                  cardChild: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: IconContent(
                      textColor: iconTextColor,
                      sizeBoXHeight: 20.0,
                      textContent: "Events",
                      icon: AssetImage("assets/events.png"),
                      iconSizeHeight: 72.0,
                      iconSizeWidth: 72.0,
                    ),
                  ),
                ),
              ), //all event list and event booking options
              ResponsiveGridCol(
                xs: 4,
                md: 3,
                child: ReusableCard(
                  color: reusableCardColor,
                  cardChild: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: IconContent(
                      textColor: iconTextColor,
                      sizeBoXHeight: 20.0,
                      textContent: "User Profile",
                      icon: AssetImage("assets/profiles.png"),
                      iconSizeHeight: 72.0,
                      iconSizeWidth: 72.0,
                    ),
                  ),
                ),
              ), //user profile options
            ]), // complete grid layout of all options
          ],
        ),
      ),
    );
  }
}
