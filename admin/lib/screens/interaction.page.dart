import 'package:flutter/material.dart';
import '../entities/item.entity.dart';
import '../entities/interaction.entity.dart';
import '../main.dart';

class InteractionsPage extends StatefulWidget {
  @override
  _InteractionsPageState createState() => _InteractionsPageState();
}

class _InteractionsPageState extends State<InteractionsPage> {
  final _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  Items? selectedItem1;
  Items? selectedItem2;
  int currentPage = 0;
  final int interactionsPerPage = 10;
  int totalInteractions = 0;



  void _addInteraction() {
    if (selectedItem1 != null && selectedItem2 != null) {
      final newInteraction = Interactions(
        description: _descriptionController.text,
      );

      newInteraction.items.add(selectedItem1!);
      newInteraction.items.add(selectedItem2!);
      objectbox.updateInteraction(newInteraction);

      _descriptionController.clear();

    }
  }
  void _deleteInteraction(int id) {
    objectbox.removeInteraction(id);
  }

  void _viewInteraction(Interactions interaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Item 1: ${interaction.items[0].name}, Item 2: ${interaction.items[1].name}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Description: ${interaction.description}'),

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




  List<Widget> _buildFormFields() {
    return [
      StreamBuilder<List<Items>>(
        stream: objectbox.getItems(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(
              children: [
                DropdownButtonFormField<Items>(
                  value: selectedItem1,
                  items: snapshot.data!.map((Items item) {if (!snapshot.data!.contains(selectedItem1)) {
                    selectedItem1 = snapshot.data![0];
                  }
                    return DropdownMenuItem<Items>(
                      value: item,
                      child: Text(item.name),
                    );
                  }).toList(),
                  onChanged: (Items? newItem) {
                    setState(() {
                      selectedItem1 = newItem;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Select First Item'),
                ),
                DropdownButtonFormField<Items>(
                  value: selectedItem2,
                  items: snapshot.data!.map((Items item) {if (!snapshot.data!.contains(selectedItem2)) {
                    selectedItem2 = snapshot.data![0];
                  }
                    return DropdownMenuItem<Items>(
                      value: item,
                      child: Text(item.name),
                    );
                  }).toList(),
                  onChanged: (Items? newItem) {
                    setState(() {
                      selectedItem2 = newItem;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Select Second Item'),
                ),
              ],
            );
          }
          return CircularProgressIndicator();
        },
      ),
      TextField(
        controller: _descriptionController,
        decoration: InputDecoration(hintText: 'Description'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Interactions Page'),
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
    child:StreamBuilder<List<Interactions>>(
        stream: objectbox.getInteractions(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final interaction = snapshot.data![index];
                return ListTile(
                  title: Text('Item 1: ${interaction.items[0].name}, Item 2: ${interaction.items[1].name}'),
                  trailing: Wrap(
                  spacing: 12, // space between two icons
                  children: <Widget>[

                    IconButton(
                   icon: Icon(Icons.visibility),
                  onPressed: () => _viewInteraction(interaction),
                 ),
                  IconButton(
                  icon: Icon(Icons.delete),
                 onPressed: () => _deleteInteraction(interaction.id!),
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
    children: [TextButton(onPressed: () {if (currentPage > 0) {setState(() {currentPage--;});}
    },
    child: Text('<'),
    ),
    StreamBuilder<List<Interactions>>(
    stream: objectbox.getInteractions(),
    builder: (context, snapshot) {
    if (snapshot.hasData) {
    final totalInteractions = snapshot.data!.length;
    return Text('Viewing ${currentPage * interactionsPerPage + 1} - ${(currentPage + 1) * interactionsPerPage} of $totalInteractions');
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
                title: Text('Add Interaction'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: _buildFormFields(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _addInteraction();
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