import 'dart:async';
import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:september_twenty_nine_user/entities/symptom.entity.dart';
import '../entities/condition.entity.dart';
import '../entities/plan.entity.dart';
import '../utils/objectbox.store.dart';

class RemedyPlanScreen extends StatefulWidget {
  @override
  _RemedyPlanScreenState createState() => _RemedyPlanScreenState();
}

class _RemedyPlanScreenState extends State<RemedyPlanScreen> {
  List<Plans>? plans;
  final TextEditingController _searchController = TextEditingController();
  late StreamSubscription<List<Plans>> planSub;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remedy Plan'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.sick_outlined,
              size: 140,
              color: Colors.redAccent,
            ),
            SizedBox(height: 1),
            Text(
              'What are you treating today?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            ConditionSymptomSelectionButton(
              title: 'Treat a Condition',
              isCondition: true,
              buttonHeight: 50,
            ),
            SizedBox(height: 20),
            ConditionSymptomSelectionButton(
              title: 'Treat a Symptom',
              isCondition: false,
              buttonHeight: 50,
            ),
          ],
        ),
      ),
    );
  }
}

class ConditionSymptomSelectionButton extends StatefulWidget {
  final String title;
  final bool isCondition;
  final double buttonHeight;

  ConditionSymptomSelectionButton({
    required this.title,
    required this.isCondition,
    required this.buttonHeight,
  });

  @override
  _ConditionSymptomSelectionButtonState createState() =>
      _ConditionSymptomSelectionButtonState();
}

class _ConditionSymptomSelectionButtonState
    extends State<ConditionSymptomSelectionButton> {
  String? selectedConditionSymptom;
  List<Plans>? plans;
  late StreamSubscription<List<Plans>> planSub;
  List<Conditions>? conditions;
  late StreamSubscription<List<Conditions>> conditionSub;
  List<Symptoms>? symptoms;
  late StreamSubscription<List<Symptoms>> symptomsub;

  @override
  void initState() {
    super.initState();
    ObjectBox.getInstance().then((objectBox) {
      planSub = objectBox.getPlans().listen((retrievedPlans) {
        setState(() {
          plans = retrievedPlans;
        });
      });
      conditionSub = objectBox.getConditions().listen((retrievedConditions) {
        setState(() {
          conditions = retrievedConditions;
        });
      });
      symptomsub = objectBox.getSymptoms().listen((retrievedSymptoms) {
        setState(() {
          symptoms = retrievedSymptoms;
        });
      });
    });
  }

  @override
  void dispose() {
    planSub.cancel();
    symptomsub.cancel();
    conditionSub.cancel();
    super.dispose();
  }

  List<String> get currentList {
    if (widget.isCondition) {
      return conditions?.map((e) => e.name).toList() ?? [];
    } else {
      return symptoms?.map((e) => e.name).toList() ?? [];
    }
  }

  TextEditingController searchTextController = TextEditingController();

  void _navigateToPromptPage() {
    if (selectedConditionSymptom != null && selectedConditionSymptom!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PromptPage(),
        ),
      );
    }
  }

  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.buttonHeight,
      child: Center(
        child: AutoCompleteTextField<String>(
          key: key,
          controller: searchTextController,
          suggestions: currentList,
          style: TextStyle(fontSize: 16.0),
          decoration: InputDecoration(
            labelText: 'Search for a ${widget.isCondition ? 'Condition' : 'Symptom'}',
            border: OutlineInputBorder(),
          ),
          clearOnSubmit: false,
          textSubmitted: (text) {
            setState(() {
              selectedConditionSymptom = text;
            });
            _navigateToPromptPage();
          },
          itemFilter: (item, query) {
            return item.toLowerCase().contains(query.toLowerCase());
          },
          itemSorter: (a, b) {
            return a.compareTo(b);
          },
          itemSubmitted: (item) {
            setState(() {
              selectedConditionSymptom = item;
            });
            _navigateToPromptPage();
          },
          itemBuilder: (context, item) {
            return ListTile(
              title: Text(item),
            );
          },
        ),
      ),
    );
  }
}

class PromptPage extends StatefulWidget {
  @override
  _PromptPageState createState() => _PromptPageState();
}

class _PromptPageState extends State<PromptPage> {
  String selectedCategory = ''; // To store the selected category
  String selectedDropdownValue = ''; // To store the selected dropdown item

  // Replace these lists with your actual herb, drug, and treatment data from the database
  List<String> herbItems = ['Garlic', 'Sage', 'Herb 3'];
  List<String> drugItems = ['Vitamin', 'Omega3', 'Drug 3'];
  List<String> treatmentItems = ['Spa', 'Acupuncture', 'Treatment 3'];

  TextEditingController herbSearchController = TextEditingController();
  TextEditingController drugSearchController = TextEditingController();
  TextEditingController treatmentSearchController = TextEditingController();

  String getCategoryFromController(
      TextEditingController herbController,
      TextEditingController drugController,
      TextEditingController treatmentController) {
    if (herbController.text.isNotEmpty) {
      return 'Herb';
    } else if (drugController.text.isNotEmpty) {
      return 'Drug';
    } else if (treatmentController.text.isNotEmpty) {
      return 'Treatment';
    } else {
      return '';
    }
  }

  void navigateToRemedyDetailPage(BuildContext context, String category,
      String selectedItem, String conditionName, String selectedCategoryItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RemedyPlanDetailsPage(
          conditionName: conditionName,
          selectedCategoryItem: selectedCategoryItem,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prompt Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selected Category: $selectedCategory',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            Column(
              children: [
                TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: herbSearchController,
                    decoration: InputDecoration(
                      hintText: 'Select a Herb',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return herbItems
                        .where((item) =>
                        item.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      selectedDropdownValue = suggestion;
                      selectedCategory = getCategoryFromController(
                          herbSearchController, drugSearchController, treatmentSearchController);
                    });
                    drugSearchController.clear(); // Clear text in other search bars
                    treatmentSearchController.clear(); // Clear text in other search bars
                    navigateToRemedyDetailPage(
                        context, selectedCategory, suggestion, selectedCategory, suggestion);
                  },
                ),
                TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: drugSearchController,
                    decoration: InputDecoration(
                      hintText: 'Select a Drug',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return drugItems
                        .where((item) =>
                        item.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      selectedDropdownValue = suggestion;
                      selectedCategory = getCategoryFromController(
                          herbSearchController, drugSearchController, treatmentSearchController);
                    });
                    herbSearchController.clear(); // Clear text in other search bars
                    treatmentSearchController.clear(); // Clear text in other search bars
                    navigateToRemedyDetailPage(
                        context, selectedCategory, suggestion, selectedCategory, suggestion);
                  },
                ),
                TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: treatmentSearchController,
                    decoration: InputDecoration(
                      hintText: 'Select a Treatment',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return treatmentItems
                        .where((item) =>
                        item.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      selectedDropdownValue = suggestion;
                      selectedCategory = getCategoryFromController(
                          herbSearchController, drugSearchController, treatmentSearchController);
                    });
                    herbSearchController.clear(); // Clear text in other search bars
                    drugSearchController.clear(); // Clear text in other search bars
                    navigateToRemedyDetailPage(
                        context, selectedCategory, suggestion, selectedCategory, suggestion);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RemedyPlanDetailsPage extends StatefulWidget {
  final String conditionName;
  final String selectedCategoryItem;

  RemedyPlanDetailsPage({
    required this.conditionName,
    required this.selectedCategoryItem,
  });

  @override
  _RemedyPlanDetailsPageState createState() => _RemedyPlanDetailsPageState();
}

class _RemedyPlanDetailsPageState extends State<RemedyPlanDetailsPage> {
  final List<IconData> icons = [
    Icons.warning,
    Icons.library_books,
    Icons.local_pharmacy,
    Icons.nature,
    Icons.receipt,
    Icons.star,
  ];

  final List<String> titles = [
    'Cautions',
    'Instructions',
    'Drugs Commonly Used',
    'Herbal Alternatives',
    'References',
    'Reviews',
  ];

  int selectedIconIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.conditionName} - ${widget.selectedCategoryItem}'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                icons.length,
                    (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIconIndex = index;
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                          icons[index],
                          size: 40,
                          color: selectedIconIndex == index
                              ? Colors.blue
                              : Colors.red, // You can change the color here
                        ),
                        Text(
                          selectedIconIndex == index ? titles[index] : '',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          if (selectedIconIndex != -1) ...[
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      titles[selectedIconIndex],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      // Replace with different information for each icon
                      getInformationForIcon(selectedIconIndex),
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String getInformationForIcon(int index) {
    // Replace this with logic to return different information for each icon
    switch (index) {
      case 0:
        return 'Cautions details go here...';
      case 1:
        return 'Instructions details go here...';
      case 2:
        return 'Drugs details go here...';
      case 3:
        return 'Herbal alternatives details go here...';
      case 4:
        return 'References details go here...';
      case 5:
        return 'Reviews details go here...';
      default:
        return '';
    }
  }
}
