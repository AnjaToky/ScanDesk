import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/view/colors/couleur.dart';

class ButtonEtat {
  Widget buildButton(BuildContext context, WidgetRef ref) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    final tabs = [
      (route: '/list-tout',         label: 'Tout',        icon: Icons.apps_rounded),
      (route: '/list-dispo',        label: 'Dispo',       icon: Icons.check_circle_outline),
      (route: '/list-maintenance',  label: 'Maintenance', icon: Icons.build_outlined),
      (route: '/list-perdu',        label: 'Perdu',       icon: Icons.warning_amber_outlined),
      (route: '/emprunt',           label: 'Emprunts',    icon: Icons.person_outline),
    ];

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        children: tabs.map((tab) {
          final isActive = currentRoute == tab.route;
          return GestureDetector(
            onTap: () {
              if (currentRoute != tab.route) {
                Navigator.pushNamed(context, tab.route);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? Couleur.primaire : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? Couleur.primaire : const Color(0xFFE2E8F0),
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Couleur.primaire.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab.icon,
                    size: 14,
                    color: isActive ? Colors.white : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
