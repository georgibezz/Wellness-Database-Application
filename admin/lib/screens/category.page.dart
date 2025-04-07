import 'package:flutter/material.dart';
import '../entities/category.entity.dart'; // Import your category.entity.dart file
import '../main.dart'; // Import your objectbox.store.dart file


//TODO: after adding cetegory, it doesn't add name and you have to edit it and update it again in order dfor name to be added
class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  void _addCategory() async {
    await objectbox.addCategory(_nameController.text);
    _nameController.clear();
  }

  void _editCategory(Categories category) {
    _nameController.text = category.name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: 'Name'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                category.name = _nameController.text;
                objectbox.updateCategory(
                    category); // Implement this in your objectbox file

                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _viewCategory(Categories category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(category.name),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
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
          title: Text('Category Page'),
        backgroundColor: Colors.teal.shade700, ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
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
            child: StreamBuilder<List<Categories>>(
              stream: objectbox.getCategories(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final category = snapshot.data![index];
                      return ListTile(
                        title: Text(category.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editCategory(category),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () =>
                                  objectbox.removeCategory(category.id),
                            ),
                            IconButton(
                              icon: Icon(Icons.visibility),
                              onPressed: () => _viewCategory(category),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Category'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(hintText: 'Name'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _addCategory();
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange, // Set the background color
        foregroundColor: Colors.white, // Set the foreground color (icon color)
        elevation: 5.0,
      ),
    );
  }
}