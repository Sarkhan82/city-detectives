import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/admin/providers/dashboard_provider.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/models/investigation_with_enigmas.dart';
import 'package:city_detectives/features/investigation/models/enigma.dart';

/// Écran création / édition d’une enquête (admin) – Story 7.2 (FR62, FR63, FR64).
/// - Création : investigation null
/// - Édition : investigation fournie + liste d’énigmes avec accès édition.
class InvestigationEditScreen extends ConsumerStatefulWidget {
  const InvestigationEditScreen({super.key, this.investigation});

  final Investigation? investigation;

  @override
  ConsumerState<InvestigationEditScreen> createState() =>
      _InvestigationEditScreenState();
}

class _InvestigationEditScreenState
    extends ConsumerState<InvestigationEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;
  late final TextEditingController _difficultyController;
  late final TextEditingController _priceAmountController;
  late final TextEditingController _priceCurrencyController;
  bool _isFree = true;
  bool _isSaving = false;

  Investigation? get _existing => widget.investigation;

  @override
  void initState() {
    super.initState();
    final inv = _existing;
    _titleController = TextEditingController(text: inv?.titre ?? '');
    _descriptionController = TextEditingController(
      text: inv?.description ?? '',
    );
    _durationController = TextEditingController(
      text: inv != null ? inv.durationEstimate.toString() : '60',
    );
    _difficultyController = TextEditingController(
      text: inv?.difficulte ?? 'facile',
    );
    _isFree = inv?.isFree ?? true;
    _priceAmountController = TextEditingController(
      text: inv?.priceAmount?.toString() ?? '',
    );
    _priceCurrencyController = TextEditingController(
      text: inv?.priceCurrency ?? 'EUR',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _difficultyController.dispose();
    _priceAmountController.dispose();
    _priceCurrencyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final titre = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final difficulte = _difficultyController.text.trim();
    final duration = int.tryParse(_durationController.text.trim());

    if (titre.isEmpty || description.isEmpty || difficulte.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Titre, description et difficulté sont requis.'),
        ),
      );
      return;
    }
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La durée doit être un entier positif.')),
      );
      return;
    }

    int? priceAmount;
    String? priceCurrency;
    if (!_isFree) {
      final rawPrice = _priceAmountController.text.trim();
      if (rawPrice.isNotEmpty) {
        priceAmount = int.tryParse(rawPrice);
      }
      priceCurrency = _priceCurrencyController.text.trim().isEmpty
          ? null
          : _priceCurrencyController.text.trim();
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(adminInvestigationRepositoryProvider);
      if (_existing == null) {
        await repo.createInvestigation(
          titre: titre,
          description: description,
          durationEstimate: duration,
          difficulte: difficulte,
          isFree: _isFree,
          priceAmount: priceAmount,
          priceCurrency: priceCurrency,
        );
      } else {
        await repo.updateInvestigation(
          _existing!.id,
          titre: titre,
          description: description,
          durationEstimate: duration,
          difficulte: difficulte,
          isFree: _isFree,
          priceAmount: priceAmount,
          priceCurrency: priceCurrency,
        );
      }

      if (!mounted) return;
      // Rafraîchir dashboard + liste des enquêtes.
      ref.invalidate(adminDashboardProvider);
      ref.invalidate(adminInvestigationListProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _existing == null ? 'Enquête créée.' : 'Enquête mise à jour.',
          ),
        ),
      );
      context.go(AppRouter.adminInvestigationListPath());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d’enregistrer l’enquête. ${e.toString()}'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = _existing;
    final isEdit = inv != null;

    AsyncValue<InvestigationWithEnigmas?> enigmasAsync = const AsyncValue.data(
      null,
    );
    if (isEdit) {
      enigmasAsync = ref.watch(adminInvestigationWithEnigmasProvider(inv.id));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Éditer l’enquête' : 'Créer une enquête'),
        leading: Semantics(
          label: 'Retour à la liste des enquêtes',
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: 'Retour',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations générales',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre de l’enquête',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Durée estimée (minutes)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _difficultyController,
                decoration: const InputDecoration(
                  labelText: 'Difficulté (facile / moyen / difficile)',
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Enquête gratuite'),
                value: _isFree,
                onChanged: (value) {
                  setState(() {
                    _isFree = value;
                  });
                },
              ),
              if (!_isFree) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _priceAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Prix (centimes, ex. 299)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _priceCurrencyController,
                  decoration: const InputDecoration(
                    labelText: 'Devise (ex. EUR)',
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Semantics(
                label: 'Enregistrer l’enquête',
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
              if (isEdit) ...[
                const SizedBox(height: 32),
                Text(
                  'Énigmes de cette enquête',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                enigmasAsync.when(
                  data: (data) {
                    final enigmas = data?.enigmas ?? const <Enigma>[];
                    if (enigmas.isEmpty) {
                      return const Text('Aucune énigme pour le moment.');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: enigmas.length,
                      itemBuilder: (context, index) {
                        final e = enigmas[index];
                        final validated = e.historicalContentValidated == true;
                        return Card(
                          child: ListTile(
                            title: Text(e.titre),
                            subtitle: Text(
                              'Type : ${e.type} • Contenu historique validé : ${validated ? 'Oui' : 'Non'}',
                            ),
                            trailing: const Icon(Icons.edit),
                            onTap: () {
                              context.push(
                                AppRouter.adminEnigmaEditPath(inv.id, e.id),
                                extra: e,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) =>
                      Text('Impossible de charger les énigmes : $error'),
                ),
                const SizedBox(height: 12),
                Semantics(
                  label: 'Ajouter une énigme à cette enquête',
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push(
                        AppRouter.adminEnigmaEditPath(inv.id, 'new'),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une énigme'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
