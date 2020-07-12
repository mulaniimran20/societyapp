import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:societyapp/pages/common_notice_for_all_list.dart';
import 'package:societyapp/pojo_classes/constant.dart';
import 'package:societyapp/pojo_classes/url_for_api.dart';
import 'package:societyapp/widgets/icon_content.dart';
import 'package:societyapp/widgets/reusable_card.dart';

URLForApi urlForApi = URLForApi();

class NoticeBoardScreen extends StatelessWidget {
  NoticeBoardScreen({this.noticeboardimage, this.userId, this.societyId});

  final String noticeboardimage;
  final int userId;
  final int societyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Society App"),
        centerTitle: true,
      ),
      body: MyApp(
          noticeboardimage: urlForApi.baseUrlForImages + noticeboardimage,
          userId: userId,
          societyId: societyId),
    );
  }
}

class MyApp extends StatefulWidget {
  MyApp({this.noticeboardimage, this.userId, this.societyId});

  final String noticeboardimage;
  final int userId;
  final int societyId;

  @override
  _MyAppState createState() => _MyAppState(
      noticeboardimage: noticeboardimage, userId: userId, societyId: societyId);
}

class _MyAppState extends State<MyApp> {
  _MyAppState({this.noticeboardimage, this.userId, this.societyId});

  final String noticeboardimage;
  final int userId;
  final int societyId;

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
                image: noticeboardimage,
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
                          builder: (context) => CommonNoticeForAllScreen()),
                    );
                  });
                },
                cardChild: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: IconContent(
                    textColor: iconTextColor,
                    sizeBoXHeight: 20.0,
                    textContent: "Common Notice For All",
                    icon: AssetImage("assets/furniture.png"),
                    iconSizeHeight: 72.0,
                    iconSizeWidth: 72.0,
                  ),
                ),
              ),
            ), // emergency contacts tab
            ResponsiveGridCol(
              xs: 6,
              md: 6,
              child: ReusableCard(
                onTapGestureFunction: () {
                  setState(() {
                    /*Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StaffDetailsScreen()),
                    );*/
                  });
                },
                color: reusableCardColor,
                cardChild: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: IconContent(
                    textColor: iconTextColor,
                    sizeBoXHeight: 20.0,
                    textContent: "Notice Only For You",
                    icon: AssetImage("assets/furniture.png"),
                    iconSizeHeight: 72.0,
                    iconSizeWidth: 72.0,
                  ),
                ),
              ),
            ), // staff details tab
          ]), // complete grid layout of all options
        ],
      ),
    );
  }
}
