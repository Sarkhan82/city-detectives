import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/admin/providers/dashboard_provider.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';

/// Détail d'une enquête (admin) – Prévisualiser, Publier, Rollback (Story 7.3 – FR65, FR66, FR67).
class AdminInvestigationDetailScreen extends ConsumerStatefulWidget {
  const AdminInvestigationDetailScreen({
    super.key,
    required this.investigation,
  });

  final Investigation investigation;

  @override
  ConsumerState<AdminInvestigationDetailScreen> createState() =>
      _AdminInvestigationDetailScreenState();
}

class _AdminInvestigationDetailScreenState
    extends ConsumerState<AdminInvestigationDetailScreen> {
  bool _isPublishing = false;
  bool _isRollingBack = false;

  Future<void> _publish() async {
    if (_isPublishing) return;
    setState(() => _isPublishing = true);
    try {
      final repo = ref.read(adminInvestigationRepositoryProvider);
      await repo.publishInvestigation(widget.investigation.id);
      if (!mounted) return;
      ref.invalidate(adminInvestigationListProvider);
      ref.invalidate(adminDashboardProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enquête publiée.')));
      context.go(AppRouter.adminInvestigationListPath());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de publier l\'enquête. Réessayez plus tard.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  Future<void> _rollback() async {
    if (_isRollingBack) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dépublier l\'enquête ?'),
        content: const Text(
          'L\'enquête ne sera plus visible pour les utilisateurs. Vous pourrez la republier plus tard.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Dépublier'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _isRollingBack = true);
    try {
      final repo = ref.read(adminInvestigationRepositoryProvider);
      await repo.rollbackInvestigation(widget.investigation.id);
      if (!mounted) return;
      ref.invalidate(adminInvestigationListProvider);
      ref.invalidate(adminDashboardProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enquête dépubliée.')));
      context.go(AppRouter.adminInvestigationListPath());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de dépublier l\'enquête. Réessayez plus tard.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isRollingBack = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.investigation;
    final status = inv.status ?? 'draft';
    final isDraft = status == 'draft';

    return Scaffold(
      appBar: AppBar(
        title: Text(inv.titre),
        leading: Semantics(
          label: 'Retour à la liste des enquêtes',
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: 'Retour',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(inv.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(
            isDraft ? 'Statut : Brouillon' : 'Statut : Publiée',
            semanticsLabel: isDraft ? 'Statut : Brouillon' : 'Statut : Publiée',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDraft
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Semantics(
            label: 'Ouvrir la prévisualisation de l\'enquête',
            child: FilledButton.icon(
              onPressed: () =>
                  context.push(AppRouter.adminInvestigationPreviewPath(inv.id)),
              icon: const Icon(Icons.visibility),
              label: const Text('Prévisualiser'),
            ),
          ),
          if (isDraft) ...[
            const SizedBox(height: 12),
            Semantics(
              label: 'Publier l\'enquête pour les utilisateurs',
              child: FilledButton.icon(
                onPressed: _isPublishing ? null : _publish,
                icon: _isPublishing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.publish),
                label: Text(_isPublishing ? 'Publication…' : 'Publier'),
              ),
            ),
          ],
          if (!isDraft) ...[
            const SizedBox(height: 12),
            Semantics(
              label: 'Dépublier l\'enquête',
              child: OutlinedButton.icon(
                onPressed: _isRollingBack ? null : _rollback,
                icon: _isRollingBack
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.undo),
                label: Text(_isRollingBack ? 'Rollback…' : 'Rollback'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
