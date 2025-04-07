import 'package:flutter/material.dart';
import 'package:september_twenty_nine_user/screens/saved.plans.page.dart';
import 'package:september_twenty_nine_user/entities/user.entity.dart';

class ProfilePage extends StatelessWidget {
  final User currentUser;  // Declare a final variable to hold the currentUser
  ProfilePage({required this.currentUser});  // Initialize it via constructor


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.green[300]
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            onTap: () {
              // Handle edit profile logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              // Handle change password logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Settings'),
            onTap: () {
              // Handle notification settings logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            onTap: () {
              // Handle language selection logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_chart), // New icon for the table view
            title: const Text('Saved Plans'), // New title
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedPlansPage(currentUser: currentUser,)), // Navigate to the new screen
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () {
              // Handle log out logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_chart), // New icon for the table view
            title: const Text('All Item Data: Table View'), // New title
            onTap: () {

            },
          ),
        ],
      ),
    );
  }
}