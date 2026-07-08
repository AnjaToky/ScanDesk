import 'package:flutter/material.dart';
import 'package:scan_desc/view/colors/couleur.dart';

class SearchBarr {
  static Widget searchBar(final ValueChanged<String>? onChange) {
    return TextField(
      onChanged: onChange,

      decoration: InputDecoration(
        filled: true,
        fillColor: Couleur.input,
        hintText: 'Recherche',
        hintStyle: TextStyle(color: Couleur.textPrimaire, fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.zero,
      ),
      style: TextStyle(color: Couleur.textPrimaire, fontSize: 16),
    );
  }
}
