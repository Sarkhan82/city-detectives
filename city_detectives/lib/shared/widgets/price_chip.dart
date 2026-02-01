import 'package:flutter/material.dart';

/// Chip Gratuit ou Payant – design system « carnet de détective » (Story 2.2).
/// Fallback « Payant » si [isFree] est false ou absent.
class PriceChip extends StatelessWidget {
  const PriceChip({super.key, required this.isFree});

  final bool isFree;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isFree ? 'Gratuit' : 'Payant',
      child: Chip(
        label: Text(isFree ? 'Gratuit' : 'Payant'),
        backgroundColor: isFree
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
