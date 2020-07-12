import 'package:flutter/material.dart';

class IconContent extends StatelessWidget {
  IconContent(
      {@required this.icon,
      this.iconSizeWidth,
      this.iconSizeHeight,
      @required this.sizeBoXHeight,
      @required this.textContent,
      @required this.textColor});

  final ImageProvider icon;
  final double iconSizeWidth;
  final double iconSizeHeight;
  final double sizeBoXHeight;
  final String textContent;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image(
          image: icon,
          width: iconSizeWidth,
          height: iconSizeHeight,
        ),
        Text(
          textContent,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0XFFFFFFFF),
            fontSize: 10.0,
            fontFamily: 'Poppins-Bold',
          ),
        ),
      ],
    );
  }
}
