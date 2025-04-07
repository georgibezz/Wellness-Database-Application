import 'package:flutter/material.dart';
import '../entities/category.entity.dart';
import '../entities/item.entity.dart';
import '../main.dart'; // import your objectbox.store.dart file

//TODO: after clicking confirmation, it adds another item instead of just adding the one your confirming
class ItemPage extends StatefulWidget {
  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final _nameController = TextEditingController();
  final _alsoCalledController = TextEditingController();
  final _usesController = TextEditingController();
  final _cautionController = TextEditingController();
  final _consumerInformationController = TextEditingController();
  final _referencesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int currentPage = 0;
  final int itemsPerPage = 10;
  int totalItems = 0;
  Categories? selectedCategory;


  void _deleteItem(int id) {
    objectbox.removeItem(id);
  }
  void _addItem() {
    if (selectedCategory != null) {
      final newItem = Items(
        name: _nameController.text,
        alsoCalled: _alsoCalledController.text,
        uses: _usesController.text,
        caution: _cautionController.text,
        conscientiousConsumerInformation: _consumerInformationController.text,
        references: _referencesController.text,
        // Include other fields as necessary
      );
      newItem.category.target = selectedCategory!;
      objectbox.updateItem(newItem);

      _nameController.clear();
      _alsoCalledController.clear();
      _usesController.clear();
      _cautionController.clear();
      _consumerInformationController.clear();
      _referencesController.clear();
    }
  }

  void _editItem(Items item) {
    _nameController.text = item.name;
    _alsoCalledController.text = item.alsoCalled;
    _usesController.text = item.uses;
    _cautionController.text = item.caution;
    _consumerInformationController.text = item.conscientiousConsumerInformation;
    _referencesController.text = item.references;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Item'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _buildFormFields(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                item.name = _nameController.text;
                item.alsoCalled = _alsoCalledController.text;
                item.uses = _usesController.text;
                item.caution = _cautionController.text;
                item.conscientiousConsumerInformation = _consumerInformationController.text;
                item.references = _referencesController.text;
                item.category.target = selectedCategory!;

                objectbox.updateItem(item);
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

  List<Widget> _buildFormFields() {
    return [
      StreamBuilder<List<Categories>>(
        stream: objectbox.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            // Check if selectedCategory exists in the snapshot.data
            if (!snapshot.data!.contains(selectedCategory)) {
              selectedCategory = snapshot.data![0];
            }
            return DropdownButtonFormField<Categories>(
              //value: selectedCategory,
              items: snapshot.data!.map((Categories category) {
                return DropdownMenuItem<Categories>(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (Categories? newCategory) {
                setState(() {
                  selectedCategory = newCategory;
                });
              },
              decoration: InputDecoration(labelText: 'Select Category'),
            );
          }
          return CircularProgressIndicator();
        },
      ),
      TextField(
        controller: _nameController,
        decoration: InputDecoration(hintText: 'Name'),
      ),
      TextField(
        controller: _alsoCalledController,
        decoration: InputDecoration(hintText: 'Also Called'),
      ),
      TextField(
        controller: _usesController,
        decoration: InputDecoration(hintText: 'Uses'),
      ),
      TextField(
        controller: _cautionController,
        decoration: InputDecoration(hintText: 'Caution'),
      ),
      TextField(
        controller: _consumerInformationController,
        decoration: InputDecoration(hintText: 'Consumer Information'),
      ),
      TextField(
        controller: _referencesController,
        decoration: InputDecoration(hintText: 'References'),
      ),
    ];
  }

  void _viewItem(Items item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item.name),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Also Called: ${item.alsoCalled}'),
                Text('Uses: ${item.uses}'),
                Text('Caution: ${item.caution}'),
                Text('Consumer Information: ${item.conscientiousConsumerInformation}'),
                Text('References: ${item.references}'),
                Text('Category: ${item.category.target?.name ?? 'Unknown'}'), // Show the category
              ],
            ),
          ),
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
        title: Text('Item Page'),
        backgroundColor: Colors.teal.shade700,
      ),

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
    child: StreamBuilder<List<Items>>(
        stream: objectbox.getItems(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var items = snapshot.data!;
            //totalItems = items.length;
            // Case-insensitive search
            if (_searchController.text.isNotEmpty) {
              items = items.where((item) =>
                  item.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
            }
            // Case-insensitive sort
            items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

            // Pagination
            final totalItems = items.length;
            final start = currentPage * itemsPerPage;
            final end = start + itemsPerPage > totalItems ? totalItems : start + itemsPerPage;
            final currentItems = items.sublist(start, end);

            return ListView.builder(
              itemCount: currentItems.length,
              itemBuilder: (context, index) {
                final item = currentItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.alsoCalled),
                  trailing: Wrap(
                    spacing: 12, // space between two icons
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editItem(item),
                      ),
                      IconButton(
                        icon: Icon(Icons.visibility),
                        onPressed: () => _viewItem(item),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteItem(item.id!),
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
                  child: Text('<'),
                ),
                StreamBuilder<List<Items>>(
                  stream: objectbox.getItems(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final totalItems = snapshot.data!.length;
                      return Text('Viewing ${currentPage * itemsPerPage + 1} - ${(currentPage + 1) * itemsPerPage} of $totalItems');
                    }
                    return Text('Loading...');
                  },
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      currentPage++;  // Increment the current page
                    });
                  },
                  child: Text('>'),
                ),
              ],
            ),
          ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Item'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: _buildFormFields(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Confirmation'),
                            content: Text('Are you sure you would like to add this item?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _addItem();
                                  Navigator.of(context).pop(); // Close the confirmation dialog
                                },
                                child: Text('Yes'),
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
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 5.0,
      ),
    );
  }
}