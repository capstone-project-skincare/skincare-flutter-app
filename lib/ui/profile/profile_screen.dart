import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>> _fetchUserData(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    return {
      'scanDetections': (data['scanDetections'] as List<dynamic>? ?? [])
          .map((d) => d['class'] as String)
          .toSet()
          .toList(),
      'recommendedIngredients':
          List<String>.from(data['recommendedIngredients'] ?? []),
    };
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          "Profile",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: user == null
          ? const Center(child: Text("Not logged in"))
          : FutureBuilder<Map<String, dynamic>>(
              future: _fetchUserData(user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final skinIssues =
                    snapshot.data!['scanDetections'] as List<String>;
                final ingredients =
                    snapshot.data!['recommendedIngredients'] as List<String>;

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            child: Text(user.email![0].toUpperCase()),
                          ),
                          const SizedBox(height: 20),
                          Text("Email: ${user.email}",
                              style: const TextStyle(fontSize: 16)),
                          const Divider(height: 40),
                        ],
                      ),
                      // Skin Type Card
                      Card(
                        color: Theme.of(context).colorScheme.secondary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Skin Type",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 10),
                              Chip(
                                label: const Text("Dry"),
                                backgroundColor: Colors.pink.shade50,
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Skin Issues Card
                      Card(
                        color: Theme.of(context).colorScheme.secondary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Skin Issues",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 10),
                              if (skinIssues.isEmpty)
                                Text("No issues detected yet.",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge)
                              else
                                Wrap(
                                  spacing: 8,
                                  children: skinIssues
                                      .map((issue) => Chip(
                                            label: Text(issue),
                                            backgroundColor:
                                                Colors.pink.shade50,
                                            labelStyle: const TextStyle(
                                                color: Colors.black),
                                          ))
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Recommended Ingredients Card
                      Card(
                        color: Theme.of(context).colorScheme.secondary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Recommended Ingredients",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 10),
                              if (ingredients.isEmpty)
                                Text("No recommendations yet.",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge)
                              else
                                Wrap(
                                  spacing: 8,
                                  children: ingredients
                                      .map((ing) => Chip(
                                            label: Text(ing),
                                            backgroundColor:
                                                Colors.pink.shade50,
                                            labelStyle: const TextStyle(
                                                color: Colors.black),
                                          ))
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: () => userProvider.signOut(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          "Logout",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
