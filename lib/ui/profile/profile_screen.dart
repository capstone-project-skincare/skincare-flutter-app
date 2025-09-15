import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center horizontally
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Text(user.email![0].toUpperCase()),
                    ),
                    const SizedBox(height: 20),
                    Text("Email: ${user.email}",
                        style: const TextStyle(fontSize: 16)),
                    Text("UID: ${user.uid}",
                        style: const TextStyle(fontSize: 16)),
                    const Divider(height: 40),
                    const Text("Skin Type: TBD",
                        style: TextStyle(fontSize: 16)),
                    const Text("Conditions: TBD",
                        style: TextStyle(fontSize: 16)),
                    const Text("Recommendations: TBD",
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => userProvider.signOut(),
                      child: Text(
                        "Logout",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
