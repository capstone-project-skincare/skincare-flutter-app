import 'package:flutter/material.dart';

class IngredientChip extends StatelessWidget {
  final String label;
  const IngredientChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final chipTheme = Theme.of(context).chipTheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Chip(
        label: Text(
          label,
          style: chipTheme.labelStyle ??
              textTheme.bodyMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
        ),
        backgroundColor: chipTheme.backgroundColor ?? const Color(0xFFF8BBD0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
