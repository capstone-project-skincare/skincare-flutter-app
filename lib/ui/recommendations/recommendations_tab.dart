import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skincare_app/services/firestore_service.dart';

class RecommendationsTab extends StatefulWidget {
  const RecommendationsTab({super.key});

  @override
  State<RecommendationsTab> createState() => _RecommendationsTabState();
}

class _RecommendationsTabState extends State<RecommendationsTab> {
  bool _loading = true;
  final FirestoreService _firestoreService = FirestoreService();
  List<String> _recommendedIngredients = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final ingredients =
          await _firestoreService.getRecommendedIngredients(uid);
      setState(() {
        _recommendedIngredients = ingredients;
        _loading = false;
      });
    } else {
      setState(() {
        _recommendedIngredients = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text("Recommendations"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _recommendedIngredients.isEmpty
              ? const Center(
                  child: Text(
                    "No recommendations yet. Run a scan to get started!",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _recommendedIngredients.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _recommendedIngredients[index],
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
