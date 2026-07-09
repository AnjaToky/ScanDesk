import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/view/colors/couleur.dart';

class BottomBar {
  static Widget buildBottom(BuildContext context, WidgetRef ref) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    final items = [
      (route: '/scan-screen', icon: Icons.qr_code_scanner, label: 'Scanner'),
      (route: '/list-tout', icon: Icons.list_alt_rounded, label: 'Liste'),
      (route: '/dash-board', icon: Icons.home_filled, label: 'Accueil'),
      (route: '/personne', icon: Icons.people_rounded, label: 'Personnes'),
      (route: '/emprunt', icon: Icons.wallet, label: 'Emprunt'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: items.map((item) {
              final isActive = currentRoute == item.route;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (currentRoute != item.route) {
                      Navigator.pushNamed(context, item.route);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Couleur.primaire.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: isActive
                              ? Couleur.primaire
                              : const Color(0xFFADB5BD),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isActive
                              ? Couleur.primaire
                              : const Color(0xFFADB5BD),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
