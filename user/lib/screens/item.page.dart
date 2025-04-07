import 'package:flutter/material.dart';
import 'package:september_twenty_nine_user/entities/item.entity.dart';
import 'package:september_twenty_nine_user/entities/category.entity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:september_twenty_nine_user/screens/plan.page.dart';
import 'package:wikipedia/wikipedia.dart';
import '../objectbox.g.dart';
import '../utils/objectbox.store.dart';
import 'dart:async';

class ItemList extends StatefulWidget {
  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  List<Items>? items;
  final TextEditingController _searchController = TextEditingController();
  late StreamSubscription<List<Items>> itemSub;
  List<Categories>? categories;
  Categories? selectedCategory;

  int startIndex = 0; // Added
  int endIndex = 20; // Added

  @override
  void initState() {
    super.initState();
    ObjectBox.getInstance().then((objectBox) {
      itemSub = objectBox.getItems().listen((retrievedItems) {
        setState(() {
          items = retrievedItems;
        });
      });

      objectBox.getCategories().listen((retrievedCategories) {
        setState(() {
          categories = retrievedCategories;
        });
      });
    });

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    itemSub.cancel();
    super.dispose();
  }

  List<Items> getFilteredItems(String query, Categories? category) {
    List<Items> filteredList = [];
    if (query.isEmpty && category == null) {
      filteredList = items!.skip(startIndex).take(endIndex).toList();
    } else {
      filteredList = items!.where((element) {
        return (element.name.toLowerCase().contains(query.toLowerCase())) &&
            (category == null || element.category.target?.id == category.id); // Ensure proper linking
      }).skip(startIndex).take(endIndex).toList();
    }
    filteredList.sort((a, b) => a.name.compareTo(b.name));
    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = getFilteredItems(_searchController.text, selectedCategory);
    final totalItems = items?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Remedy Items', style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton<Categories>(
            icon: Icon(Icons.filter_list),
            onSelected: (Categories category) {
              setState(() {
                selectedCategory = category;
              });
            },
            itemBuilder: (BuildContext context) {
              return categories!.map((Categories category) {
                return PopupMenuItem<Categories>(
                  value: category,
                  child: Text(category.name, style: GoogleFonts.poppins()),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: items == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Remedies',
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
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade900,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: ListTile(
                    title: Text(
                      item.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailPage(item: item),
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
                  'Viewing ${startIndex + 1} - ${startIndex + 20} of $totalItems',
                  style: GoogleFonts.poppins(),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (endIndex < totalItems) {
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
class ItemDetailPage extends StatefulWidget {
  final Items item;

  ItemDetailPage({required this.item});

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  String selectedTab = 'Description';
  bool _loading = false;
  List<WikipediaSearch> _data = [];
  late TabController _tabController;
  List<String> remedyPlansForThisItem = [];


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
          searchQuery: '${widget.item.name}', limit: 10);
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
          "Remedy Items",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.green.shade700,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset('assets/images/item.png', width: 200, height: 200),
                ),
                Text(
                  "About " + widget.item.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.item.alsoCalled,
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
              buildTabButton('Uses', "assets/images/uses.png"),
              buildTabButton('Precautions', "assets/images/caution.png"),
              buildTabButton('Info', "assets/images/consumerInfo.png"),
              buildTabButton('Conditions', "assets/images/conditions.png"),
              buildTabButton('Symptoms', "assets/images/symptoms.png"),
              buildTabButton('Reference', "assets/images/reference.png"),
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
      case 'Uses':
        return formatStandardContent(
          'Uses', widget.item.uses,
        );
      case 'Precautions':
        return formatStandardContent(
          'Precautions', widget.item.caution,
        );
      case 'Info':
        return formatStandardContent(
          'Conscientious Consumer Information', widget.item.conscientiousConsumerInformation,
        );
      case 'Conditions':
        final conditions = <String>[];
        for (final plan in widget.item.plan) {
          final condition = plan.condition.target;
          if (condition != null) {
            conditions.add(condition.name);
          }
        }
        return ListView.builder(
          itemCount: conditions.length,
          itemBuilder: (context, index) {
            final condition = conditions[index];
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                borderRadius: BorderRadius.circular(25),
              ),
              margin: EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(
                  condition,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  final plan = widget.item.plan.firstWhere(
                        (element) => element.condition.target?.name == condition,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => conditionPlanDetailPage(plan: plan),
                    ),
                  );
                },
              ),
            );
          },
        );
      case 'Symptoms':
        final symptoms = <String>[];
        for (final plan in widget.item.plan) {
          final symptom = plan.symptom.target;
          if (symptom != null) {
            symptoms.add(symptom.name);
          }
        }
        return ListView.builder(
          itemCount: symptoms.length,
          itemBuilder: (context, index) {
            final symptom = symptoms[index];
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.purpleAccent,
                borderRadius: BorderRadius.circular(25),
              ),
              margin: EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(
                  symptom,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  final plan = widget.item.plan.firstWhere(
                        (element) => element.symptom.target?.name == symptom,
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

      case 'References':
        return formatStandardContent(
          'References', widget.item.references,
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

