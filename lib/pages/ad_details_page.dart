import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

class AdDetailsPage extends StatelessWidget {
  AdDetailsPage({this.clickedAdId});
  final int clickedAdId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Society App"),
        centerTitle: true,
      ),
      body: MyApp(
        clickedAdId: clickedAdId,
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  MyApp({this.clickedAdId});
  final int clickedAdId;
  @override
  _MyAppState createState() => _MyAppState(clickedAdId: clickedAdId);
}

class _MyAppState extends State<MyApp> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _MyAppState({this.clickedAdId});
  final int clickedAdId;

  Widget addetailsWidgetPage = Container(
    child: Center(
      child: Image.asset("assets/loading1.gif"),
    ),
  );

  void getAllAdvertisementDetails() async {
    var clickedAdvertisementDetailsUrl =
        urlForApi.clickedAdvertisementDetailsUrl;

    Map mapAdvertisementClickId = {"clickedAdId": clickedAdId};

    HttpClientResponse httpClientResponseForAdvertisementDetails =
        await getNetworkData.getNetworkDataUsingPostMethod(
            clickedAdvertisementDetailsUrl, mapAdvertisementClickId);

    if (httpClientResponseForAdvertisementDetails.statusCode == 200) {
      String replyForAllAdvertisementList =
          await httpClientResponseForAdvertisementDetails
              .transform(utf8.decoder)
              .join();
      var responseForAdvertisementDetails =
          jsonDecode(replyForAllAdvertisementList);

      if (responseForAdvertisementDetails['msg'] == "success") {
        var society_wise_advertisement_image_url = urlForApi.baseUrlForImages +
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_image_url'];
        var society_wise_advertisement_name =
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_name'];
        var society_wise_advertisement_description =
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_description'];
        var society_wise_advertisement_contact_details =
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_contact_details'];
        var society_wise_advertisement_contact_email_id =
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_contact_email_id'];

        double i_width = MediaQuery.of(context).size.width * 0.9;

        onTapGestureForCallIcon() async {
          var number =
              "0$society_wise_advertisement_contact_details"; //set the number here
          bool res = await FlutterPhoneDirectCaller.callNumber(number);
        }

        Future<void> _shareImageFromUrl() async {
          try {
            var request = await HttpClient()
                .getUrl(Uri.parse('$society_wise_advertisement_image_url'));
            var response = await request.close();
            Uint8List bytes =
                await consolidateHttpClientResponseBytes(response);
            await Share.file(
                'Share Advertise', 'amlog.jpg', bytes, 'image/jpg');
          } catch (e) {
            print('error: $e');
          }
        }

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
                        "$society_wise_advertisement_name",
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
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                child: FadeInImage.assetNetwork(
                  placeholder: "assets/loading1.gif",
                  image: society_wise_advertisement_image_url,
                  height: 200.0,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "$society_wise_advertisement_description",
                      style: textStyleAdDetailsDescription,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Center(
                    child: AwesomeButton(
                      blurRadius: 5.0,
                      splashColor: Color.fromRGBO(255, 255, 255, .4),
                      borderRadius: BorderRadius.circular(50.0),
                      height: 70.0,
                      width: 70.0,
                      onTap: onTapGestureForCallIcon,
                      color: reusableCardColor,
                      child: Icon(
                        Icons.call,
                        color: Colors.white,
                        size: 35.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: AwesomeButton(
                      blurRadius: 5.0,
                      splashColor: Color.fromRGBO(255, 255, 255, .4),
                      borderRadius: BorderRadius.circular(50.0),
                      height: 70.0,
                      width: 70.0,
                      onTap: () async {
                        final MailOptions mailOptions = MailOptions(
                          body: 'Hello...'
                              ''
                              ''
                              'I am interested in your advertisement which is given by you on society application. So please contact me.',
                          subject: 'Interest Shown in Advertisement',
                          recipients: [
                            '$society_wise_advertisement_contact_email_id'
                          ],
                          isHTML: true,
                          bccRecipients: ['aarfaatechnovision@gmail.com'],
                        );

                        await FlutterMailer.send(mailOptions);
                      },
                      color: reusableCardColor,
                      child: Icon(
                        Icons.mail,
                        color: Colors.white,
                        size: 35.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: AwesomeButton(
                      blurRadius: 5.0,
                      splashColor: Color.fromRGBO(255, 255, 255, .4),
                      borderRadius: BorderRadius.circular(50.0),
                      height: 70.0,
                      width: 70.0,
                      onTap: () async => await _shareImageFromUrl(),
                      color: reusableCardColor,
                      child: Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 35.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        );

        setState(() {
          addetailsWidgetPage = temp;
        });
      } else {
        Toast.show(
          "Request failed with status: ${httpClientResponseForAdvertisementDetails.statusCode}, please try again after some time",
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
