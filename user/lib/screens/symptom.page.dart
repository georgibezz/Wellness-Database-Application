import 'package:flutter/material.dart';
import 'package:september_twenty_nine_user/entities/symptom.entity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:september_twenty_nine_user/screens/plan.page.dart';
import 'package:wikipedia/wikipedia.dart';
import '../utils/objectbox.store.dart';
import 'dart:async';

class SymptomList extends StatefulWidget {
  @override
  _SymptomListState createState() => _SymptomListState();
}

class _SymptomListState extends State<SymptomList> {
  List<Symptoms>? symptoms;
  final TextEditingController _searchController = TextEditingController();
  late StreamSubscription<List<Symptoms>> symptomSub;

  int startIndex = 0; // Added
  int endIndex = 20; // Added

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

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    symptomSub.cancel();
    super.dispose();
  }


  List<Symptoms> getFilteredSymptoms(String query) {
    List<Symptoms> filteredList = [];
    if (query.isEmpty) filteredList = symptoms!.skip(startIndex).take(endIndex).toList();
    else {
      filteredList = symptoms!
          .where((element) => element.name.toLowerCase().contains(query.toLowerCase()))
          .skip(startIndex)
          .take(endIndex)
          .toList();
    }
    // Sort the conditions in ascending alphabetical order
    filteredList.sort((a, b) => a.name.compareTo(b.name));
    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    final filteredSymptoms = getFilteredSymptoms(_searchController.text);
    final totalSymptoms = symptoms?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Symptoms', style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
      ),
      body: symptoms == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Symptoms',
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
              itemCount: filteredSymptoms.length,
              itemBuilder: (context, index) {
                final symptom = filteredSymptoms[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: ListTile(
                    title: Text(
                      symptom.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                      ),

                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SymptomDetailPage(symptom: symptom),
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
                  'Viewing ${startIndex + 1} - ${startIndex + 20} of $totalSymptoms',
                  style: GoogleFonts.poppins(),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (endIndex < totalSymptoms) {
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
class SymptomDetailPage extends StatefulWidget {
  final Symptoms symptom;

  SymptomDetailPage({required this.symptom});

  @override
  _SymptomDetailPageState createState() => _SymptomDetailPageState();
}

class _SymptomDetailPageState extends State<SymptomDetailPage> {
  String selectedTab = 'Description';
  bool _loading = false;
  List<WikipediaSearch> _data = [];
  late TabController _tabController;
  List<String> remedyPlansForThisSymptom = [];


  @override
  void initState() {
    super.initState();
    getWikipediaData();
  }

  Future<void> getWikipediaData() async {
    try {
      setState(() {
        _loading = true;
      });
      Wikipedia instance = Wikipedia();
      var result = await instance.searchQuery(
          searchQuery: '${widget.symptom.name}', limit: 10);
      setState(() {
        _loading = false;
        _data = result!.query!.search!;
      });
    } catch (e) {
      print(e);
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Symptoms",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.purpleAccent,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset('assets/images/symptom.png', width: 200, height: 200),
                ),
                Text(
                  "About " + widget.symptom.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.symptom.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTabButton('Wikipedia', "assets/images/wikipedia.png"),
              buildTabButton('Causes', "assets/images/causes.png"),
              buildTabButton(
                  'Complications', "assets/images/complications.png"),
              buildTabButton('Remedy Plans', "assets/images/remedies.png"),
            ],
          ),
          const Divider(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildSelectedTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabButton(String tabName, String imagePath) {
    bool isSelected = selectedTab == tabName;

    return InkWell(
      onTap: () {
        setState(() {
          selectedTab = isSelected ? '' : tabName;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: isSelected ? Colors.teal : Colors.grey,
            child: Image.asset(
              imagePath,
              width: 30,
              height: 30,
            ),
          ),
          Visibility(
            visible: isSelected,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                tabName,
                style: GoogleFonts.poppins(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget formatStandardContent(String heading, String details) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Description',
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            ...details.split(';').map((record) => Container(
              width: double.infinity, // Make it full width
              margin: EdgeInsets.only(bottom: 8), // Margin between containers
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                record,
                style: GoogleFonts.poppins(),
              ),
            )),
          ],
        ),
      ),
    );
  }


  Widget buildSelectedTabContent() {
    switch (selectedTab) {
      case 'Wikipedia':
        return _buildWikipediaContent();
      case 'Causes':
        return formatStandardContent(
          'Causes', widget.symptom.causes.join('\n'),
        );
      case 'Complications':
        return formatStandardContent(
          'Complications', widget.symptom.complications.join('\n'),
        );
      case 'Remedy Plans':
        final items = <String>[];
        for (final plan in widget.symptom.plan) {
          final item = plan.item.target;
          if (item != null) {
            items.add(item.name);
          }
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green.shade900,
                borderRadius: BorderRadius.circular(25),
              ),
              margin: EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(
                  item,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  final plan = widget.symptom.plan.firstWhere(
                        (element) => element.item.target?.name == item,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => symptomPlanDetailPage(plan: plan),
                    ),
                  );
                },
              ),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }


  Widget _buildWikipediaContent() {
    return Stack(
      children: [
        ListView.builder(
          itemCount: _data.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) => InkWell(
            onTap: () async {
              Wikipedia instance = Wikipedia();
              setState(() {
                _loading = true;
              });
              var pageData = await instance.searchSummaryWithPageId(pageId: _data[index].pageid!);

              setState(() {
                _loading = false;
              });
              if (pageData == null) {
                const snackBar = SnackBar(
                  content: Text('Data Not Found'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                showGeneralDialog(
                  context: context,
                  pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
                    appBar: AppBar(
                      title: Text(_data[index].title!, style: const TextStyle(color: Colors.black)),
                      backgroundColor: Colors.white,
                      iconTheme: const IconThemeData(color: Colors.black),
                    ),
                    body: ListView(
                      padding: const EdgeInsets.all(10),
                      children: [
                        Text(pageData.title!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 8),
                        Text(pageData.description!, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 8),
                        Text(pageData.extract!)
                      ],
                    ),
                  ),
                );
              }
            },
            child: Card(
              elevation: 5,
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(_data[index].title!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 10),
                    Text(_data[index].snippet!),
                  ],
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: _loading,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }
}

