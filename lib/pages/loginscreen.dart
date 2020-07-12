import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:societyapp/widgets/form_card.dart';
import 'package:societyapp/pojo_classes/url_for_api.dart';
import 'dart:convert';
import 'package:societyapp/pojo_classes/get_network_data.dart';
import 'package:toast/toast.dart';
import 'package:societyapp/pages/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

URLForApi urlForApi = URLForApi();
GetNetworkData getNetworkData = new GetNetworkData();

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bool visited = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: ScreenUtil.getInstance().setWidth(120),
          height: 1.0,
          color: Colors.black26.withOpacity(.2),
        ),
      );

  Future<bool> getLoginSuccessSharedPreference() async {
    final SharedPreferences prefs = await _prefs;
    visited = prefs.getBool("loginSuccess") ?? false;
    if (visited) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {}
  }

  Future<void> _setLoginSuccessSharedPrefrences(
      String mobileno,
      String password,
      int society_table_id,
      int loginUserid,
      String society_notice_board_banner) async {
    final SharedPreferences prefs = await _prefs;
    visited = true;

    setState(() {
      prefs.setBool("loginSuccess", visited).then((bool success) {
        return visited;
      });

      prefs
          .setString("society_notice_board_banner", society_notice_board_banner)
          .then((bool success) {
        return society_notice_board_banner;
      });

      prefs.setString("loginMobileNumber", mobileno).then((bool success) {
        return mobileno;
      });

      prefs.setString("userPassword", password).then((bool success) {
        return password;
      });

      prefs.setInt("userSocietyId", society_table_id).then((bool success) {
        return society_table_id;
      });

      prefs.setInt("userLoginId", loginUserid).then((bool success) {
        return loginUserid;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoginSuccessSharedPreference();
  }

  void loginAttempt() async {
    var mobileNumber = FormCard.mobileNumber;
    var userPassword = FormCard.userPassword;
    var loginUrl = urlForApi.loginUrl;

    Map map = {
      "user_mobile_number": mobileNumber,
      "user_password": userPassword
    };

    HttpClientResponse httpClientResponse =
        await getNetworkData.getNetworkDataUsingPostMethod(loginUrl, map);
    if (httpClientResponse.statusCode == 200) {
      String reply = await httpClientResponse.transform(utf8.decoder).join();
      var response = jsonDecode(reply);
      if (response['errmsg'] != "") {
        Toast.show(response['errmsg'], context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else {
        _setLoginSuccessSharedPrefrences(
            mobileNumber,
            userPassword,
            int.parse(response['society_table_id']),
            int.parse(response['loginUserId']),
            response['society_notice_board_banner']);
      }
    } else {
      Toast.show(
          "Request failed with status: ${httpClientResponse.statusCode}, please try again after some time",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ScreenUtil.instance =
        ScreenUtil(width: 750, height: 1334, allowFontScaling: true);
    return new Scaffold(
      resizeToAvoidBottomPadding: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: SizedBox(
                  height: ScreenUtil.getInstance().setHeight(250),
                ),
              ),
              Expanded(child: Container()),
              Expanded(child: Image.asset("assets/image_02.png"))
            ],
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 28.0, right: 28.0, top: 20.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        "assets/LaunchImage.png",
                        height: ScreenUtil.getInstance().setHeight(250),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(60),
                  ),
                  FormCard(),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(60),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 12.0,
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                        ],
                      ),
                      FlatButton(
                        child: Container(
                          width: ScreenUtil.getInstance().setWidth(230),
                          height: ScreenUtil.getInstance().setHeight(80),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xFF17ead9),
                                Color(0xFF6078ea)
                              ]),
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
                                  loginAttempt();
                                });
                              },
                              child: Center(
                                child: Text("SIGNIN",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins-Bold",
                                        fontSize: 15,
                                        letterSpacing: 1.0)),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(60),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "New User? ",
                        style: TextStyle(
                            fontFamily: "Poppins-Medium", fontSize: 15.0),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Text("SignUp",
                            style: TextStyle(
                                color: Color(0xff17ead9),
                                fontFamily: "Poppins-Bold",
                                fontSize: 18.0)),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
