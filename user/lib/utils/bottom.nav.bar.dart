import 'package:flutter/material.dart';
import 'package:september_twenty_nine_user/screens/home.page.dart';
import 'package:september_twenty_nine_user/screens/condition.page.dart';
import 'package:september_twenty_nine_user/screens/item.page.dart';
import 'package:september_twenty_nine_user/screens/profile.page.dart';
import 'package:september_twenty_nine_user/screens/symptom.page.dart';
import 'package:september_twenty_nine_user/screens/review.page.dart';

import '../entities/user.entity.dart';
import '../screens/plan.page.dart';
import '../screens/prompt.page.dart';
import '../screens/remedyplan.page.dart';

class MyBottomNavigationBar extends StatefulWidget {
final User? currentUser;  // Declare a final variable to hold the currentUser

const MyBottomNavigationBar({Key? key, required this.currentUser}) : super(key: key);

@override
_MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomePage(),
      ConditionOrSymptom(),
      ReviewsScreen(),
      ItemList(),
      PlanList(),
      ConditionRemedyPlan(),
      ConditionCategoryRemedyPlan(conditionId: 0),
      SymptomCategoryRemedyPlan(symptomId: 0),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.teal,
          primaryColor: Colors.white,
          textTheme: Theme.of(context).textTheme.copyWith(
            bodySmall: const TextStyle(color: Colors.orange),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex, // Set the current index here
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.shifting,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medication),
              label: 'Remedies',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.reviews_outlined),
              label: 'Reviews',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Plans',
            ),
          ],
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.white,
        ),
      ),
    );
  }
}
