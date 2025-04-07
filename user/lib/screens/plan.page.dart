import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:september_twenty_nine_user/screens/review.page.dart';
import 'package:wikipedia/wikipedia.dart';
import '../utils/objectbox.store.dart';
import '../entities/plan.entity.dart';
import 'dart:async';

class PlanList extends StatefulWidget {
  @override
  _PlanListState createState() => _PlanListState();
}

class _PlanListState extends State<PlanList> {
  List<Plans>? plans;
  final TextEditingController _searchController = TextEditingController();
  late StreamSubscription<List<Plans>> planSub;

  int startIndex = 0; // Added
  int endIndex = 20;

  @override
  void initState() {
    super.initState();
    ObjectBox.getInstance().then((objectBox) {
      planSub = objectBox.getPlans().listen((retrievedPlans) {
        setState(() {
          plans = retrievedPlans;
        });
      });
    });
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    planSub.cancel();
    super.dispose();
  }

  List<Plans> getFilteredPlans(String query) {
    if (query.isEmpty) return plans!.skip(startIndex).take(endIndex).toList();
    return plans!
        .where((element) => element.name.toLowerCase().contains(query.toLowerCase()))
        .skip(startIndex)
        .take(endIndex)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlans = getFilteredPlans(_searchController.text);
    final totalPlans = plans?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Plans', style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
      ),
      body: plans == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Plans',
                labelStyle: GoogleFonts.poppins(color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              style: GoogleFonts.poppins(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPlans.length,
              itemBuilder: (context, index) {
                final plan = filteredPlans[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade300,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: ListTile(
                    title: Text(
                      plan.name,
                      style: GoogleFonts.poppins(),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlanDetailPage(plan: plan),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (startIndex - 20 >= 0) {
                      setState(() {
                        startIndex -= 20;
                        endIndex -= 20;
                      });
                    }
                  },
                  child: Text("<", style: GoogleFonts.poppins()),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.teal, // Set button color to green
                  ),
                ),
                Text(
                  'Viewing ${startIndex + 1} - ${startIndex + 20} of $totalPlans',
                  style: GoogleFonts.poppins(),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (endIndex < totalPlans) {
                      setState(() {
                        startIndex += 20;
                        endIndex += 20;
                      });
                    }
                  },
                  child: Text(">", style: GoogleFonts.poppins()),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.teal, // Set button color to green
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class conditionPlanDetailPage extends StatefulWidget {
  final Plans plan;

  conditionPlanDetailPage({required this.plan});

  @override
  _conditionPlanDetailPageState createState() => _conditionPlanDetailPageState();
}

class _conditionPlanDetailPageState extends State<conditionPlanDetailPage> {
  bool _showInstructions = false;
  bool _showDosage = false;
  bool _showPrecautions = false;
  bool _showReferences = false;
  bool _showReviews = false;

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
          // Add navigation logic to the desired page when "illness.png" is tapped.
          // You can use Navigator to navigate to the appropriate page.
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
class PlanDetailPage extends StatefulWidget {
  final Plans plan;

  PlanDetailPage({required this.plan});

  @override
  _PlanDetailPageState createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends State<PlanDetailPage> {
  bool _showInstructions = false;
  bool _showDosage = false;
  bool _showPrecautions = false;
  bool _showReferences = false;
  bool _showReviews = false;

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
          // Add navigation logic to the desired page when "illness.png" is tapped.
          // You can use Navigator to navigate to the appropriate page.
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
class symptomPlanDetailPage extends StatefulWidget {
final Plans plan;

symptomPlanDetailPage({required this.plan});

@override
_symptomPlanDetailPageState createState() => _symptomPlanDetailPageState();
}

class _symptomPlanDetailPageState extends State<symptomPlanDetailPage> {
  bool _showInstructions = false;
  bool _showDosage = false;
  bool _showPrecautions = false;
  bool _showReferences = false;
  bool _showReviews = false;

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
                        'Unknown symptom'}' with '${widget.plan.item.target
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
          // Add navigation logic to the desired page when "illness.png" is tapped.
          // You can use Navigator to navigate to the appropriate page.
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