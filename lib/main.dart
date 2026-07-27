import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/firebase_options.dart';
import 'package:scan_desc/service/sync_queue_service.dart';
import 'package:scan_desc/service/sync_service.dart';
import 'package:scan_desc/view/colors/couleur.dart';
import 'package:scan_desc/view/dash_board.dart';
import 'package:scan_desc/view/emprunt/emprunt_page.dart';
import 'package:scan_desc/view/list_inventaire/list_emprunter.dart';
import 'package:scan_desc/view/personne/personne_page.dart';
import 'package:scan_desc/view/list_inventaire/list_dispo.dart';
import 'package:scan_desc/view/list_inventaire/list_maintenance.dart';
import 'package:scan_desc/view/list_inventaire/list_perdu.dart';
import 'package:scan_desc/view/list_inventaire/list_tout.dart';
import 'package:scan_desc/view/scanner_screen.dart';
import 'package:scan_desc/view/splach_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart';

Future<bool> _initializeFirebaseIfSupported() async {
  final supportedPlatform =
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows;

  if (!supportedPlatform) {
    debugPrint('[main] Firebase skipped on Linux desktop.');
    return false;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } catch (e, stackTrace) {
    debugPrint('[main] Firebase initialization skipped: $e');
    debugPrintStack(stackTrace: stackTrace);
    return false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final firebaseReady = await _initializeFirebaseIfSupported();

  if (firebaseReady) {
    await SyncService.instance.syncFromFirestore();
    SyncQueueService.instance.startListening();
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
        colorScheme: ColorScheme.fromSeed(seedColor: Couleur.primaire),
      ),
      home: const SplashScreen(),
      routes: {
        "/list-dispo": (context) => ListDispo(),
        "/list-tout": (context) => ListTout(),
        "/list-maintenance": (context) => ListMaintenance(),
        "/list-perdu": (context) => ListPerdu(),
        "/dash-board": (context) => DashBoard(),
        "/scan-screen": (context) => ScannerScreen(),
        "/emprunt": (context) => EmpruntPage(),
        "/personne": (context) => PersonnePage(),
        "/list-emprunt": (context) => ListEmprunter(),
      },
    );
  }
}
