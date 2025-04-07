import 'package:flutter/material.dart';
import '../entities/condition.entity.dart';
import '../main.dart';  // import your objectbox.store.dart file

class ConditionPage extends StatefulWidget {
  @override
  _ConditionPageState createState() => _ConditionPageState();
}

class _ConditionPageState extends State<ConditionPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _causesController = TextEditingController();
  final _complicationsController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int currentPage = 0;
  final int conditionsPerPage = 10;
  int totalConditions = 0;

  void _addCondition() {
    final newCondition = Conditions(
      name: _nameController.text,
      description: _descriptionController.text,
      causes: _causesController.text.split(', '),
      complications: _complicationsController.text.split(', '),
    );

    objectbox.updateCondition(newCondition);

    _nameController.clear();
    _descriptionController.clear();
    _causesController.clear();
    _complicationsController.clear();
  }

  void _deleteCondition(int id) {
    objectbox.removeCondition(id);
  }

  void _editCondition(Conditions condition) {
    _nameController.text = condition.name;
    _descriptionController.text = condition.description;
    _causesController.text = condition.causes.join(', ');
    _complicationsController.text = condition.complications.join(', ');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Condition'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _buildFormFields(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                condition.name = _nameController.text;
                condition.description = _descriptionController.text;
                condition.causes = _causesController.text.split(', ');
                condition.complications = _complicationsController.text.split(', ');

                objectbox.updateCondition(condition);
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
      TextField(
        controller: _nameController,
        decoration: InputDecoration(hintText: 'Name'),
      ),
      TextField(
        controller: _descriptionController,
        decoration: InputDecoration(hintText: 'Description'),
      ),
      TextField(
        controller: _causesController,
        decoration: InputDecoration(hintText: 'Causes (comma-separated)'),
      ),
      TextField(
        controller: _complicationsController,
        decoration: InputDecoration(hintText: 'Complications (comma-separated)'),
      ),
    ];
  }

  void _viewCondition(Conditions condition) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(condition.name),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Description: ${condition.description}'),
                Text('Causes: ${condition.causes.join(', ')}'),
                Text('Complications: ${condition.complications.join(', ')}'),
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
        title: Text('Conditions Page'),
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
            child: StreamBuilder<List<Conditions>>(
              stream: objectbox.getConditions(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var conditions = snapshot.data!;
                  //totalItems = items.length;
                  // Case-insensitive search
                  if (_searchController.text.isNotEmpty) {
                    conditions = conditions.where((condition) =>
                        condition.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
                  }
                  // Case-insensitive sort
                  conditions.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                  // Pagination
                  final totalConditions = conditions.length;
                  final start = currentPage * conditionsPerPage;
                  final end = start + conditionsPerPage > totalConditions ? totalConditions : start + conditionsPerPage;
                  final currentConditions = conditions.sublist(start, end);

                  return ListView.builder(
                    itemCount: currentConditions.length,
                    itemBuilder: (context, index) {
                      final condition = currentConditions[index];
                      return ListTile(
                        title: Text(condition.name),
                        trailing: Wrap(
                          spacing: 12, // space between two icons
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editCondition(condition),
                            ),
                            IconButton(
                              icon: Icon(Icons.visibility),
                              onPressed: () => _viewCondition(condition),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteCondition(condition.id!),
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
              StreamBuilder<List<Conditions>>(
                stream: objectbox.getConditions(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final totalItems = snapshot.data!.length;
                    return Text('Viewing ${currentPage * conditionsPerPage + 1} - ${(currentPage + 1) * conditionsPerPage} of $totalItems');
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
                title: Text('Add Condition'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: _buildFormFields(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _addCondition();
                      Navigator.of(context).pop();
                      showDialog(  context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Confirmation'),
                            content: Text('Are you sure you would like to add this condition?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _addCondition();
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
        backgroundColor: Colors.orange, // Set the background color
        foregroundColor: Colors.white, // Set the foreground color (icon color)
        elevation: 5.0,
      ),
    );
  }
}

