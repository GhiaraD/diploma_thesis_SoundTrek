import 'package:flutter/material.dart';

import 'colors.dart' as my_colors;

class Themes {
  static ButtonStyle buttonHalfPageStyleLight = ButtonStyle(
    foregroundColor: MaterialStateProperty.all<Color>(my_colors.Colors.white),
    backgroundColor: MaterialStateProperty.all<Color>(my_colors.Colors.primaryLight),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(),
      ),
    ),
    side: MaterialStateProperty.all<BorderSide>(BorderSide.none),
  );

  static ButtonStyle buttonHalfPageStyle = ButtonStyle(
    foregroundColor: MaterialStateProperty.all<Color>(my_colors.Colors.white),
    backgroundColor: MaterialStateProperty.all<Color>(my_colors.Colors.primary),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(),
      ),
    ),
    side: MaterialStateProperty.all<BorderSide>(BorderSide.none),
  );

  static ButtonStyle buttonHalfPageStyleDisabled = ButtonStyle(
    foregroundColor: MaterialStateProperty.all<Color>(my_colors.Colors.greyDark),
    backgroundColor: MaterialStateProperty.all<Color>(my_colors.Colors.greyLight),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(),
      ),
    ),
    side: MaterialStateProperty.all<BorderSide>(BorderSide.none),
  );

  static ButtonStyle buttonHalfPageStyleWhite = ButtonStyle(
    foregroundColor: MaterialStateProperty.all<Color>(my_colors.Colors.black),
    backgroundColor: MaterialStateProperty.all<Color>(my_colors.Colors.white),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(),
      ),
    ),
    side: MaterialStateProperty.all<BorderSide>(BorderSide.none),
  );

  static TextStyle titleStyleEditText = const TextStyle(
    color: my_colors.Colors.black,
    fontSize: 24,
    fontWeight: FontWeight.normal,
  );
}

class CurvedTopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = my_colors.Colors.primaryOverlay
      ..style = PaintingStyle.fill;

    var path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..quadraticBezierTo(size.width, 0, size.width * .8, 0)
      ..lineTo(size.width * .2, 0)
      ..quadraticBezierTo(0, 0, 0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
