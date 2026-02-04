import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/features/admin/providers/dashboard_provider.dart';
import 'package:city_detectives/features/investigation/models/enigma.dart';

/// Écran création / édition d’une énigme (admin) – Story 7.2 (FR63, FR64).
/// Affiche l’état de validation historique et permet de le modifier.
class EnigmaEditScreen extends ConsumerStatefulWidget {
  const EnigmaEditScreen({
    super.key,
    required this.investigationId,
    this.enigma,
  });

  final String investigationId;
  final Enigma? enigma;

  @override
  ConsumerState<EnigmaEditScreen> createState() => _EnigmaEditScreenState();
}

class _EnigmaEditScreenState extends ConsumerState<EnigmaEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _orderController;
  late final TextEditingController _typeController;
  late final TextEditingController _consigneController;
  late final TextEditingController _historicalExplanationController;
  late final TextEditingController _educationalContentController;
  bool _historicalValidated = false;
  bool _isSaving = false;

  Enigma? get _existing => widget.enigma;

  @override
  void initState() {
    super.initState();
    final e = _existing;
    _titleController = TextEditingController(text: e?.titre ?? '');
    _orderController = TextEditingController(
      text: e != null ? e.orderIndex.toString() : '1',
    );
    _typeController = TextEditingController(text: e?.type ?? 'words');
    _consigneController = TextEditingController(text: e?.consigne ?? '');
    _historicalExplanationController = TextEditingController(
      text: e?.historicalExplanation ?? '',
    );
    _educationalContentController = TextEditingController(
      text: e?.educationalContent ?? '',
    );
    _historicalValidated = e?.historicalContentValidated ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose();
    _typeController.dispose();
    _consigneController.dispose();
    _historicalExplanationController.dispose();
    _educationalContentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final titre = _titleController.text.trim();
    final order = int.tryParse(_orderController.text.trim());
    final type = _typeController.text.trim();
    final consigne = _consigneController.text.trim();
    final historicalExplanation = _historicalExplanationController.text.trim();
    final educationalContent = _educationalContentController.text.trim();

    if (titre.isEmpty || order == null || order <= 0 || type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Titre, ordre (>=1) et type sont requis.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(adminEnigmaRepositoryProvider);
      if (_existing == null) {
        await repo.createEnigma(
          investigationId: widget.investigationId,
          orderIndex: order,
          type: type,
          titre: titre,
          consigne: consigne.isEmpty ? null : consigne,
          historicalExplanation: historicalExplanation.isEmpty
              ? null
              : historicalExplanation,
          educationalContent: educationalContent.isEmpty
              ? null
              : educationalContent,
          historicalContentValidated: _historicalValidated,
        );
      } else {
        await repo.updateEnigma(
          _existing!.id,
          orderIndex: order,
          type: type,
          titre: titre,
          consigne: consigne.isEmpty ? null : consigne,
          historicalExplanation: historicalExplanation.isEmpty
              ? null
              : historicalExplanation,
          educationalContent: educationalContent.isEmpty
              ? null
              : educationalContent,
          historicalContentValidated: _historicalValidated,
        );
      }

      if (!mounted) return;
      // Rafraîchir la liste d’énigmes et le dashboard admin.
      ref.invalidate(
        adminInvestigationWithEnigmasProvider(widget.investigationId),
      );
      ref.invalidate(adminDashboardProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _existing == null ? 'Énigme créée.' : 'Énigme mise à jour.',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d’enregistrer l’énigme. ${e.toString()}'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = _existing;
    final isEdit = e != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Éditer l’énigme' : 'Créer une énigme'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations de base',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre de l’énigme',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _orderController,
                decoration: const InputDecoration(
                  labelText: 'Ordre dans l’enquête (orderIndex)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Type (words, geolocation, photo, puzzle, …)',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _consigneController,
                decoration: const InputDecoration(
                  labelText: 'Consigne / question (optionnel)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _historicalExplanationController,
                decoration: const InputDecoration(
                  labelText: 'Explication historique (optionnel)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _educationalContentController,
                decoration: const InputDecoration(
                  labelText: 'Contenu éducatif (optionnel)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Contenu historique validé'),
                subtitle: const Text(
                  'Indique si le contenu historique a été relu et validé.',
                ),
                value: _historicalValidated,
                onChanged: (value) async {
                  final newValue = value ?? false;
                  if (_existing != null && newValue && !_historicalValidated) {
                    // Utilise explicitement la mutation validateEnigmaHistoricalContent.
                    try {
                      final repo = ref.read(adminEnigmaRepositoryProvider);
                      await repo.validateHistoricalContent(_existing!.id);
                      if (!mounted) return;
                      setState(() {
                        _historicalValidated = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Contenu historique marqué comme validé.',
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Impossible de valider le contenu historique. ${e.toString()}',
                          ),
                        ),
                      );
                    }
                  } else {
                    setState(() {
                      _historicalValidated = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              Semantics(
                label: 'Enregistrer l’énigme',
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Enregistrement…' : 'Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
