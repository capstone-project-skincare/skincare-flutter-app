import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String brand;
  final String image;

  const ProductCard({
    required this.name,
    required this.brand,
    required this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final textTheme = Theme.of(context).textTheme;
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        color: cardColor,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                brand,
                style: textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
