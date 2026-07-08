import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/view/colors/couleur.dart';

class BottomBar {
  static Widget buildBottom(BuildContext context, WidgetRef ref) {
    final currentRoue = ModalRoute.of(context)?.settings.name;

    Widget buildItem(String route, Widget icon, {VoidCallback? onTap}) {
      return Expanded(
        child: GestureDetector(
          onTap: () {
            if (currentRoue != route) {
              Navigator.pushNamed(context, route);
            }

            if (onTap != null) onTap;
          },

          child: Container(child: icon),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(color: Couleur.secondaire),
        child: Row(
          children: [
            buildItem("/scan-screen", Icon(Icons.qr_code_scanner)),
            buildItem("/dash-board", Icon(Icons.home)),
            buildItem("/list-tout", Icon(Icons.list)),
            buildItem("/personne", Icon(Icons.person))
          ],
        ),
      ),
    );
  }
}
