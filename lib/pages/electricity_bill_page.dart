import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:societyapp/pojo_classes/constant.dart';
import 'package:societyapp/pojo_classes/login_user_details.dart';
import 'package:societyapp/pojo_classes/url_for_api.dart';
import 'package:societyapp/pojo_classes/get_network_data.dart';
import 'package:societyapp/widgets/reusable_card.dart';
import 'package:toast/toast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

URLForApi urlForApi = URLForApi();
GetNetworkData getNetworkData = GetNetworkData();

var billingMonth;

class ElectricityBillPage extends StatelessWidget {
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

  var totalAmountForPayment = 0.00;
  Razorpay _razorpay;
  LoginUserDetails loginUserDetails;

  var userMobileNumber;
  var userPassword;
  var userSocietyId;
  var electricityBillConsumerNumber;
  var userContactNumber;
  var userEmailIdForRazor;
  var userIdLoginPerson;
  var electricityUserBillingUnitNumber;
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
  Widget societyMaintainanceHistoryDetailsWidget = Container(
    width: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset("assets/loading1.gif"),
      ],
    ),
  );
  Widget headingWidget = Container();

  Future<bool> getLoginDetailsSharedPreference() async {
    final SharedPreferences prefs = await _prefs;
    loginUserId = prefs.getInt("userLoginId") ?? 0;
    userMobileNumber = prefs.getString("loginMobileNumber") ?? "";
    userPassword = prefs.getString("userPassword") ?? "";
    setState(() {
      getLoginUserDetails();
      getMaintanancePageDetails();
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
          electricityUserBillingUnitNumber =
              response['user_billing_unit_number_for_electricity_bill'];
          electricityBillConsumerNumber =
              response['user_electricity_bill_number'];
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

  void getUserHistoryDetails() async {
    var maintainancePaymentHistoryFetchUrl =
        urlForApi.electricityBillPaymentHistoryFetchUrl;

    Map mapMaintainaneceHistory = {"userLoginId": loginUserId};

    HttpClientResponse httpClientResponseForMainHistory =
        await getNetworkData.getNetworkDataUsingPostMethod(
            maintainancePaymentHistoryFetchUrl, mapMaintainaneceHistory);
    if (httpClientResponseForMainHistory.statusCode == 200) {
      String replyForMainHistory =
          await httpClientResponseForMainHistory.transform(utf8.decoder).join();
      var responseForMainHistory = jsonDecode(replyForMainHistory);

      if (responseForMainHistory['msg'] == "success") {
        if (responseForMainHistory['nohistory']) {
          setState(() {
            societyMaintainanceHistoryDetailsWidget = Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ReusableCard(
                    color: reusableCardColor,
                    cardChild: Center(child: Text("No History Available")),
                  ),
                ],
              ),
            );

            societyMaintainancePageDetailsWidget = Column(
              children: <Widget>[
                headingWidget,
                societyMaintainanceHistoryDetailsWidget,
              ],
            );
          });
        } else {
          societyMaintainanceHistoryDetailsWidget = Container();

          setState(() {
            List<Widget> listOfReusableCardsForManHistory = [
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Center(
                    child: Text(
                  "Electricity Bill History",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                )),
              ),
            ];

            for (var n = 0; n < responseForMainHistory['loop']; n++) {
              var maintainance_payment_history_paid_id =
                  responseForMainHistory['response'][n]
                      ['electricity_billing_payment_history_payment_id'];
              var maintainance_payment_history_payment_amount =
                  responseForMainHistory['response'][n]
                      ['electricity_billing_paymnet_amount'];
              var maintainance_payment_history_paid_date =
                  responseForMainHistory['response'][n]
                      ['electricity_billing_payment_history_payment_date'];

              billingMonth = responseForMainHistory['response'][n]
                  ['electricity_billing_payment_history_payment_date'];

              Widget reusableCardWidForSingleHistorycomponenet = ReusableCard(
                color: reusableCardColor,
                cardChild: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: <Widget>[
                                Icon(FontAwesomeIcons.fileInvoiceDollar),
                                SizedBox(width: 15.0),
                                Text(
                                  "$maintainance_payment_history_paid_id",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "Rs. $maintainance_payment_history_payment_amount /-",
                                    style: TextStyle(fontSize: 12.0),
                                  ),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  Icon(FontAwesomeIcons.angleDoubleRight),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Container(
                        height: 1.0,
                        width: double.infinity,
                        color: Color(0XFF000000),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "$maintainance_payment_history_paid_date",
                                style: TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
              listOfReusableCardsForManHistory
                  .add(reusableCardWidForSingleHistorycomponenet);

              if (n == (responseForMainHistory['loop'] - 1)) {
                setState(() {
                  societyMaintainanceHistoryDetailsWidget = Column(
                    children: listOfReusableCardsForManHistory,
                  );

                  societyMaintainancePageDetailsWidget = Column(
                    children: <Widget>[
                      headingWidget,
                      societyMaintainanceHistoryDetailsWidget,
                    ],
                  );
                });
              }
            }
          });
        }
      }
    } else {
      Toast.show(
        "Request failed with status: ${httpClientResponseForMainHistory.statusCode}, please try again after some time",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
    }
  }

  void getMaintanancePageDetails() async {
    String urlForEmergencyContactList = urlForApi.getElectricityBillDetailys;
    Map mapUserId = {"userLoginId": loginUserId};

    HttpClientResponse httpClientResponseForEmergencyContactListUrl =
        await getNetworkData.getNetworkDataUsingPostMethod(
            urlForEmergencyContactList, mapUserId);

    if (httpClientResponseForEmergencyContactListUrl.statusCode == 200) {
      String reply = await httpClientResponseForEmergencyContactListUrl
          .transform(utf8.decoder)
          .join();
      var response = jsonDecode(reply);
      if (response['msg'] != "success") {
        Toast.show("Server error please try after sometime...", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else {
        print(response);
        bool takeHistory = false;
        var conumerNumber = response['consumer_number'];
        var billingUnitNumber = response['billingunitno'];

        var lastPaymentDate = response['lastPaymentDate'];

        var billamount = response['billamount'];
        var latepaymentamount = response['latepaymentamount'];
        var latepaymnetstartdate = response['latepaymnetstartdate'];
        var bill_date = response['bill_date'];
        var billnumber = response['billnumber'];
        var billPeriod = response['billPeriod'];
        var earlyPaymentDate = response['earlyPaymentDate'];

        if (response['paysu'] == "failed") {
          takeHistory = false;
        } else {
          takeHistory = true;
        }

        bool paybutton = response['paybutton'];

        Widget lastPaymentDateWidget = Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Text(
                    "Last Payment Date",
                    style: textStyleForMaintainanceHeaderTextTitle,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Text(
                    "$lastPaymentDate",
                    style: textStyleForMaintainanceHeaderTextValue,
                  ),
                ),
              ),
            ],
          ),
        );

        Widget payButtonWidget;

        double cardHeightD;
        if (paybutton) {
          totalAmountForPayment = double.parse(billamount);
          cardHeightD = 400.0;
          payButtonWidget = Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Container(
                    height: ScreenUtil.getInstance().setHeight(80),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xFF17ead9), Color(0xFF6078ea)]),
                        borderRadius: BorderRadius.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                              color: Color(0xFF6078ea).withOpacity(.3),
                              offset: Offset(0.0, 8.0),
                              blurRadius: 8.0)
                        ]),
                    child: Material(
                      color: Colors.transparent,
                      child: FlatButton(
                        onPressed: () {
                          setState(() {
                            openCheckout();
                          });
                        },
                        child: Center(
                          child: Text("Pay Electricity Bill",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Poppins-Bold",
                                  fontSize: 15,
                                  letterSpacing: 1.0)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          payButtonWidget = Container();
          cardHeightD = 325.0;
        }

        headingWidget = ReusableCard(
          color: reusableCardColor,
          newheight: cardHeightD,
          cardChild: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: Text(
                            "Consumer Number ",
                            style: textStyleForMaintainanceHeaderTextTitle,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Text(
                            "$conumerNumber",
                            style: textStyleForMaintainanceHeaderTextValue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: Text(
                            "Billing Unit Number ",
                            style: textStyleForMaintainanceHeaderTextTitle,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Text(
                            "$billingUnitNumber",
                            style: textStyleForMaintainanceHeaderTextValue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: Text(
                            "Bill Generate Date ",
                            style: textStyleForMaintainanceHeaderTextTitle,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Text(
                            "$bill_date",
                            style: textStyleForMaintainanceHeaderTextValue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: Text(
                            "Bill Amount ",
                            style: textStyleForMaintainanceHeaderTextTitle,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Text(
                            "Rs. $billamount /-",
                            style: textStyleForMaintainanceHeaderTextValue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: Text(
                            "Last Payment Date ",
                            style: textStyleForMaintainanceHeaderTextTitle,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Text(
                            "$latepaymnetstartdate",
                            style: textStyleForMaintainanceHeaderTextValue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: Text(
                            "Late Payment Amount ",
                            style: textStyleForMaintainanceHeaderTextTitle,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Text(
                            "Rs. $latepaymentamount /-",
                            style: textStyleForMaintainanceHeaderTextValue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: lastPaymentDateWidget,
              ),
              Container(
                child: payButtonWidget,
              )
            ],
          ),
        );

        /*if (paymentHistoryAvailable) {
          societyMaintainanceHistoryDetailsWidget = Container();
        } else {
          societyMaintainanceHistoryDetailsWidget = Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ReusableCard(
                  color: reusableCardColor,
                  cardChild: Center(child: Text("No History Available")),
                ),
              ],
            ),
          );
        }*/
        getUserHistoryDetails();

        setState(() {
          societyMaintainancePageDetailsWidget = Column(
            children: <Widget>[
              headingWidget,
              societyMaintainanceHistoryDetailsWidget,
            ],
          );
        });
      }
    } else {
      Toast.show(
        "Request failed with status: ${httpClientResponseForEmergencyContactListUrl.statusCode}, please try again after some time",
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
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _razoroaySuccessEventHandler);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _razoroayErrorEventHandler);
    _razorpay.on(
        Razorpay.EVENT_EXTERNAL_WALLET, _razoroayExternalWalletEventHandler);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _razorpay.clear();
  }

  //'amount': totalAmountForPayment * 100,
  void openCheckout() async {
    var options = {
      'key': 'rzp_live_iMJU2s4h0nl9gl',
      'amount': 1 * 100,
      'name': 'Society Maintainance Payment',
      'description': 'Your society maintainance payment',
      'prefill': {'contact': userContactNumber, 'email': userEmailIdForRazor},
      'external': {
        'wallet': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e);
    }
  }

  void _razoroaySuccessEventHandler(
      PaymentSuccessResponse paymentSuccessResponse) async {
    var paymentId = paymentSuccessResponse.paymentId;
    var mapSendPaymentSuccessDetails = {
      "paymentId": paymentId,
      "loginUserId": loginUserId,
      "electricityPaymentAmount": totalAmountForPayment,
      "billingMonth": billingMonth,
    };
    var sendPaymentSuccessInfoUrl =
        urlForApi.electricityPaymentSuccessInsertionUrl;

    HttpClientResponse httpClientResponse =
        await getNetworkData.getNetworkDataUsingPostMethod(
            sendPaymentSuccessInfoUrl, mapSendPaymentSuccessDetails);
    if (httpClientResponse.statusCode == 200) {
      String reply = await httpClientResponse.transform(utf8.decoder).join();
      var response = jsonDecode(reply);
      if (response['msg'] == "success") {
        Toast.show("Payment Done Successfully", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        getMaintanancePageDetails();
        getUserHistoryDetails();
      }
    }
  }

  void _razoroayErrorEventHandler(
      PaymentFailureResponse paymentFailureResponse) {
    Toast.show("Error - " + paymentFailureResponse.message, context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void _razoroayExternalWalletEventHandler(
      ExternalWalletResponse externalWalletResponse) {
    Toast.show(
        "External Wallet - " + externalWalletResponse.walletName, context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: societyMaintainancePageDetailsWidget,
    );
  }
}
