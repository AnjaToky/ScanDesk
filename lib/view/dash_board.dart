import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/model/inventaire_model.dart';
import 'package:scan_desc/view/list_inventaire.dart';
import 'package:scan_desc/view/widget/bottom_bar.dart';
import 'package:scan_desc/viewModel/inventaire_notifier.dart';

String _formatDate(DateTime date) {
  const months = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

const _blue = Color(0xFF2D62ED);
const _green = Color(0xFF4CAF50);
const _orange = Color(0xFFFFA726);
const _red = Color(0xFFEF5350);

class DashBoard extends ConsumerWidget {
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncInventaire = ref.watch(inventaireProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: _blue,
        title: const Text(
          'ScanDesk',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 0,
      ),
      body: asyncInventaire.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (items) => _buildBody(items),
      ),
      bottomNavigationBar: BottomBar.buildBottom(context, ref),
    );
  }

  Widget _buildBody(List<Inventaire> items) {
    final total = items.length;
    final dispo = items
        .where((i) => i.etatInventaire == EtatInventaire.dispo)
        .length;
    final entretien = items
        .where((i) => i.etatInventaire == EtatInventaire.maintenance)
        .length;
    final perdu = items
        .where((i) => i.etatInventaire == EtatInventaire.perdu)
        .length;
    final dernierScan = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScanCard(date: dernierScan),
          const SizedBox(height: 20),
          const Text(
            'Votre matériels',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _StatCard(label: 'Total matériel', value: total, color: _blue),
              _StatCard(label: 'Disponible', value: dispo, color: _green),
              _StatCard(label: 'Maintenance', value: entretien, color: _orange),
              _StatCard(label: 'Perdue', value: perdu, color: _red),
            ],
          ),
          const SizedBox(height: 20),
          _ActivityCard(items: items),
        ],
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  final DateTime date;
  const _ScanCard({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dernier scan',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(date),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/list-dispo");
            },
            child: Text("List dispo"),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final List<Inventaire> items;
  const _ActivityCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final recent = items.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dernier activiter',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            const Text(
              'Aucune activité',
              style: TextStyle(color: Colors.black54),
            )
          else
            ...recent.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: _blue,
      unselectedItemColor: Colors.black54,
      onTap: (index) {
        if (index == 2 && currentIndex != 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ListInventaire()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
      ],
    );
  }
}
