import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/providers/payment_provider.dart';

/// Flux de paiement simulé (Story 6.2 – FR53) : récap → confirmation → succès.
/// Design « carnet de détective » ; labels accessibilité WCAG 2.1 Level A.
class PurchaseSimulationScreen extends ConsumerStatefulWidget {
  const PurchaseSimulationScreen({
    super.key,
    required this.investigation,
    this.onSuccess,
  });

  final Investigation investigation;
  final VoidCallback? onSuccess;

  @override
  ConsumerState<PurchaseSimulationScreen> createState() =>
      _PurchaseSimulationScreenState();
}

class _PurchaseSimulationScreenState
    extends ConsumerState<PurchaseSimulationScreen> {
  int _step = 0; // 0 récap, 1 confirmation, 2 succès
  bool _loading = false;
  String? _error;

  Future<void> _onConfirmPay() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final payment = ref.read(paymentServiceProvider);
      await payment.recordPurchaseIntent(widget.investigation.id);
      if (!mounted) return;
      setState(() {
        _step = 1;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        final msg = _isAuthError(e)
            ? 'Veuillez vous connecter pour acheter.'
            : e.toString().replaceFirst('Exception: ', '');
        setState(() {
          _error = msg;
          _loading = false;
        });
      }
    }
  }

  static bool _isAuthError(Object e) {
    final s = e.toString().toLowerCase();
    return s.contains('authentification') || s.contains('token');
  }

  Future<void> _onSimulatePay() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final payment = ref.read(paymentServiceProvider);
      await payment.simulatePurchase(widget.investigation.id);
      if (!mounted) return;
      ref.invalidate(userPurchasesProvider);
      setState(() {
        _step = 2;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        final msg = _isAuthError(e)
            ? 'Veuillez vous connecter pour acheter.'
            : e.toString().replaceFirst('Exception: ', '');
        setState(() {
          _error = msg;
          _loading = false;
        });
      }
    }
  }

  void _onSuccessClose() {
    widget.onSuccess?.call();
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.investigation;
    final priceText = inv.formattedPrice ?? '';

    return Semantics(
      label: _step == 0
          ? 'Simulation achat – ${inv.titre} – Prix $priceText. Bouton Payer.'
          : _step == 1
          ? 'Confirmation paiement simulé. Bouton Payer.'
          : 'Achat réussi. Bouton fermer.',
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _step == 0
                ? 'Simulation achat'
                : _step == 1
                ? 'Confirmation'
                : 'Achat réussi',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 1,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_step == 0) ...[
                          Text(
                            inv.titre,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (priceText.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Semantics(
                              label: 'Prix $priceText',
                              child: Text(
                                priceText,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          if (_error != null) ...[
                            Text(
                              _error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Semantics(
                            label: 'Payer $priceText',
                            button: true,
                            child: FilledButton.icon(
                              onPressed: _loading ? null : _onConfirmPay,
                              icon: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.payment),
                              label: Text(_loading ? 'Chargement…' : 'Payer'),
                            ),
                          ),
                        ],
                        if (_step == 1) ...[
                          Text(
                            inv.titre,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            priceText,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          if (_error != null) ...[
                            Text(
                              _error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Semantics(
                            label: 'Payer simulé',
                            button: true,
                            child: FilledButton.icon(
                              onPressed: _loading ? null : _onSimulatePay,
                              icon: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.check_circle_outline),
                              label: Text(
                                _loading ? 'Chargement…' : 'Payer (simulé)',
                              ),
                            ),
                          ),
                        ],
                        if (_step == 2) ...[
                          Icon(
                            Icons.check_circle,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Achat réussi',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '« ${inv.titre} » est maintenant accessible.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          Semantics(
                            label: 'Fermer',
                            button: true,
                            child: FilledButton.icon(
                              onPressed: _onSuccessClose,
                              icon: const Icon(Icons.done),
                              label: const Text('Fermer'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
