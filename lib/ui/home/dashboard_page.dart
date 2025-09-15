import 'package:flutter/material.dart';
import 'package:skincare_app/widgets/ingredient_chip.dart';
import 'package:skincare_app/widgets/product_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lightPink = const Color(0xFFF8BBD0); // Light pink
    final veryLightPink = const Color(0xFFFCE4EC); // Very light pink
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'Home',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          children: [
            // Welcome Header
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment
                  .center, //Center Column contents horizontally,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: veryLightPink,
                  child: Icon(Icons.spa, color: Colors.pink, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Welcome to GlowUp!",
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Scan Button
            Card(
              color: veryLightPink,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "Ready for your skin analysis?",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightPink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      icon: const Icon(Icons.camera_alt),
                      label: Text(
                        "Scan Your Face",
                        style: textTheme.titleSmall,
                      ),
                      onPressed: () {
                        DefaultTabController.of(context).animateTo(1);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Daily Skin Tip
            Card(
              color: veryLightPink,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.yellow, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Tip: Always apply sunscreen, even on cloudy days!",
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Trending Ingredients
            Text(
              "Trending Ingredients",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  IngredientChip("Niacinamide"),
                  IngredientChip("Hyaluronic Acid"),
                  IngredientChip("Vitamin C"),
                  IngredientChip("Ceramides"),
                  IngredientChip("Retinol"),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Recommended Products Carousel (Mock)
            Text(
              "Recommended For You",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ProductCard(
                    name: "HydraBoost Gel",
                    brand: "GlowLabs",
                    image: "assets/images/product1.png",
                  ),
                  ProductCard(
                    name: "Vitamin C Serum",
                    brand: "SkinScience",
                    image: "assets/images/product2.png",
                  ),
                  ProductCard(
                    name: "Ceramide Cream",
                    brand: "PureSkin",
                    image: "assets/images/product3.png",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
