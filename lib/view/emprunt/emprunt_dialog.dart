import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_desc/model/emprunter_model.dart';
import 'package:scan_desc/model/inventaire_model.dart';
import 'package:scan_desc/model/personne_model.dart';
import 'package:scan_desc/viewModel/emprunt_notifier.dart';
import 'package:scan_desc/viewModel/personne_notifier.dart';

class EmpruntDialog extends ConsumerStatefulWidget {
  final Inventaire inventaire;

  const EmpruntDialog({super.key, required this.inventaire});

  @override
  ConsumerState<EmpruntDialog> createState() => _EmpruntDialogState();
}

class _EmpruntDialogState extends ConsumerState<EmpruntDialog> {
  Personne? _personneSelectionnee;
  DateTime _dateEmprunt = DateTime.now();
  DateTime? _dateRemise;

  Future<void> _pickDate(bool isEmprunt) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isEmprunt ? _dateEmprunt : (_dateRemise ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isEmprunt) {
          _dateEmprunt = picked;
        } else {
          _dateRemise = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non définie';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final personnesAsync = ref.watch(personneProvider);

    return AlertDialog(
      title: Text('Emprunter — ${widget.inventaire.name}'),
      content: personnesAsync.when(
        loading: () => const SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Text('Erreur: $e'),
        data: (personnes) {
          if (personnes.isEmpty) {
            return const Text(
              'Aucune personne enregistrée.\nAjoutez des personnes d\'abord.',
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Personne>(
                decoration: const InputDecoration(labelText: 'Personne'),
                initialValue: _personneSelectionnee,
                items: personnes
                    .map(
                      (p) => DropdownMenuItem(value: p, child: Text(p.name)),
                    )
                    .toList(),
                onChanged: (p) => setState(() => _personneSelectionnee = p),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date emprunt'),
                subtitle: Text(_formatDate(_dateEmprunt)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date retour prévue'),
                subtitle: Text(_formatDate(_dateRemise)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(false),
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _personneSelectionnee == null
              ? null
              : () {
                  ref.read(empruntProvider.notifier).ajouterEmprunt(
                    Emprunter(
                      idInventaire: widget.inventaire.id!,
                      idPersonne: _personneSelectionnee!.id,
                      dateEmprunt: _dateEmprunt,
                      dateRemise: _dateRemise,
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${widget.inventaire.name} emprunté par ${_personneSelectionnee!.name}',
                      ),
                    ),
                  );
                },
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}

void showEmpruntDialog(BuildContext context, Inventaire inventaire) {
  showDialog(
    context: context,
    builder: (_) => EmpruntDialog(inventaire: inventaire),
  );
}
