import 'package:flutter/material.dart';

/**
 * builder for app's top navbar
 * */
PreferredSize buildNavBar(BuildContext context, String title) {
  return new PreferredSize(
    child: new Container(
      padding: new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: new Padding(
        padding: const EdgeInsets.only(left: 30.0, top: 20.0, bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 10,
            ),
            Text(
              title,
              style: homePageText(14, Colors.white, FontWeight.bold),
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 18, 0),
              child: Image.asset(
                'images/sign+_white.png',
                height: 40,
              ),
            ),
          ],
        ),
      ),
      decoration: new BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xff9AB7D0), Color(0xff004E98), Color(0xff0F122A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          boxShadow: [
            new BoxShadow(
              color: Colors.grey[500],
              blurRadius: 20.0,
              spreadRadius: 1.0,
            )
          ]),
    ),
    preferredSize: new Size(MediaQuery.of(context).size.width, 150.0),
  );
}

/**
  * the style of the front page text
  * */
TextStyle homePageText(double size, Color textColor, FontWeight weight) {
  return TextStyle(
      decoration: TextDecoration.none,
      color: textColor,
      fontWeight: FontWeight.bold,
      fontSize: size);
}
