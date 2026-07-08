import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/view/dash_board.dart';
import 'package:scan_desc/view/list_inventaire/list_dispo.dart';
import 'package:scan_desc/view/list_inventaire/list_maintenance.dart';
import 'package:scan_desc/view/list_inventaire/list_perdu.dart';
import 'package:scan_desc/view/list_inventaire/list_tout.dart';
import 'package:scan_desc/view/scanner_screen.dart';
import 'package:scan_desc/view/splach_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
                                                                                                                                                              
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanDesk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D62ED)),
      ),
      home: const SplashScreen(),
      routes: {
        "/list-dispo": (context) => ListDispo(),
        "/list-tout": (context) => ListTout(),
        "/list-maintenance": (context) => ListMaintenance(),
        "/list-perdu": (context) => ListPerdu(),
        "/dash-board": (context) => DashBoard(),
        "/scan-screen": (context) => ScannerScreen(),
      },
    );
  }
}
