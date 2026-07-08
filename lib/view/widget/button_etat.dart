import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/viewModel/inventaire_notifier.dart';

class ButtonEtat {
  Widget buildButton(BuildContext context, WidgetRef ref) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    Widget buildItem(String route, String label, {VoidCallback? onTap}) {
      final isSelect = currentRoute == route;

      return Expanded(
        child: GestureDetector(
          onTap: () {
            if (currentRoute != route) {
              Navigator.pushNamed(context, route);
            }
            if (onTap != null) onTap;
          },

          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(vertical: 8),
            width: 50,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelect ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          buildItem(
            '/list-tout',
            'Tout',
            onTap: () {
              ref.read(inventaireProvider.notifier).refresh();
            },
          ),

          buildItem(
            '/list-dispo',
            'Dispo',
            onTap: () {
              ref.read(inventaireProvider.notifier).refresh();
            },
          ),

          buildItem(
            '/list-maintenance',
            'Mainteance',
            onTap: () {
              ref.read(inventaireProvider.notifier).refresh();
            },
          ),

          buildItem(
            '/list-perdu',
            'Perdu',
            onTap: () {
              ref.read(inventaireProvider.notifier).refresh();
            },
          ),

          buildItem(
            '/emprunt',
            'Emprunt',
            onTap: () {
              ref.read(inventaireProvider.notifier).refresh();
            },
          ),
        ],
      ),
    );
  }
}
