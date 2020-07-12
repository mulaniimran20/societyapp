import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {
  ReusableCard(
      {@required this.color,
      @required this.cardChild,
      this.onTapGestureFunction,
      this.newheight});

  final Color color;
  final Widget cardChild;
  final Function onTapGestureFunction;
  final double newheight;

  @override
  Widget build(BuildContext context) {
    var cardHeight = 110.0;

    if (newheight != null) {
      cardHeight = newheight;
    } else {
      cardHeight = cardHeight;
    }

    return GestureDetector(
      onTap: onTapGestureFunction,
      child: Container(
        height: cardHeight,
        alignment: Alignment(0, 0),
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: cardChild,
      ),
    );
  }
}
