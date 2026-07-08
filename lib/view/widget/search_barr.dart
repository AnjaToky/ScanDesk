import 'package:flutter/material.dart';
import 'package:scan_desc/view/colors/couleur.dart';

class SearchBarr {
  static Widget searchBar(final ValueChanged<String>? onChange) {
    return TextField(
      onChanged: onChange,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Rechercher...',
        hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Color(0xFFADB5BD), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Couleur.primaire, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      style: const TextStyle(color: Couleur.textPrimaire, fontSize: 14),
    );
  }
}
