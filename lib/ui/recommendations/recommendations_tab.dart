import 'package:flutter/material.dart';

class RecommendationsTab extends StatefulWidget {
  const RecommendationsTab({super.key});

  @override
  State<RecommendationsTab> createState() => _RecommendationsTabState();
}

class _RecommendationsTabState extends State<RecommendationsTab> {
  bool _loading = true;
  List<Map<String, String>> _recommendations = [];

  @override
  void initState() {
    super.initState();

    // Simulate API call (later replace with real backend call)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _recommendations = [
          {
            "ingredient": "Salicylic Acid",
            "benefit": "Helps unclog pores and reduce acne",
            "example": "Paula's Choice BHA 2% Exfoliant",
          },
          {
            "ingredient": "Niacinamide",
            "benefit": "Improves skin texture and reduces inflammation",
            "example": "The Ordinary Niacinamide 10% + Zinc 1%",
          },
          {
            "ingredient": "Hyaluronic Acid",
            "benefit": "Boosts hydration and plumps skin",
            "example": "CeraVe Hydrating Serum",
          },
        ];
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          "Recommendations",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loading state
            if (_loading)
              const Center(child: CircularProgressIndicator())

            // Empty state
            else if (_recommendations.isEmpty)
              const Text(
                "No recommendations yet. Run a scan to get started!",
                style: TextStyle(color: Colors.grey),
              )

            // List of recommendations
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _recommendations.length,
                  itemBuilder: (context, index) {
                    final rec = _recommendations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec["ingredient"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              rec["benefit"]!,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Example: ${rec["example"]!}",
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
