import 'package:flutter/material.dart';
import '../entities/condition.entity.dart';
import '../entities/item.entity.dart';
import '../entities/symptom.entity.dart';
import '../entities/plan.entity.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../main.dart';  // import your objectbox.store.dart file

class PlanPage extends StatefulWidget {
  @override
  _PlanPageState createState() => _PlanPageState();
}

//TODO: add dropdown delection for symptom/condition/item
class _PlanPageState extends State<PlanPage> {
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _dosageController = TextEditingController();
  final _precautionsController = TextEditingController();
  final _referencesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int currentPage = 0;
  final int plansPerPage = 10;
  int totalPlans = 0;
  Items? selectedItem;
  Conditions? selectedCondition;
  Symptoms? selectedSymptom;// Either 'Condition' or 'Symptom'



  void _addPlan() {
    if (selectedItem != null ) {
      final newPlan = Plans(
        name: _nameController.text,
        instructions: _instructionsController.text,
        dosage: _dosageController.text,
        precautions: _precautionsController.text,
        references: _referencesController.text,
      );
      newPlan.item.target = selectedItem!;
      newPlan.condition.target = selectedCondition!;
      newPlan.symptom.target = selectedSymptom!;
      objectbox.updatePlan(newPlan);


      _nameController.clear();
      _instructionsController.clear();
      _dosageController.clear();
      _precautionsController.clear();
      _referencesController.clear();
    }
  }


  void _deletePlan(int id) {
    objectbox.removePlan(id);
  }

  void _editPlan(Plans plan) {
    _nameController.text = plan.name;
    _instructionsController.text = plan.instructions;
    _dosageController.text = plan.dosage;
    _precautionsController.text = plan.precautions;
    _referencesController.text = plan.references;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Plan'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _buildFormFields(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                plan.name = _nameController.text;
                plan.instructions = _instructionsController.text;
                plan.dosage = _dosageController.text;
                plan.precautions = _precautionsController.text;
                plan.references = _referencesController.text;
                plan.item.target = selectedItem!;
                plan.condition.target = selectedCondition!;
                plan.symptom.target = selectedSymptom!;

                objectbox.updatePlan(plan);
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
      StreamBuilder<List<Items>>(
        stream: objectbox.getItems(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            // Check if selectedCategory exists in the snapshot.data
            if (!snapshot.data!.contains(selectedItem)) {
              selectedItem = snapshot.data![0];
            }
            return DropdownButtonFormField<Items>(
              //value: selectedCategory,
              items: snapshot.data!.map((Items item) {
                return DropdownMenuItem<Items>(
                  value: item,
                  child: Text(item.name),
                );
              }).toList(),
              onChanged: (Items? newItems) {
                setState(() {
                  selectedItem = newItems;
                });
              },
              decoration: InputDecoration(labelText: 'Select Item'),
            );
          }
          return CircularProgressIndicator();
        },
      ),
      StreamBuilder<List<Conditions>>(
        stream: objectbox.getConditions(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            // Check if selectedCategory exists in the snapshot.data
            if (!snapshot.data!.contains(selectedCondition)) {
              selectedCondition = snapshot.data![0];
            }
            return DropdownButtonFormField<Conditions>(
              //value: selectedCategory,
              items: snapshot.data!.map((Conditions condition) {
                return DropdownMenuItem<Conditions>(
                  value: condition,
                  child: Text(condition.name),
                );
              }).toList(),
              onChanged: (Conditions? newConditions) {
                setState(() {
                  selectedCondition = newConditions;
                });
              },
              decoration: InputDecoration(labelText: 'Select  Condition'),
            );
          }
          return CircularProgressIndicator();
        },
      ),
      StreamBuilder<List<Symptoms>>(
        stream: objectbox.getSymptoms(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            // Check if selectedCategory exists in the snapshot.data
            if (!snapshot.data!.contains(selectedSymptom)) {
              selectedSymptom = snapshot.data![0];
            }
            return DropdownButtonFormField<Symptoms>(
              //value: selectedCategory,
              items: snapshot.data!.map((Symptoms symptom) {
                return DropdownMenuItem<Symptoms>(
                  value: symptom,
                  child: Text(symptom.name),
                );
              }).toList(),
              onChanged: (Symptoms? newsymptom) {
                setState(() {
                  selectedSymptom = newsymptom;
                });
              },
              decoration: InputDecoration(labelText: 'Select  Symptom'),
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
        controller: _instructionsController,
        decoration: InputDecoration(hintText: 'Instructions'),
      ),
      TextField(
        controller: _dosageController,
        decoration: InputDecoration(hintText: 'Dosage'),
      ),
      TextField(
        controller: _precautionsController,
        decoration: InputDecoration(hintText: 'Precautions'),
      ),
      TextField(
        controller: _referencesController,
        decoration: InputDecoration(hintText: 'References'),
      ),
    ];
  }

  void _viewPlan(Plans plan) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(plan.name),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Instructions: ${plan.instructions}'),
                Text('Dosage: ${plan.dosage}'),
                Text('Precautions: ${plan.precautions}'),
                Text('References: ${plan.references}'),
                Text('Item: ${plan.item.target?.name ?? 'Unknown'}'),
                Text('Condition: ${plan.condition.target?.name ?? 'Unknown'}'),
                Text('Symptom: ${plan.symptom.target?.name ?? 'Unknown'}'),// Show the category
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
      appBar: AppBar(title: Text('Plan Page'),
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
            child: StreamBuilder<List<Plans>>(
              stream: objectbox.getPlans(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final plan = snapshot.data![index];
                      return ListTile(
                        title: Text(plan.name),
                        subtitle: Text(plan.instructions),
                        trailing: Wrap(
                          spacing: 12,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.visibility),
                              onPressed: () => _viewPlan(plan),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editPlan(plan),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deletePlan(plan.id),
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
              StreamBuilder<List<Plans>>(
                stream: objectbox.getPlans(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final totalItems = snapshot.data!.length;
                    return Text(
                        'Viewing ${currentPage * plansPerPage + 1} - ${(currentPage + 1) * plansPerPage} of $totalPlans');
                  }
                  return Text('Loading...');
                },
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    currentPage++;
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
                title: Text('Add Plan'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: _buildFormFields(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _addPlan();
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
