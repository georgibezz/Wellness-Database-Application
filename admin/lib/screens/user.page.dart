import 'package:flutter/material.dart';
import '../entities/user.entity.dart';
import '../main.dart'; // import your objectbox.store.dart file


class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int currentPage = 0;
  final int usersPerPage = 10;
  int totalUsers = 0;


  void _deleteUser(int id) {
    objectbox.removeUser(id);
  }

  void _viewUser(User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user.name),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Also Called: ${user.email}'), // Show the category
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
        backgroundColor: Colors.teal.shade700,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  // Trigger rebuild for updated search
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<User>>(
              stream: objectbox.getUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var users = snapshot.data!;
                  //totalItems = items.length;
                  // Case-insensitive search
                  if (_searchController.text.isNotEmpty) {
                    users = users.where((user) =>
                        user.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
                  }
                  // Case-insensitive sort
                  users.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                  // Pagination
                  final totalUsers = users.length;
                  final start = currentPage * usersPerPage;
                  final end = start + usersPerPage > totalUsers ? totalUsers : start + usersPerPage;
                  final currentUsers = users.sublist(start, end);

                  return ListView.builder(
                    itemCount: currentUsers.length,
                    itemBuilder: (context, index) {
                      final user = currentUsers[index];
                      return ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        trailing: Wrap(
                          spacing: 12, // space between two icons
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () => _viewUser(user),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteUser(user.id!),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  if (currentPage > 0) {
                    setState(() {
                      currentPage--;
                    });
                  }
                },
                child: const Text('<'),
              ),
              StreamBuilder<List<User>>(
                stream: objectbox.getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final totalUsers = snapshot.data!.length;
                    return Text('Viewing ${currentPage * usersPerPage + 1} - ${(currentPage + 1) * usersPerPage} of $totalUsers');
                  }
                  return const Text('Loading...');
                },
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    currentPage++;  // Increment the current page
                  });
                },
                child: const Text('>'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}