import 'package:flutter/material.dart';

class ResponsiveWidth {
  static double getResponsiveWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1320) {
      return screenWidth * 0.55;
    } else if (screenWidth > 960) {
      return screenWidth * 0.7;
    } else {
      return screenWidth * 0.95;
    }
  }
}

class ResponsiveWidth_B {
  static double getResponsiveWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1320) {
      return screenWidth * 0.2;
    } else if (screenWidth > 960) {
      return screenWidth * 0.4;
    } else {
      return screenWidth * 0.9;
    }
  }
}

mixin ResponsiveWidth_Info {
  static double getResponsiveWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1320) {
      return screenWidth * 0.1;
    } else if (screenWidth > 960) {
      return screenWidth * 0.5;
    } else {
      return screenWidth * 0.5;
    }
  }
}