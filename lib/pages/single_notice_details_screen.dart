import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:societyapp/pojo_classes/url_for_api.dart';
import 'package:societyapp/pojo_classes/constant.dart';
import 'package:societyapp/pojo_classes/get_network_data.dart';
import 'package:toast/toast.dart';
import 'package:awesome_button/awesome_button.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
//import 'package:screenshot_share_image/screenshot_share_image.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

URLForApi urlForApi = URLForApi();
GetNetworkData getNetworkData = GetNetworkData();

class SingleNoticeDetailsScreen extends StatelessWidget {
  SingleNoticeDetailsScreen({this.clickedNoticeId});
  final int clickedNoticeId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Society App"),
        centerTitle: true,
      ),
      body: MyApp(
        clickedNoticeId: clickedNoticeId,
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  MyApp({this.clickedNoticeId});
  final int clickedNoticeId;
  @override
  _MyAppState createState() => _MyAppState(clickedNoticeId: clickedNoticeId);
}

class _MyAppState extends State<MyApp> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _MyAppState({this.clickedNoticeId});
  final int clickedNoticeId;

  Widget addetailsWidgetPage = Container(
    child: Center(
      child: Image.asset("assets/loading1.gif"),
    ),
  );

  void getAllAdvertisementDetails() async {
    var getSingleNoticeDetailsUrl = urlForApi.getSingleNoticeDetailsUrl;

    Map mapNoticeClickId = {"clickedNoticeId": clickedNoticeId};

    HttpClientResponse httpClientResponseForNoticeDetails =
        await getNetworkData.getNetworkDataUsingPostMethod(
            getSingleNoticeDetailsUrl, mapNoticeClickId);

    if (httpClientResponseForNoticeDetails.statusCode == 200) {
      String replyForAllNoticeList = await httpClientResponseForNoticeDetails
          .transform(utf8.decoder)
          .join();
      var responseForNoticeDetails = jsonDecode(replyForAllNoticeList);

      if (responseForNoticeDetails['msg'] == "success") {
        var notice_icon_url = urlForApi.baseUrlForImages +
            responseForNoticeDetails['data']['notice_icon_url'];

        var notice_title = responseForNoticeDetails['data']['notice_title'];

        var notice_description =
            responseForNoticeDetails['data']['notice_description'];

        var notice_given_date_time =
            responseForNoticeDetails['data']['notice_given_date_time'];

        double i_width = MediaQuery.of(context).size.width * 0.9;

        Widget temp = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 15.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        "$notice_title",
                        style: textAdDetailsHeadingStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            /*Container(
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                child: FadeInImage.assetNetwork(
                  placeholder: "assets/loading1.gif",
                  image: notice_icon_url,
                  height: 200.0,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),*/
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Html(
                      data: "$notice_description",
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        );

        setState(() {
          addetailsWidgetPage = temp;
        });
      } else {
        Toast.show(
          "Request failed with status: ${httpClientResponseForNoticeDetails.statusCode}, please try again after some time",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllAdvertisementDetails();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: addetailsWidgetPage,
    );
  }
}
