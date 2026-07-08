import 'package:flutter/material.dart';
import 'package:scan_desc/view/colors/couleur.dart';

class AppNavBar {
  static PreferredSizeWidget appBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        "ScanDesc",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Couleur.secondaire,
        ),
      ),
      backgroundColor: Couleur.primaire,
    );
  }
}
