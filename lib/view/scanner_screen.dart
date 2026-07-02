import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/view/widget/bottom_bar.dart';

class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("ScanDesc")),

      bottomNavigationBar: BottomBar.buildBottom(context, ref),
    );
  }
}
