import 'package:flutter/material.dart';
import '../entities/plan.entity.dart';
import '../entities/symptom.entity.dart';
import '../main.dart';  // import your objectbox.store.dart file

class SymptomPage extends StatefulWidget {
  @override
  _SymptomPageState createState() => _SymptomPageState();
}

class _SymptomPageState extends State<SymptomPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _causesController = TextEditingController();
  final _complicationsController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int currentPage = 0;
  final int symptomsPerPage = 10;
  int totalSymptoms = 0;

  void _addSymptom() {
    final newSymptom = Symptoms(
      name: _nameController.text,
      description: _descriptionController.text,
      causes: _causesController.text.split(', '),
      complications: _complicationsController.text.split(', '),
    );

    objectbox.updateSymptom(newSymptom);

    _nameController.clear();
    _descriptionController.clear();
    _causesController.clear();
    _complicationsController.clear();
  }

  void _deleteSymptom(int id) {
    objectbox.removeSymptom(id);
  }

  void _editSymptom(Symptoms symptom) {
    _nameController.text = symptom.name;
    _descriptionController.text = symptom.description;
    _causesController.text = symptom.causes.join(', ');
    _complicationsController.text = symptom.complications.join(', ');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Symptom'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _buildFormFields(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                symptom.name = _nameController.text;
                symptom.description = _descriptionController.text;
                symptom.causes = _causesController.text.split(', ');
                symptom.complications = _complicationsController.text.split(', ');

                objectbox.updateSymptom(symptom);
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

  void _viewSymptom(Symptoms symptom) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(symptom.name),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Description: ${symptom.description}'),
                Text('Causes: ${symptom.causes.join(', ')}'),
                Text('Complications: ${symptom.complications.join(', ')}'),
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
        title: Text('Sypmtom Page'),
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
            child: StreamBuilder<List<Symptoms>>(
              stream: objectbox.getSymptoms(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var symptoms = snapshot.data!;
                  //totalItems = items.length;
                  // Case-insensitive search
                  if (_searchController.text.isNotEmpty) {
                    symptoms = symptoms.where((symptom) =>
                        symptom.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
                  }
                  // Case-insensitive sort
                  symptoms.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                  // Pagination
                  final totalSymptoms = symptoms.length;
                  final start = currentPage * symptomsPerPage;
                  final end = start + symptomsPerPage > totalSymptoms ? totalSymptoms : start + symptomsPerPage;
                  final currentSymptoms = symptoms.sublist(start, end);

                  return ListView.builder(
                    itemCount: currentSymptoms.length,
                    itemBuilder: (context, index) {
                      final symptom = currentSymptoms[index];
                      return ListTile(
                        title: Text(symptom.name),
                        trailing: Wrap(
                          spacing: 12, // space between two icons
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editSymptom(symptom),
                            ),
                            IconButton(
                              icon: Icon(Icons.visibility),
                              onPressed: () => _viewSymptom(symptom),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteSymptom(symptom.id!),
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
              StreamBuilder<List<Symptoms>>(
                stream: objectbox.getSymptoms(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final totalSymptoms = snapshot.data!.length;
                    return Text('Viewing ${currentPage * symptomsPerPage + 1} - ${(currentPage + 1) * symptomsPerPage} of $totalSymptoms');
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
                title: Text('Add Symptom'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: _buildFormFields(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _addSymptom();
                      Navigator.of(context).pop();
                      showDialog(  context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Confirmation'),
                            content: Text('Are you sure you would like to add this condition?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _addSymptom();
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