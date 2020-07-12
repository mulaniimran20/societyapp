import 'package:flutter/material.dart';
import 'package:societyapp/pojo_classes/constant.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class ContactDetailsCard extends StatelessWidget {
  ContactDetailsCard({
    @required this.color,
    this.onTapGestureForCard,
    @required this.imageUrl,
    @required this.cardUserName,
    @required this.cardUserPost,
    @required this.cardUserEmailId,
    @required this.cardUserContactNumber,
    @required this.cardWithImage,
  });

  final Color color;
  final String imageUrl;
  final Function onTapGestureForCard;
  final String cardUserName;
  final String cardUserPost;
  final String cardUserEmailId;
  final String cardUserContactNumber;
  final bool cardWithImage;

  @override
  Widget build(BuildContext context) {
    Widget cardChild;

    onTapGestureForCallIcon() async {
      var number = "0$cardUserContactNumber"; //set the number here
      bool res = await FlutterPhoneDirectCaller.callNumber(number);
    }

    Widget cardChildWithImage =
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
      Expanded(
        flex: 1,
        child: FadeInImage.assetNetwork(
          placeholder: "assets/loading1.gif",
          image: imageUrl,
          height: contactCardHeight,
          width: contactCardHeight,
        ),
      ),
      Expanded(
        flex: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              cardUserName,
              style: TextStyle(
                fontSize: 14.0,
                fontFamily: "Poppins-Bold",
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              cardUserPost,
              style: TextStyle(
                fontSize: 10.0,
                fontFamily: "Poppins-Bold",
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              cardUserEmailId,
              style: TextStyle(
                fontSize: 8.0,
                fontFamily: "Poppins-Bold",
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
          ],
        ),
      ),
      Expanded(
        flex: 1,
        child: GestureDetector(
          onTap: onTapGestureForCallIcon,
          child: Container(
            child: Icon(
              Icons.call,
              size: 48.0,
            ),
          ),
        ),
      ),
    ]);

    return GestureDetector(
      onTap: onTapGestureForCard,
      child: Container(
        height: contactCardHeight,
        alignment: Alignment(0, 0),
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: cardChildWithImage,
      ),
    );
  }
}
