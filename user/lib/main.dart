import 'dart:async';
import 'package:flutter/material.dart';
import 'package:september_twenty_nine_user/screens/landing.page.dart';
import 'package:september_twenty_nine_user/screens/remedyplan.page.dart';
import 'package:september_twenty_nine_user/utils/bottom.nav.bar.dart';
import 'screens/home.page.dart';
import 'screens/item.page.dart';
import 'screens/condition.page.dart';
import 'screens/prompt.page.dart';
import 'screens/plan.page.dart';
import 'screens/symptom.page.dart';
import 'screens/review.page.dart';
import 'utils/objectbox.store.dart';
import 'package:flutter/services.dart';

void main() async {
  // This ensures that the binding is initialized before using platform-specific services.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize your ObjectBox
  await ObjectBox.getInstance();

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
      routes: {
      //  '/CategoryScreen': (context) => CategoryL(),
        '/ItemScreen':(context)=> ItemList(),
        '/SymptomScreen':(context)=> SymptomList(),
        '/ConditionScreen': (context)=> ConditionList(),
        '/PlanScreen':(context)=> PlanList(),
        'RemedyPlanScreen':(context)=> RemedyPlanScreen(),
        '/bottomNavbar':(context)=> MyBottomNavigationBar(currentUser: null),
        //'/InteractionScreen': (context)=> InteractionsPage(),
        // '/CalculatorScreen': (context) => CalculatorPage(),
        //'/DeleteConditionScreen': (context)=> DeleteConditionPage(selectedConditions: selectedConditions),
          '/ReviewScreen': (context) => ReviewsScreen(),
      },
    );
  }
}
