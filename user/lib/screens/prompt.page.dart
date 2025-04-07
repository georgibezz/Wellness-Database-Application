import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:september_twenty_nine_user/entities/category.entity.dart';
import 'package:september_twenty_nine_user/entities/condition.entity.dart';
import 'package:september_twenty_nine_user/entities/plan.entity.dart';
import 'package:september_twenty_nine_user/screens/review.page.dart';
import '../entities/symptom.entity.dart';
import '../utils/objectbox.store.dart';

class ConditionOrSymptom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Condition or Symptom'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Feeling ill? What would you like to treat?',
              style: GoogleFonts.poppins(
                fontSize: 22.0, // Adjust the font size as needed
              ),
            ),

            Image.asset('assets/images/sick_person.jpg'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ConditionRemedyPlan()),
                );
              },
              child: Text('Condition', style: GoogleFonts.poppins(),
             ),
              style: ElevatedButton.styleFrom(
                primary: Colors.teal,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SymptomRemedyPlan()),
                );
              },
              child: Text('Symptom',style: GoogleFonts.poppins(),),
              style: ElevatedButton.styleFrom(
                primary: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SymptomRemedyPlan extends StatefulWidget {
  @override
  _SymptomRemedyPlanState createState() => _SymptomRemedyPlanState();
}

class _SymptomRemedyPlanState extends State<SymptomRemedyPlan> {
  List<Symptoms>? symptoms;
  late StreamSubscription<List<Symptoms>> symptomSub;

  @override
  void initState() {
    super.initState();
    ObjectBox.getInstance().then((objectBox) {
      symptomSub = objectBox.getSymptoms().listen((retrievedSymptoms) {
        setState(() {
          symptoms = retrievedSymptoms;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Symptoms'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<ObjectBox>(
        future: ObjectBox.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final objectBox = snapshot.data!;
            return StreamBuilder<List<Symptoms>>(
              stream: objectBox.getSymptoms(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final symptom = snapshot.data![index];
                      return ListTile(
                        title: Text(symptom.name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SymptomCategoryRemedyPlan(symptomId: symptom.id,),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: Text('Error initializing ObjectBox'),
            );
          }
        },
      ),
    );
  }
}
class ConditionRemedyPlan extends StatefulWidget {
  @override
  _ConditionRemedyPlanState createState() => _ConditionRemedyPlanState();
}

class _ConditionRemedyPlanState extends State<ConditionRemedyPlan> {
  List<Conditions>? conditions;
  List<Conditions>? filteredConditions;
  late StreamSubscription<List<Conditions>> conditionSub;
  TextEditingController searchController = TextEditingController();
  int startIndex = 0;
  int itemsPerPage = 15;
  int endIndex = 14;

  @override
  void initState() {
    super.initState();
    ObjectBox.getInstance().then((objectBox) {
      conditionSub = objectBox.getConditions().listen((retrievedConditions) {
        setState(() {
          conditions = retrievedConditions;
          conditions!.sort((a, b) => a.name.compareTo(b.name));
          filteredConditions = conditions;
          endIndex = (filteredConditions!.length < itemsPerPage)
              ? filteredConditions!.length - 1
              : itemsPerPage - 1;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Conditions',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<ObjectBox>(
        future: ObjectBox.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final objectBox = snapshot.data!;
            return Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: 'Search Conditions',
                  ),
                  onChanged: (value) {
                    setState(() {
                      filteredConditions = conditions!
                          .where((condition) => condition.name
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                ),
                Text(
                  'Viewing ${startIndex + 1} to ${endIndex + 1} of ${filteredConditions!.length}',
                  style: GoogleFonts.poppins(),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: endIndex - startIndex + 1,
                    itemBuilder: (context, index) {
                      final condition = filteredConditions![startIndex + index];
                      return ListTile(
                        title: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            condition.name,
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ConditionCategoryRemedyPlan(conditionId: condition.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          startIndex =
                          (startIndex - itemsPerPage >= 0) ? startIndex - itemsPerPage : 0;
                          endIndex = startIndex + itemsPerPage - 1;
                        });
                      },
                      child: Text('< Back', style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.teal, // This sets the background color to teal
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          startIndex =
                          (startIndex + itemsPerPage < filteredConditions!.length)
                              ? startIndex + itemsPerPage
                              : startIndex;
                          endIndex = (endIndex + itemsPerPage < filteredConditions!.length)
                              ? endIndex + itemsPerPage
                              : filteredConditions!.length - 1;
                        });
                      },
                      child: Text('Forward >', style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.teal, // This sets the background color to teal
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: Text(
                'Error initializing ObjectBox',
                style: GoogleFonts.poppins(),
              ),
            );
          }
        },
      ),
    );
  }
}

class ConditionCategoryRemedyPlan extends StatelessWidget {
  final int conditionId;

  ConditionCategoryRemedyPlan({required this.conditionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categories for Plan',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<ObjectBox>(
        future: ObjectBox.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final objectBox = snapshot.data!;
            return Column(
              children: [
                SizedBox(height: 27.0),
                Text(
                  'It is now time for you to select the type of plan you would like to use.',
                  style: GoogleFonts.poppins(fontSize: 20.0),
                ),
                Image.asset('assets/images/choice.jpg'), // Make sure the image is in the assets/images directory
                Expanded(
                  child: StreamBuilder<List<Categories>>(
                    stream: objectBox.getCategories(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final category = snapshot.data![index];
                            return ListTile(
                              title: Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  category.name,
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                              onTap: () async {
                                // Fetch plans using the conditionId and categoryId
                                final plans = await objectBox
                                    .getPlansByConditionAndCategory(
                                    conditionId, category.id);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ConditionRemedyPlanSelection(
                                            conditionId, category.id
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: Text(
                'Error initializing ObjectBox',
                style: GoogleFonts.poppins(),
              ),
            );
          }
        },
      ),
    );
  }
}
class SymptomCategoryRemedyPlan extends StatelessWidget {
  final int symptomId;

  SymptomCategoryRemedyPlan({required this.symptomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories for Symptoms'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<ObjectBox>(
        future: ObjectBox.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final objectBox = snapshot.data!;
            return StreamBuilder<List<Categories>>(
              stream: objectBox.getCategories(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final category = snapshot.data![index];
                      return ListTile(
                        title: Text(category.name),
                        onTap: () async {
                          // Fetch plans using the conditionId and categoryId
                          final plans = await objectBox
                              .getPlansBySymptomAndCategory(
                              symptomId, category.id);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                 SymptomRemedyPlanSelection(
                                      symptomId,category.id
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: Text('Error initializing ObjectBox'),
            );
          }
        },
      ),
    );
  }
}
class ConditionRemedyPlanSelection extends StatelessWidget {
  final int selectedConditionId;
  final int selectedCategoryId;

  ConditionRemedyPlanSelection(this.selectedConditionId, this.selectedCategoryId);

  @override
  Widget build(BuildContext context) {
    final objectBoxFuture = ObjectBox.getInstance();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Remedy Plan Selection',
          style: GoogleFonts.poppins(fontSize: 22.0),
        ),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<ObjectBox>(
        future: objectBoxFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final objectBox = snapshot.data;
              return Column(
                children: [
                  SizedBox(height: 27.0),
                  Text(
                    'Now select the plan of your choice.',
                    style: GoogleFonts.poppins(fontSize: 22.0),
                  ),
                  Image.asset('assets/images/selectingplan.jpg'),
                  Expanded(
                    child: FutureBuilder<List<Plans>>(
                      future: objectBox!.getPlansByConditionAndCategory(
                          selectedConditionId, selectedCategoryId),
                      builder: (context, plansSnapshot) {
                        if (plansSnapshot.connectionState ==
                            ConnectionState.done) {
                          if (plansSnapshot.hasData) {
                            return ListView.builder(
                              itemCount: plansSnapshot.data!.length,
                              itemBuilder: (context, index) {
                                final plan = plansSnapshot.data![index];
                                return ListTile(
                                  title: Container(
                                    padding: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Text(
                                      plan.name,
                                      style: GoogleFonts.poppins(fontSize: 22.0),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ConditionPlanDetailPages(plan: plan),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          } else if (plansSnapshot.hasError) {
                            return Center(
                                child: Text(
                                  'Error: ${plansSnapshot.error}',
                                  style: GoogleFonts.poppins(fontSize: 22.0),
                                ));
                          } else {
                            return Center(
                                child: Text(
                                  'No Plans Available',
                                  style: GoogleFonts.poppins(fontSize: 22.0),
                                ));
                          }
                        }
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.poppins(fontSize: 22.0),
                  ));
            } else {
              return Center(
                  child: Text(
                    'Failed to initialize ObjectBox',
                    style: GoogleFonts.poppins(fontSize: 22.0),
                  ));
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class SymptomRemedyPlanSelection extends StatelessWidget {
  final int selectedSymptomId;
  final int selectedCategoryId;

  SymptomRemedyPlanSelection(this.selectedSymptomId, this.selectedCategoryId);

  @override
  Widget build(BuildContext context) {
    final objectBoxFuture = ObjectBox.getInstance();

    return Scaffold(
      appBar: AppBar(
          title: Text('Remedy Plan Selection'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<ObjectBox>(
        future: objectBoxFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final objectBox = snapshot.data;
              return FutureBuilder<List<Plans>>(
                future: objectBox!.getPlansBySymptomAndCategory(
                    selectedSymptomId, selectedCategoryId),
                builder: (context, plansSnapshot) {
                  if (plansSnapshot.connectionState == ConnectionState.done) {
                    if (plansSnapshot.hasData) {
                      return ListView.builder(
                        itemCount: plansSnapshot.data!.length,
                        itemBuilder: (context, index) {
                          final plan = plansSnapshot.data![index];
                          return ListTile(
                            title: Text(plan.name),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SymptomPlanDetailPages(plan: plan),
                                ),
                              );
                            },
                          );
                        },
                      );
                    } else if (plansSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${plansSnapshot.error}'));
                    } else {
                      return Center(child: Text('No Plans Available'));
                    }
                  }
                  return Center(child: CircularProgressIndicator());
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Center(child: Text('Failed to initialize ObjectBox'));
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class ConditionPlanDetailPages extends StatefulWidget {
  final Plans plan;

  ConditionPlanDetailPages({required this.plan});

  @override
 ConditionPlanDetailPagesState createState() => ConditionPlanDetailPagesState();
}

class ConditionPlanDetailPagesState extends State<ConditionPlanDetailPages> {
  bool _showInstructions = false;
  bool _showDosage = false;
  bool _showPrecautions = false;
  bool _showReferences = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Plans",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center( // Adding Image above Plan Name
                  child: Image.asset(
                      "assets/images/plan.png", width: 200, height: 200),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    "Treating '${widget.plan.condition.target?.name ??
                        'Unknown Condition'}' with '${widget.plan.item.target
                        ?.name ?? 'Unknown Item'}'",
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ),
          _buildExpandableContainer(
              'Instructions', _showInstructions, widget.plan.instructions),
          _buildExpandableContainer('Dosage', _showDosage, widget.plan.dosage),
          _buildExpandableContainer(
              'Precautions', _showPrecautions, widget.plan.precautions),
          _buildExpandableContainer(
              'References', _showReferences, widget.plan.references),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          backgroundColor: Colors.teal;
          // Handle your logic for adding reviews here
          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => AddReviewScreen(), // Replace with the actual page you want to navigate to
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Container _buildExpandableContainer(String title, bool isOpen,
      String content) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isOpen ? Colors.teal : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Explicitly set the alignment to start
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(
                vertical: 0.0, horizontal: 16.0),
            title: Text(title, style: GoogleFonts.poppins()),
            onTap: () {
              setState(() {
                switch (title) {
                  case 'Instructions':
                    _showInstructions = !_showInstructions;
                    break;
                  case 'Dosage':
                    _showDosage = !_showDosage;
                    break;
                  case 'Precautions':
                    _showPrecautions = !_showPrecautions;
                    break;
                  case 'References':
                    _showReferences = !_showReferences;
                    break;
                }
              });
            },
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                content,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SymptomPlanDetailPages extends StatefulWidget {
  final Plans plan;

  SymptomPlanDetailPages({required this.plan});

  @override
  SymptomPlanDetailPagesState createState() => SymptomPlanDetailPagesState();
}

class SymptomPlanDetailPagesState extends State<SymptomPlanDetailPages> {
  bool _showInstructions = false;
  bool _showDosage = false;
  bool _showPrecautions = false;
  bool _showReferences = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Plans",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center( // Adding Image above Plan Name
                  child: Image.asset(
                      "assets/images/plan.png", width: 200, height: 200),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    "Treating '${widget.plan.symptom.target?.name ??
                        'Unknown Condition'}' with '${widget.plan.item.target
                        ?.name ?? 'Unknown Item'}'",
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ),
          _buildExpandableContainer(
              'Instructions', _showInstructions, widget.plan.instructions),
          _buildExpandableContainer('Dosage', _showDosage, widget.plan.dosage),
          _buildExpandableContainer(
              'Precautions', _showPrecautions, widget.plan.precautions),
          _buildExpandableContainer(
              'References', _showReferences, widget.plan.references),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle your logic for adding reviews here
          backgroundColor: Colors.teal;
          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => AddReviewScreen(), // Replace with the actual page you want to navigate to
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Container _buildExpandableContainer(String title, bool isOpen,
      String content) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isOpen ? Colors.teal : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Explicitly set the alignment to start
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(
                vertical: 0.0, horizontal: 16.0),
            title: Text(title, style: GoogleFonts.poppins()),
            onTap: () {
              setState(() {
                switch (title) {
                  case 'Instructions':
                    _showInstructions = !_showInstructions;
                    break;
                  case 'Dosage':
                    _showDosage = !_showDosage;
                    break;
                  case 'Precautions':
                    _showPrecautions = !_showPrecautions;
                    break;
                  case 'References':
                    _showReferences = !_showReferences;
                    break;
                }
              });
            },
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                content,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}