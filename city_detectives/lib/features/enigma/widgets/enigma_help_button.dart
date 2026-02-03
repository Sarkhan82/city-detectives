import 'package:flutter/material.dart';

import 'package:city_detectives/features/enigma/widgets/enigma_hints_panel.dart';

/// Bouton « Aide » pour afficher les indices progressifs (Story 4.3 – FR30).
/// Ouvre un modal avec le panneau d'indices (suggestion → indice → solution).
class EnigmaHelpButton extends StatelessWidget {
  const EnigmaHelpButton({super.key, required this.enigmaId});

  final String enigmaId;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Aide – afficher les indices pour cette énigme',
      button: true,
      child: IconButton(
        icon: const Icon(Icons.help_outline),
        onPressed: () => _showHintsPanel(context),
        tooltip: 'Aide',
      ),
    );
  }

  void _showHintsPanel(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: EnigmaHintsPanel(
            enigmaId: enigmaId,
            onClose: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
    );
  }
}
