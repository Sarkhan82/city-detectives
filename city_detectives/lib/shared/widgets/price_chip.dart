import 'package:flutter/material.dart';

/// Chip Gratuit ou Payant + prix optionnel – design system « carnet de détective » (Story 2.2, 6.1).
/// [priceLabel] : prix formaté pour les enquêtes payantes (ex. "2,99 €") – FR47, FR49.
/// Fallback « Payant » si [isFree] est false ou absent ; labels accessibles WCAG 2.1 Level A.
class PriceChip extends StatelessWidget {
  const PriceChip({super.key, required this.isFree, this.priceLabel});

  final bool isFree;
  final String? priceLabel;

  @override
  Widget build(BuildContext context) {
    final semanticsLabel = isFree
        ? 'Gratuit'
        : (priceLabel != null ? 'Payant $priceLabel' : 'Payant');
    return Semantics(
      label: semanticsLabel,
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
